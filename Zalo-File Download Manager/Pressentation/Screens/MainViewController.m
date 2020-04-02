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
@property (nonatomic, strong) NSMutableArray<void (^)(unsigned long, long long, long long)> *progressHandlers;
@property (nonatomic, strong) NSMutableArray<void (^)(NSError *, unsigned long)> *completionHandlers;

@property (nonatomic, strong) FileDownloadTableViewModel *tableViewModel;
@property (nonatomic, strong) NSArray<FileDownloadViewModel *> *viewModelsArray;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _fileDownloadBusiness = [[FileDownloadBusiness alloc] init];
    _progressHandlers = [[NSMutableArray alloc] init];
    _completionHandlers = [[NSMutableArray alloc] init];
    
    [self initDownloadFilesWithCount:5];
    
    __weak MainViewController *weakSelf = self;
    
    for (unsigned long i = 0; i < self.downloadFiles.count; i++) {
        [self.progressHandlers addObject:^(unsigned long index, long long bytesWritten, long long totalBytes) {
            if (index < self.downloadFiles.count) {
                [weakSelf updateCellAtIndex:(int)index withState:FileDownloading bytesWritten:bytesWritten totalBytes:totalBytes];
            }
        }];
        
        [self.completionHandlers addObject:^(NSError *error, unsigned long index) {
            if (index < self.downloadFiles.count) {
                [weakSelf updateCellAtIndex:(int)index withState:FileDownloadFinish bytesWritten:weakSelf.downloadFiles[index].totalBytes totalBytes:weakSelf.downloadFiles[index].totalBytes];
            }
        }];
    }
    
    [self initAndLayoutView];
}

- (void)initDownloadFilesWithCount:(int)count {
    _downloadFiles = [[NSMutableArray alloc] init];
    for (int i = 0; i < count; i++) {
        File *file = [[File alloc] initWithName:[NSString stringWithFormat:@"Tập tin %d", i + 1] url:googleDrive1GBFileUrl];
        [_downloadFiles addObject:file];
    }
}

- (void)initAndLayoutView {
    [self.navigationController setNavigationBarHidden:NO animated:YES];

    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Download Manager";
    
    _downloadBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Download" style:UIBarButtonItemStylePlain target:self action:@selector(downloadButtonTapped)];
    self.navigationItem.rightBarButtonItem = _downloadBarButton;
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
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
    _viewModelsArray = [self getViewModelsFromFileEntities:self.downloadFiles];
    
    _tableViewModel = [[FileDownloadTableViewModel alloc] initWithListArray:self.viewModelsArray];
    _tableViewModel.delegate = self;
    
    _tableView.dataSource = _tableViewModel.tableViewDataSource;
    _tableView.delegate = _tableViewModel.tableViewDelegate;
    
    [_tableView reloadData];
    
    [self.fileDownloadBusiness downloadMultiFiles:self.downloadFiles withProgressHandlers:self.progressHandlers completionHandlers:self.completionHandlers];
}

- (void)updateCellAtIndex:(int)index
                withState:(FileDownloadState)state
             bytesWritten:(long long)bytesWritten
               totalBytes:(long long)totalBytes {
    __weak MainViewController *weakSelf = self;
    
    if (index >= weakSelf.downloadFiles.count) {
        return;
    }
    
    weakSelf.downloadFiles[index].state = state;
    weakSelf.downloadFiles[index].bytesWritten = bytesWritten;
    weakSelf.downloadFiles[index].totalBytes = totalBytes;
    [weakSelf.viewModelsArray[index] updateByFile:weakSelf.downloadFiles[index]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    });
}

#pragma mark - FileDownloadTableViewModelDelegateProtocol

- (void)pauseButtonTappedAtCell:(FileDownloadCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    int index = (int)indexPath.row;
    
    if (index >= self.downloadFiles.count)
        return;
    
    if (self.downloadFiles[index].state == FileDownloading) {
        // Pause or cancel if failed
        [self.fileDownloadBusiness pauseDownloadTaskAtIndex:index withCompletionHandler:^(NSError *error) {
            if (!error) {
                [self updateCellAtIndex:index withState:FileDownloadPause bytesWritten:self.downloadFiles[index].bytesWritten totalBytes:self.downloadFiles[index].totalBytes];
            } else {
                [self updateCellAtIndex:index withState:FileDownloadCancel bytesWritten:0 totalBytes:self.downloadFiles[index].totalBytes];
            }
        }];
        
    } else if (self.downloadFiles[index].state == FileDownloadPause) {
        // Resume
        [self.fileDownloadBusiness resumeDownloadTaskAtIndex:index withProgressHandler:^(unsigned long index, long long bytesWritten, long long totalBytes) {
            self.progressHandlers[index](index, bytesWritten, totalBytes);
            
        } downloadCompleteHandler:^(NSError *error, unsigned long index) {
            self.completionHandlers[index](error, index);
            
        } resumeCompletionHandler:^(NSError *error) {
            if (error) {
                [self updateCellAtIndex:index withState:FileDownloadCancel bytesWritten:0 totalBytes:self.downloadFiles[index].totalBytes];
            } else {
                [self updateCellAtIndex:index withState:FileDownloading bytesWritten:self.downloadFiles[index].bytesWritten totalBytes:self.downloadFiles[index].totalBytes];
            }
        }];
        
    } else if (self.downloadFiles[index].state == FileDownloadCancel) {
        //Retry
        [self updateCellAtIndex:index withState:FileDownloading bytesWritten:0 totalBytes:self.downloadFiles[index].totalBytes];
        
        [self.fileDownloadBusiness retryDownloadFile:self.downloadFiles[index] atIndex:index withProgressHandler:self.progressHandlers[index] downloadCompleteHandler:self.completionHandlers[index]];
    }
}

- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Huỷ tải xuống" message:[NSString stringWithFormat:@"Bạn có muốn kết thúc tải xuống tập tin %@", self.downloadFiles[indexPath.row].fileName] preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *acceptAction = [UIAlertAction actionWithTitle:@"Xác nhận" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        int index = (int)indexPath.row;
        [self.fileDownloadBusiness cancelDownloadTaskAtIndex:index withCompletionHandler:^(NSError *error) {
            if (!error) {
                [self updateCellAtIndex:index withState:FileDownloadCancel bytesWritten:0 totalBytes:self.downloadFiles[index].totalBytes];
            }
        }];
        
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Từ chối" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:acceptAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
