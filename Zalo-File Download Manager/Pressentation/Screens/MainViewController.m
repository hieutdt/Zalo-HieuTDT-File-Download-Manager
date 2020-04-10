//
//  MainViewController.m
//  Zalo-File Download Manager
//
//  Created by Trần Đình Tôn Hiếu on 3/27/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "MainViewController.h"

#import "AppConsts.h"

#import "FileDownloadTableViewModel.h"
#import "FileDownloadViewModel.h"
#import "FileDownloadCell.h"

#import "FileDownloadManager.h"

@interface MainViewController () <UITableViewDelegate, FileDownloadTableViewModelDelegate>

@property (nonatomic, strong) UIBarButtonItem *downloadBarButton;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) FileDownloadTableViewModel *tableViewModel;

@property (nonatomic, strong) NSMutableArray<FileDownloadViewModel *> *fileViewModels;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray *> *urlHashMap;

@property (nonatomic, strong) void (^progressHandler)(NSString *url, long long bytesWritten, long long totalBytes);
@property (nonatomic, strong) void (^completionHandler)(NSString *url, NSString *locationPath, NSError *error);

@property (nonatomic) BOOL isScrolling;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _fileViewModels = [[NSMutableArray alloc] init];
    _urlHashMap = [[NSMutableDictionary alloc] init];
    
    NSArray *urls = @[
        @"http://ovh.net/files/1Mio.dat",
        @"http://ovh.net/files/1Mio.dat",
        @"http://ovh.net/files/10Mio.dat",
        @"http://ovh.net/files/10Mio.dat",
        @"http://ovh.net/files/100Mio.dat"
    ];
    
    for (int i = 0; i < 5; i++) {
        FileDownloadViewModel *viewModel = [[FileDownloadViewModel alloc] initWithFileName:[NSString stringWithFormat:@"Tập tin %d", i]
                                                                                       url:urls[i]
                                                                                     state:FileDownloading
                                                                                totalBytes:0
                                                                              bytesWritten:0];
        [self.fileViewModels addObject:viewModel];
        
        NSMutableArray *hashMapObject = [_urlHashMap valueForKey:viewModel.url];
        if (hashMapObject) {
            [hashMapObject addObject:viewModel];
        } else {
            hashMapObject = [[NSMutableArray alloc] init];
            [hashMapObject addObject:viewModel];
            [_urlHashMap addEntriesFromDictionary:@{ viewModel.url : hashMapObject }];
        }
    }
    
    NSLog(@"Url Hash map: %@", self.urlHashMap);
    
    _isScrolling = NO;
    
    __weak MainViewController *weakSelf = self;
    _progressHandler = ^(NSString *url, long long bytesWritten, long long totalBytes) {
        NSMutableArray<FileDownloadViewModel *> *hashMapObject = [weakSelf.urlHashMap objectForKey:url];
        if (hashMapObject) {
            for (int i = 0; i < hashMapObject.count; i++) {
                int index = (int)[weakSelf.fileViewModels indexOfObject:hashMapObject[i]];
                if (weakSelf.fileViewModels[index].state == FileDownloading) {
                    [weakSelf updateCellAtIndex:index
                                      withState:FileDownloading
                                   bytesWritten:bytesWritten
                                     totalBytes:totalBytes];
                }
            }
        }
    };
    
    _completionHandler = ^(NSString *url, NSString *locationPath, NSError *error) {
        NSMutableArray<FileDownloadViewModel *> *hashMapObject = [weakSelf.urlHashMap objectForKey:url];
        if (hashMapObject) {
            for (int i = 0; i < hashMapObject.count; i++) {
                int index = (int)[weakSelf.fileViewModels indexOfObject:hashMapObject[i]];
                if (weakSelf.fileViewModels[index].state == FileDownloading) {
                    if (error) {
                        [weakSelf updateCellAtIndex:index
                                          withState:FileDownloadCancel
                                       bytesWritten:weakSelf.fileViewModels[index].bytesWritten
                                         totalBytes:weakSelf.fileViewModels[index].totalBytes];
                    } else {
                        [weakSelf updateCellAtIndex:index
                                          withState:FileDownloadFinish
                                       bytesWritten:weakSelf.fileViewModels[index].bytesWritten
                                         totalBytes:weakSelf.fileViewModels[index].totalBytes];
                    }
                }
            }
        }
    };
    
    [self initAndLayoutView];
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

