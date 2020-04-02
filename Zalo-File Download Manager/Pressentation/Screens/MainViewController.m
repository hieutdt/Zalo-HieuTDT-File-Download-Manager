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
#import "AppConsts.h"

@interface MainViewController () <UITableViewDelegate, FileDownloadTableViewModelDelegate>

@property (nonatomic, strong) UIBarButtonItem *downloadBarButton;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) FileDownloadBusiness *fileDownloadBusiness;

@property (nonatomic, strong) NSMutableArray<File *> *downloadFiles;
@property (nonatomic, strong) NSMutableArray<void (^)(float, unsigned long)> *progressHandlers;
@property (nonatomic, strong) NSMutableArray<void (^)(NSError *, unsigned long)> *completionHandlers;

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
    _tableViewModel.delegate = self;
    
    _tableView.dataSource = _tableViewModel.tableViewDataSource;
    _tableView.delegate = _tableViewModel.tableViewDelegate;
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


#pragma mark - FileDownloadTableViewModelDelegateProtocol

- (void)pauseButtonTappedAtCell:(FileDownloadCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    int index = (int)indexPath.row;
    
    if (index >= self.downloadFiles.count)
        return;
    
    if (self.downloadFiles[index].state == FileDownloading) {
        [self.fileDownloadBusiness pauseDownloadTaskAtIndex:index withCompletionHandler:^(NSError *error) {
            if (!error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.downloadFiles[index].state = FileDownloadPause;
                    self.viewModelsArray[index].state = FileDownloadPause;
                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.downloadFiles[index].state = FileDownloadCancel;
                    self.viewModelsArray[index].state = FileDownloadCancel;
                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                });
            }
        }];
        
    } else if (self.downloadFiles[index].state == FileDownloadPause) {
        [self.fileDownloadBusiness resumeDownloadTaskAtIndex:index withProgressHandler:^(float progress, unsigned long index) {
            self.progressHandlers[index](progress, index);
            
        } downloadCompleteHandler:^(NSError *error, unsigned long index) {
            self.completionHandlers[index](error, index);
            
        } resumeCompletionHandler:^(NSError *error) {
            if (error) {
                self.downloadFiles[index].state = FileDownloadCancel;
                self.viewModelsArray[index].state = FileDownloadCancel;
                
                // Update UI
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                });
            } else {
                self.downloadFiles[index].state = FileDownloading;
                self.viewModelsArray[index].state = FileDownloading;
                
                // Update UI
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                });
            }
        }];
        
    } else if (self.downloadFiles[index].state == FileDownloadCancel) {
        // TODO: retry here
        self.downloadFiles[index].state = FileDownloading;
        self.downloadFiles[index].progress = 0;
        [self.viewModelsArray[index] updateByFile:self.downloadFiles[index]];
        // Update UI
        dispatch_async(dispatch_get_main_queue(), ^{
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        });
        
        [self.fileDownloadBusiness retryDownloadFile:self.downloadFiles[index] atIndex:index withProgressHandler:self.progressHandlers[index] downloadCompleteHandler:self.completionHandlers[index]];
    }
}

- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Huỷ tải xuống" message:[NSString stringWithFormat:@"Bạn có muốn kết thúc tải xuống tập tin %@", self.downloadFiles[indexPath.row].fileName] preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *acceptAction = [UIAlertAction actionWithTitle:@"Xác nhận" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        int index = (int)indexPath.row;
        [self.fileDownloadBusiness cancelDownloadTaskAtIndex:index withCompletionHandler:^(NSError *error) {
            if (!error) {
                self.downloadFiles[index].state = FileDownloadCancel;
                self.viewModelsArray[index].state = FileDownloadCancel;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                });
            } else {
                
            }
        }];
        
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Từ chối" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:acceptAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
