//
//  MainViewController.m
//  Zalo-File Download Manager
//
//  Created by Trần Đình Tôn Hiếu on 3/27/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "MainViewController.h"
#import "NimbusCore.h"
#import "NimbusModels.h"
#import "File.h"
#import "FileDownloadBusiness.h"
#import "FileDownloadTableViewModel.h"
#import "FileDownloadViewModel.h"

@interface MainViewController () <UITableViewDelegate>

@property (nonatomic, strong) UIBarButtonItem *downloadBarButton;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) FileDownloadBusiness *fileDownloadBusiness;

@property (nonatomic, strong) NSMutableArray<File *> *downloadFiles;
@property (nonatomic, strong) NSMutableArray *progressHandlers;
@property (nonatomic, strong) NSMutableArray *completionHandlers;

@property (nonatomic, strong) NITableViewModel *dataSource;
@property (nonatomic, strong) FileDownloadTableViewModel *tableViewModel;
@property (nonatomic, strong) NSArray<FileDownloadViewModel *> *viewModelsArray;

@end

@implementation MainViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    _fileDownloadBusiness = [[FileDownloadBusiness alloc] init];
    
    _downloadFiles = [self.fileDownloadBusiness getDownloadFiles];
    _progressHandlers = [[NSMutableArray alloc] init];
    _completionHandlers = [[NSMutableArray alloc] init];
    
    __weak MainViewController *weakSelf = self;
    
    for (unsigned long i = 0; i < self.downloadFiles.count; i++) {
        [self.progressHandlers addObject:^(float progress, unsigned long index) {
            if (index < self.downloadFiles.count) {
                if (progress <= weakSelf.downloadFiles[index].progress)
                    return;
                
                weakSelf.downloadFiles[index].state = FileDownloading;
                weakSelf.downloadFiles[index].progress = progress;
                
                [weakSelf.viewModelsArray[index] updateByFile:weakSelf.downloadFiles[index]];
                
                // Update UI
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                    [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                });
            }
        }];
        
        [self.completionHandlers addObject:^(NSError *error, unsigned long index) {
            if (index < self.downloadFiles.count) {
                weakSelf.downloadFiles[index].state = FileDownloadFinish;
                weakSelf.downloadFiles[index].progress = 1;
                
                [weakSelf.viewModelsArray[index] updateByFile:weakSelf.downloadFiles[index]];
                
                // Update UI
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                    [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                });
            }
        }];
    }
    
    [self initAndLayoutView];
}

- (void)initAndLayoutView {
    [self.navigationController setNavigationBarHidden:NO animated:YES];

    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Download Manager";
    
    _downloadBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Download" style:UIBarButtonItemStylePlain target:self action:@selector(downloadButtonTapped)];
    self.navigationItem.rightBarButtonItem = _downloadBarButton;
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    
    _viewModelsArray = [self getViewModelsFromFileEntities:self.downloadFiles];
    _tableViewModel = [[FileDownloadTableViewModel alloc] initWithListArray:self.viewModelsArray];
    
    _dataSource = _tableViewModel.dataSource;

    _tableView.dataSource = _dataSource;
    _tableView.delegate = _tableViewModel.delegate;
}

- (NSArray<FileDownloadViewModel *> *)getViewModelsFromFileEntities:(NSArray<File *> *)files {
    NSMutableArray *viewModels = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < files.count; i++) {
        FileDownloadViewModel *viewModel = [[FileDownloadViewModel alloc] initWithFile:files[i]];
        [viewModels addObject:viewModel];
    }
    
    return viewModels;
}

- (void)downloadButtonTapped {
    [self.fileDownloadBusiness downloadMultiFiles:self.downloadFiles withProgressHandlers:self.progressHandlers completionHandlers:self.completionHandlers];
}

@end