- (void)downloadButtonTapped {
    _tableViewModel = [[FileDownloadTableViewModel alloc] initWithListArray:self.fileViewModels];
    _tableViewModel.delegate = self;
    
    _tableView.dataSource = _tableViewModel.tableViewDataSource;
    _tableView.delegate = _tableViewModel.tableViewDelegate;
    
    [_tableView reloadData];
    
    for (int i = 0; i < self.fileViewModels.count; i++) {
        FileDownloadViewModel *viewModel = self.fileViewModels[i];
        [[FileDownloadManager instance] performDownloadFileWithUrl:viewModel.url
                                                          priority:TaskPriorityNormal
                                         timeOutIntervalForRequest:30
                                                   progressHandler:self.progressHandler
                                                 completionHandler:self.completionHandler];
    }
    
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
    
    if (index >= weakSelf.fileViewModels.count)
        return;
    
    if (self.isScrolling)
        return;
    
    float progress = 0;
    if (totalBytes > 0) {
        progress = bytesWritten * 1.0 / totalBytes;
        progress = roundf(progress * 50) / 50;
    } else {
        progress = 0;
    }
    
    if ((progress > weakSelf.fileViewModels[index].progress && weakSelf.fileViewModels[index].state == FileDownloading)
        || state != weakSelf.fileViewModels[index].state) {
        
        weakSelf.fileViewModels[index].state = state;
        weakSelf.fileViewModels[index].bytesWritten = bytesWritten;
        weakSelf.fileViewModels[index].totalBytes = totalBytes;
        weakSelf.fileViewModels[index].progress = progress;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            [UIView performWithoutAnimation:^{
                [weakSelf.tableView beginUpdates];
                [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                [weakSelf.tableView endUpdates];
            }];
        });
    }
}


#pragma mark - DownloadFileActionMethod

- (void)pauseDownloadFileAtIndex:(int)index {
    if (index >= self.fileViewModels.count)
        return;
    
    // Pause or Cancel if failed
    if (self.fileViewModels[index].state == FileDownloading) {
        int sameUrlRunningTaskCount = [self getSameUrlRunningTasksCount:self.fileViewModels[index].url];
        
        if (sameUrlRunningTaskCount > 1) {
            [self updateCellAtIndex:index
                          withState:FileDownloadPause
                       bytesWritten:self.fileViewModels[index].bytesWritten
                         totalBytes:self.fileViewModels[index].totalBytes];
            return;
        }
        
        [[FileDownloadManager instance] pauseDownloadFileWithUrl:self.fileViewModels[index].url
                                               completionHandler:^(NSString * _Nonnull url, NSError *error) {
            if (!url)
                return;
            if ([url isEqualToString:self.fileViewModels[index].url]) {
                if (!error) {
                    [self updateCellAtIndex:index
                                  withState:FileDownloadPause
                               bytesWritten:self.fileViewModels[index].bytesWritten
                                 totalBytes:self.fileViewModels[index].totalBytes];
                } else {
                    NSLog(@"Error: %@", error.userInfo);
                    [self updateCellAtIndex:index withState:FileDownloadCancel bytesWritten:0 totalBytes:0];
                }
            }
        }];
    }
}

- (void)resumeDownloadFileAtIndex:(int)index {
    if (index >= self.fileViewModels.count)
        return;
    
    if (self.fileViewModels[index].state == FileDownloadPause) {
        int sameUrlRunningTaskCount = [self getSameUrlRunningTasksCount:self.fileViewModels[index].url];
        
        if (sameUrlRunningTaskCount > 0) {
            [self updateCellAtIndex:index
                          withState:FileDownloading
                       bytesWritten:self.fileViewModels[index].bytesWritten
                         totalBytes:self.fileViewModels[index].totalBytes];
            return;
        }
        
        [[FileDownloadManager instance] resumeDownloadFileWithUrl:self.fileViewModels[index].url
                                                completionHandler:^(NSString * _Nonnull url, NSError *error) {
            if (!url)
                return;
            if ([url isEqualToString:self.fileViewModels[index].url]) {
                if (!error) {
                    [self updateCellAtIndex:index
                                  withState:FileDownloading
                               bytesWritten:self.fileViewModels[index].bytesWritten
                                 totalBytes:self.fileViewModels[index].totalBytes];
                } else {
                    NSLog(@"Error: %@", error.userInfo);
                    [self updateCellAtIndex:index withState:FileDownloadCancel bytesWritten:0 totalBytes:0];
                }
            }
        }];
    }
}

