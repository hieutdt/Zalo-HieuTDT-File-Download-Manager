//
//  FileDownloadOperator.m
//  Zalo-File Download Manager
//
//  Created by Trần Đình Tôn Hiếu on 4/5/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "FileDownloadOperator.h"
#import "DownloadDataCache.h"
#import "AppDelegate.h"

@interface FileDownloadOperator () <NSURLSessionDownloadDelegate, NSURLSessionDelegate>

@property (nonatomic, strong) FileDownloadItem *item;
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) dispatch_queue_t callBackQueue;

@end

@implementation FileDownloadOperator

- (instancetype)init {
    self = [super initWithTaskBlock:^{} priority:TaskPriorityNormal];
    if (self) {
        _running = NO;
    }
    return self;
}

- (instancetype)initWithFileDownloadItem:(FileDownloadItem *)item
                                priority:(TaskPriority)priority
                           callBackQueue:(dispatch_queue_t)callBackQueue {
    return [self initWithFileDownloadItem:item
                                 priority:priority
                        timeOutForRequest:30
                            callBackQueue:callBackQueue];
}

- (instancetype)initWithFileDownloadItem:(FileDownloadItem *)item
                                priority:(TaskPriority)priority
                       timeOutForRequest:(int)timeOut
                           callBackQueue:(dispatch_queue_t)callBackQueue {
    self = [super init];
    if (self) {
        _item = item;
        _downloadTask = [self downloadTaskFromUrl:item.url timeOutIntervalForRequest:timeOut];
        _callBackQueue = callBackQueue;
        
        __weak FileDownloadOperator *weakSelf = self;
        self.priority = priority;
        self.taskBlock = ^{
            if (weakSelf.downloadTask) {
                [weakSelf.downloadTask resume];
                weakSelf.running = YES;
            }
        };
    }
    return self;
}

#pragma mark - UpdateTaskBlock

- (void)updateTaskToPauseDownloadWithPriority:(TaskPriority)priority
                           completionHandler:(void (^)(NSString *url, NSError *error))completionHandler
                               callBackQueue:(dispatch_queue_t)callBackQueue {
    if (!completionHandler)
        return;
    
    __weak FileDownloadOperator *weakSelf = self;
    self.priority = priority;
    self.taskBlock = ^{
        if (weakSelf.downloadTask) {
            [weakSelf.downloadTask cancelByProducingResumeData:^(NSData *resumeData) {
                if (resumeData) {
                    [[DownloadDataCache instance] setData:resumeData forKey:weakSelf.item.url];
                    completionHandler(weakSelf.item.url, nil);
                } else {
                    NSError *error = [[NSError alloc] initWithDomain:@"FileDownloadOperator"
                                                                code:ERROR_GET_RESUME_DATA_FAILED
                                                            userInfo:@{@"Tạm dừng download thất bại!": NSLocalizedDescriptionKey}];
                    dispatch_async(callBackQueue, ^{
                        completionHandler(weakSelf.item.url, error);
                    });
                }
                weakSelf.running = NO;
            }];
        }
    };
}

- (void)updateTaskToResumeDownloadWithPriority:(TaskPriority)priority
                             completionHandler:(void (^)(NSString *url, NSError *error))completionHandler
                                 callBackQueue:(dispatch_queue_t)callBackQueue {
    if (!completionHandler)
        return;
    
    __weak FileDownloadOperator *weakSelf = self;
    NSData *resumeData = [[DownloadDataCache instance] dataForKey:self.item.url];
    
    self.downloadTask = [self downloadTaskFromResumeData:resumeData timeOutIntervalForRequest:30];
    self.priority = priority;
    self.taskBlock = ^{
        if (weakSelf.downloadTask) {
            [weakSelf.downloadTask resume];
            [[DownloadDataCache instance] removeDataByKey:weakSelf.item.url];
            weakSelf.running = YES;
            
            dispatch_async(callBackQueue, ^{
                completionHandler(weakSelf.item.url, nil);
            });
        } else {
            NSError *error = [[NSError alloc] initWithDomain:@"FileDownloadOperator"
                                                        code:ERROR_GET_RESUME_DATA_FAILED
                                                    userInfo:@{@"Không tìm thấy dữ liệu download": NSLocalizedDescriptionKey}];
            dispatch_async(callBackQueue, ^{
                completionHandler(weakSelf.item.url, error);
            });
        }
    };
}

