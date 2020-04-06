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
#import "FileDownloadCell.h"
#import "AppConsts.h"
#import "FileDownloadOperator.h"

@interface MainViewController () <UITableViewDelegate, FileDownloadTableViewModelDelegate>

@property (nonatomic, strong) UIBarButtonItem *downloadBarButton;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) FileDownloadBusiness *fileDownloadBusiness;

@property (nonatomic, strong) NSMutableArray<File *> *downloadFiles;
@property (nonatomic, strong) NSMutableArray<void (^)(unsigned long, long long, long long)> *progressHandlers;
@property (nonatomic, strong) NSMutableArray<void (^)(NSError *, unsigned long)> *completionHandlers;

@property (nonatomic, strong) FileDownloadTableViewModel *tableViewModel;
@property (nonatomic, strong) NSArray<FileDownloadViewModel *> *viewModelsArray;

@property (nonatomic) BOOL isScrolling;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _fileDownloadBusiness = [[FileDownloadBusiness alloc] init];
    _progressHandlers = [[NSMutableArray alloc] init];
    _completionHandlers = [[NSMutableArray alloc] init];
    
    _isScrolling = NO;
    
    [self initDownloadFilesWithCount:5];
    
    __weak MainViewController *weakSelf = self;
    
    for (unsigned long i = 0; i < self.downloadFiles.count; i++) {
        [self.progressHandlers addObject:^(unsigned long index, long long bytesWritten, long long totalBytes) {
            if (index < self.downloadFiles.count) {
                // Only update ui if the download is more than 1MB to avoid high CPU if reload cell too much
                if (bytesWritten - self.downloadFiles[index].bytesWritten < 1024 * 1024)
                    return;
                
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
    _tableView.tableFooterView = [[UIView alloc] init];
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
    
    // Hide that download button after clicked
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)updateCellAtIndex:(int)index
                withState:(FileDownloadState)state
             bytesWritten:(long long)bytesWritten
               totalBytes:(long long)totalBytes {
    if (self.isScrolling)
        return;
    
    __weak MainViewController *weakSelf = self;
    
    if (index >= weakSelf.downloadFiles.count) {
        return;
    }
    
    weakSelf.downloadFiles[index].state = state;
    weakSelf.downloadFiles[index].bytesWritten = bytesWritten;
    weakSelf.downloadFiles[index].totalBytes = totalBytes;
    [weakSelf.viewModelsArray[index] updateByFile:weakSelf.downloadFiles[index]];
    
    if (self.isScrolling) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [UIView performWithoutAnimation:^{
            [weakSelf.tableView beginUpdates];
            [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [weakSelf.tableView endUpdates];
        }];
    });
}

#pragma mark - DownloadFileActionMethod

- (void)pauseDownloadFileAtIndex:(int)index {
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
    }
}

- (void)resumeDownloadFileAtIndex:(int)index {
    if (index >= self.downloadFiles.count)
           return;
    
    if (self.downloadFiles[index].state == FileDownloadPause) {
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
    }
}

- (void)cancelDownloadFileAtIndex:(int)index {
    if (index >= self.downloadFiles.count)
        return;
    
    [self.fileDownloadBusiness cancelDownloadTaskAtIndex:index withCompletionHandler:^(NSError *error) {
        if (!error) {
            [self updateCellAtIndex:index withState:FileDownloadCancel bytesWritten:0 totalBytes:self.downloadFiles[index].totalBytes];
        }
    }];
}

- (void)retryDownloadFileAtIndex:(int)index {
    if (index >= self.downloadFiles.count)
        return;
    
    if (self.downloadFiles[index].state == FileDownloadCancel) {
       //Retry
       [self updateCellAtIndex:index withState:FileDownloading bytesWritten:0 totalBytes:self.downloadFiles[index].totalBytes];
       
       [self.fileDownloadBusiness retryDownloadFile:self.downloadFiles[index] atIndex:index withProgressHandler:self.progressHandlers[index] downloadCompleteHandler:self.completionHandlers[index]];
    }
}


#pragma mark - FileDownloadTableViewModelDelegateProtocol

- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    int index = (int)indexPath.row;
    if (index >= self.downloadFiles.count)
        return;
    
    File *file = self.downloadFiles[index];
    NSString *message = @"";
    UIAlertAction *firstAction = nil;
    UIAlertAction *secondAction = nil;
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Huỷ" style:UIAlertActionStyleCancel handler:nil];
    
    if (file.state == FileDownloading) {
        message = [NSString stringWithFormat:@"%@ đang được tải. Bạn có muốn?", file.fileName];
        firstAction = [UIAlertAction actionWithTitle:@"Tạm dừng" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self pauseDownloadFileAtIndex:index];
        }];
        
        secondAction = [UIAlertAction actionWithTitle:@"Kết thúc" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self cancelDownloadFileAtIndex:index];
        }];
        
    } else if (file.state == FileDownloadPause) {
        message = [NSString stringWithFormat:@"%@ đang tạm ngừng tải xuống. Bạn có muốn?", file.fileName];
        firstAction = [UIAlertAction actionWithTitle:@"Tiếp tục" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self resumeDownloadFileAtIndex:index];
        }];
        
        secondAction = [UIAlertAction actionWithTitle:@"Kết thúc" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self cancelDownloadFileAtIndex:index];
        }];
        
    } else if (file.state == FileDownloadCancel) {
        message = [NSString stringWithFormat:@"%@ đã bị hủy tải xuống. Bạn có muốn?", file.fileName];
        firstAction = [UIAlertAction actionWithTitle:@"Thử lại" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self retryDownloadFileAtIndex:index];
        }];
        
    } else
        return;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Thông báo" message:message preferredStyle:UIAlertControllerStyleActionSheet];
    
    if (firstAction)
        [alert addAction:firstAction];
    if (secondAction)
        [alert addAction:secondAction];
    if (cancelAction)
        [alert addAction:cancelAction];
        
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)scrollViewDidBeginScroll {
    self.isScrolling = YES;
}

- (void)scrollViewDidEndScroll {
    self.isScrolling = NO;
    [self.tableView reloadData];
}

@end