- (void)cancelDownloadFileAtIndex:(int)index {
    if (index >= self.fileViewModels.count)
        return;
    
    if (self.fileViewModels[index].state == FileDownloading
        || self.fileViewModels[index].state == FileDownloadPause) {
        int sameUrlRunningTaskCount = [self getSameUrlRunningTasksCount:self.fileViewModels[index].url];
        if (sameUrlRunningTaskCount > 1) {
            [self updateCellAtIndex:index withState:FileDownloadCancel bytesWritten:0 totalBytes:0];
            return;
        }
        
        [[FileDownloadManager instance] cancelDownloadFileWithUrl:self.fileViewModels[index].url
                                                completionHandler:^(NSString * _Nonnull url) {
            [self updateCellAtIndex:index withState:FileDownloadCancel bytesWritten:0 totalBytes:0];
        }];
    }
}
    
- (void)retryDownloadFileAtIndex:(int)index {
    if (index >= self.fileViewModels.count)
        return;
    
    if (self.fileViewModels[index].state == FileDownloadCancel) {
        int sameUrlRunningTaskCount = [self getSameUrlRunningTasksCount:self.fileViewModels[index].url];
        
        if (sameUrlRunningTaskCount > 0) {
            [self updateCellAtIndex:index
                          withState:FileDownloading
                       bytesWritten:self.fileViewModels[index].bytesWritten
                         totalBytes:self.fileViewModels[index].totalBytes];
            return;
        }
        
        [[FileDownloadManager instance] retryDownloadFileWithUrl:self.fileViewModels[index].url
                                               completionHandler:^(NSString * _Nonnull url, NSError *error) {
            if (!error) {
                [self updateCellAtIndex:index withState:FileDownloading bytesWritten:0 totalBytes:0];
            } else {
                // Show notification
            }
        }];
    }
}

- (int)getSameUrlRunningTasksCount:(NSString *)url {
    NSMutableArray<FileDownloadViewModel *> *hashMapObject = [self.urlHashMap objectForKey:url];
    
    int sameUrlRunningTaskCount = 0;
    for (int i = 0; i < hashMapObject.count; i++) {
        if (hashMapObject[i].state == FileDownloading)
            sameUrlRunningTaskCount++;
    }
    return sameUrlRunningTaskCount;
}

#pragma mark - FileDownloadTableViewModelDelegateProtocol

- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    int index = (int)indexPath.row;
    if (index >= self.fileViewModels.count)
        return;
    
    FileDownloadViewModel *viewModel = self.fileViewModels[index];
    NSString *message = @"";
    UIAlertAction *firstAction = nil;
    UIAlertAction *secondAction = nil;
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Huỷ" style:UIAlertActionStyleCancel handler:nil];

    if (viewModel.state == FileDownloading) {
        message = [NSString stringWithFormat:@"%@ đang được tải. Bạn có muốn?", viewModel.fileName];;
        firstAction = [UIAlertAction actionWithTitle:@"Tạm dừng"
                                               style:UIAlertActionStyleDefault
                                             handler:^(UIAlertAction * _Nonnull action) {
            [self pauseDownloadFileAtIndex:index];
        }];

        secondAction = [UIAlertAction actionWithTitle:@"Kết thúc"
                                                style:UIAlertActionStyleDefault
                                              handler:^(UIAlertAction * _Nonnull action) {
            [self cancelDownloadFileAtIndex:index];
        }];
    } else if (viewModel.state == FileDownloadPause) {
        message = [NSString stringWithFormat:@"%@ đang tạm ngừng tải xuống. Bạn có muốn?", viewModel.fileName];
        firstAction = [UIAlertAction actionWithTitle:@"Tiếp tục"
                                               style:UIAlertActionStyleDefault
                                             handler:^(UIAlertAction * _Nonnull action) {
            [self resumeDownloadFileAtIndex:index];
        }];

        secondAction = [UIAlertAction actionWithTitle:@"Kết thúc"
                                                style:UIAlertActionStyleDefault
                                              handler:^(UIAlertAction * _Nonnull action) {
            [self cancelDownloadFileAtIndex:index];
        }];
    } else if (viewModel.state == FileDownloadCancel) {
            message = [NSString stringWithFormat:@"%@ đã bị hủy tải xuống. Bạn có muốn?", viewModel.fileName];
            firstAction = [UIAlertAction actionWithTitle:@"Thử lại"
                                                   style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction * _Nonnull action) {
                [self retryDownloadFileAtIndex:index];
            }];
    } else {
        return;
    }
    
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