- (void)updateTaskToCancelDownloadWithPriority:(TaskPriority)priority
                             completionHandler:(void (^)(NSString *url))completionHandler
                                 callBackQueue:(dispatch_queue_t)callBackQueue {
    if (!completionHandler)
        return;
    
    __weak FileDownloadOperator *weakSelf = self;
    self.priority = priority;
    self.taskBlock = ^{
        if (weakSelf.downloadTask) {
            [weakSelf.downloadTask cancel];
            weakSelf.running = NO;
            
            dispatch_async(callBackQueue, ^{
                completionHandler(weakSelf.item.url);
            });
        }
    };
}

- (void)updateTaskToReDownloadWithPriority:(TaskPriority)priority
                         timeOutForRequest:(int)timeOut
                         completionHandler:(void (^)(NSString *url, NSError *error))completionHandler
                             callBackQueue:(dispatch_queue_t)callBackQueue {
    if (!completionHandler)
        return;
    
    __weak FileDownloadOperator *weakSelf = self;
    self.priority = priority;
    self.taskBlock = ^{
        weakSelf.downloadTask = [weakSelf downloadTaskFromUrl:weakSelf.item.url
                                    timeOutIntervalForRequest:timeOut];
        [weakSelf.downloadTask resume];
        weakSelf.running = YES;
        
        dispatch_async(callBackQueue, ^{
            completionHandler(weakSelf.item.url, nil);
        });
    };
}

#pragma mark - GenerateDownloadTask

- (NSURLSessionDownloadTask *)downloadTaskFromUrl:(NSString *)url
                        timeOutIntervalForRequest:(int)timeOut {
    if (!url)
        return nil;
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:[NSString stringWithFormat:@"%@", self.item.url]];
    configuration.timeoutIntervalForRequest = timeOut;
    configuration.discretionary = YES;
    configuration.sessionSendsLaunchEvents = YES;
    
    _session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    NSURLSessionDownloadTask *downloadTask = [_session downloadTaskWithRequest:request];
    return downloadTask;
}

- (NSURLSessionDownloadTask *)downloadTaskFromResumeData:(NSData *)resumeData
                               timeOutIntervalForRequest:(int)timeOut {
    if (!resumeData)
        return nil;
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:[NSString stringWithFormat:@"%@", self.item.url]];
    configuration.timeoutIntervalForRequest = timeOut;
    configuration.discretionary = YES;
    configuration.sessionSendsLaunchEvents = YES;

    _session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    
    NSURLSessionDownloadTask *downloadTask = [_session downloadTaskWithResumeData:resumeData];
    return downloadTask;
}

#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
                                           didWriteData:(int64_t)bytesWritten
                                      totalBytesWritten:(int64_t)totalBytesWritten
                              totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    if (downloadTask == self.downloadTask && self.item && self.item.progressHandler) {
        dispatch_async(self.callBackQueue, ^{
            self.item.progressHandler(self.item.url, totalBytesWritten, totalBytesExpectedToWrite);
        });
    }
}

- (void)URLSession:(nonnull NSURLSession *)session downloadTask:(nonnull NSURLSessionDownloadTask *)downloadTask
                                      didFinishDownloadingToURL:(nonnull NSURL *)location {
    @try {
        NSFileManager *fileManager = NSFileManager.defaultManager;
        NSURL *documentsURL = [fileManager URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        NSURL *savedURL = [documentsURL URLByAppendingPathComponent:location.lastPathComponent];
        
        [fileManager moveItemAtURL:location toURL:savedURL error:nil];
    } @catch (NSError *error) {
        NSLog(@"Error: %@", error.userInfo);
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
                           didCompleteWithError:(NSError *)error {
    if (error)
        NSLog(@"URL Session error: %@", error.userInfo);
    
    if (task && self.item && self.item.completionHandler) {
        dispatch_async(self.callBackQueue, ^{
            self.item.completionHandler(self.item.url, @"", error);
        });
    }
}

#pragma mark - NSURLSessionDelegate

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    dispatch_async(dispatch_get_main_queue(), ^{
        AppDelegate *appDelegate =  (AppDelegate *)[UIApplication.sharedApplication delegate];
        if (appDelegate) {
            dispatch_block_t backgroundCompletionHandler = appDelegate.backgroundCompletionHandler;
            backgroundCompletionHandler();
        }
    });
}

@end
