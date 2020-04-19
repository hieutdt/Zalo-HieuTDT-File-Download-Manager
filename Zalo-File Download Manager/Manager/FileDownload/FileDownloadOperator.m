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
#import "URLDownloadCache.h"

@interface FileDownloadOperator () <NSURLSessionDownloadDelegate, NSURLSessionDelegate>

@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) dispatch_queue_t callBackQueue;

@end

@implementation FileDownloadOperator

- (instancetype)init {
    self = [super initWithTaskBlock:^{} priority:TaskPriorityNormal];
    if (self) {
    }
    return self;
}

- (instancetype)initWithFileDownloadItem:(FileDownloadItem *)item
                                priority:(TaskPriority)priority
                           callBackQueue:(dispatch_queue_t)callBackQueue {
    return [self initWithFileDownloadItem:item
                                 priority:priority
                        timeOutForRequest:30
                       timeOutForResource:86400
                            callBackQueue:callBackQueue];
}

- (instancetype)initWithFileDownloadItem:(FileDownloadItem *)item
                                priority:(TaskPriority)priority
                       timeOutForRequest:(int)timeOutForRequest
                      timeOutForResource:(int)timeOutForResource
                           callBackQueue:(dispatch_queue_t)callBackQueue {
    self = [super init];
    if (self) {
        _item = item;
        if (item) {
            _downloadTask = [self downloadTaskFromUrl:item.url
                            timeOutIntervalForRequest:timeOutForRequest
                                   timeOutForResource:timeOutForResource];
        } else {
            _downloadTask = nil;
        }
        _callBackQueue = callBackQueue;
        
        __weak FileDownloadOperator *weakSelf = self;
        self.priority = priority;
        self.taskBlock = ^{
            // If this file has been downloaded
            if ([[URLDownloadCache instance] pathForUrl:weakSelf.item.url]) {
                NSLog(@"TONHIEU: %@", [[URLDownloadCache instance] pathForUrl:weakSelf.item.url]);
                
                for (int i = 0; i < weakSelf.item.completionHandlers.count; i++) {
                    weakSelf.item.completionHandlers[i](weakSelf.item.url, [[URLDownloadCache instance] pathForUrl:weakSelf.item.url], nil);
                }
                
                [weakSelf removeAllProgressHandlers];
                [weakSelf removeAllCompletionHandlers];
                [weakSelf finish];
                return;
            }
            
            if (weakSelf.downloadTask) {
                [weakSelf.downloadTask resume];
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
            }];
        }
    };
}

- (void)updateTaskToResumeDownloadWithPriority:(TaskPriority)priority
                             timeOutForRequest:(int)timeOutForRequest
                            timeOutForResource:(int)timeOutForResource
                             completionHandler:(void (^)(NSString *url, NSError *error))completionHandler
                                 callBackQueue:(dispatch_queue_t)callBackQueue {
    if (!completionHandler)
        return;
    
    __weak FileDownloadOperator *weakSelf = self;
    NSData *resumeData = [[DownloadDataCache instance] dataForKey:self.item.url];
    
    self.downloadTask = [self downloadTaskFromResumeData:resumeData
                               timeOutIntervalForRequest:timeOutForRequest
                                      timeOutForResource:timeOutForResource];
    self.priority = priority;
    self.taskBlock = ^{
        if (weakSelf.downloadTask) {
            [weakSelf.downloadTask resume];
            [[DownloadDataCache instance] removeDataByKey:weakSelf.item.url];
            
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
            
            dispatch_async(callBackQueue, ^{
                completionHandler(weakSelf.item.url);
            });
        }
    };
}

- (void)updateTaskToReDownloadWithPriority:(TaskPriority)priority
                         timeOutForRequest:(int)timeOutForRequest
                        timeOutForResoucre:(int)timeOutForResource
                         completionHandler:(void (^)(NSString *url, NSError *error))completionHandler
                             callBackQueue:(dispatch_queue_t)callBackQueue {
    if (!completionHandler)
        return;
    
    __weak FileDownloadOperator *weakSelf = self;
    self.priority = priority;
    self.taskBlock = ^{
        weakSelf.downloadTask = [weakSelf downloadTaskFromUrl:weakSelf.item.url
                                    timeOutIntervalForRequest:timeOutForRequest
                                           timeOutForResource:timeOutForResource];
        [weakSelf.downloadTask resume];
        
        dispatch_async(callBackQueue, ^{
            completionHandler(weakSelf.item.url, nil);
        });
    };
}


#pragma mark - GenerateDownloadTask

- (NSURLSessionDownloadTask *)downloadTaskFromUrl:(NSString *)url
                        timeOutIntervalForRequest:(int)timeOutForRequest
                               timeOutForResource:(int)timeOutForResource {
    if (!url)
        return nil;
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:[NSString stringWithFormat:@"%@", self.item.url]];
    configuration.timeoutIntervalForRequest = timeOutForRequest;
    configuration.timeoutIntervalForResource = timeOutForResource;
    configuration.discretionary = YES;
    configuration.sessionSendsLaunchEvents = YES;
    
    _session = [NSURLSession sessionWithConfiguration:configuration
                                             delegate:self
                                        delegateQueue:nil];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    NSURLSessionDownloadTask *downloadTask = [_session downloadTaskWithRequest:request];
    return downloadTask;
}

- (NSURLSessionDownloadTask *)downloadTaskFromResumeData:(NSData *)resumeData
                               timeOutIntervalForRequest:(int)timeOutForRequest
                                      timeOutForResource:(int)timeOutForResource {
    if (!resumeData)
        return nil;
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:[NSString stringWithFormat:@"%@", self.item.url]];
    configuration.timeoutIntervalForRequest = timeOutForRequest;
    configuration.timeoutIntervalForResource = timeOutForResource;
    configuration.discretionary = YES;
    configuration.sessionSendsLaunchEvents = YES;

    _session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    
    NSURLSessionDownloadTask *downloadTask = [_session downloadTaskWithResumeData:resumeData];
    return downloadTask;
}


#pragma mark - UpdateHandlers

- (void)addProgressHandler:(void (^)(NSString *url, long long bytesWritten, long long totalBytes))progressHandler {
    if (self.item && self.item.progressHandlers) {
        [self.item.progressHandlers addObject:progressHandler];
    }
}

- (void)addCompletionHandler:(void (^)(NSString *url, NSString *locationPath, NSError *error))completionHandler {
    if (self.item && self.item.completionHandlers) {
        [self.item.completionHandlers addObject:completionHandler];
    }
}

- (void)removeAllProgressHandlers {
    if (self.item && self.item.progressHandlers) {
        [self.item.progressHandlers removeAllObjects];
    }
}

- (void)removeAllCompletionHandlers {
    if (self.item && self.item.completionHandlers) {
        [self.item.completionHandlers removeAllObjects];
    }
}


#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
                                           didWriteData:(int64_t)bytesWritten
                                      totalBytesWritten:(int64_t)totalBytesWritten
                              totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    if (downloadTask == self.downloadTask && self.item && self.item.progressHandlers) {
        dispatch_async(self.callBackQueue, ^{
            for (int i = 0; i < self.item.progressHandlers.count; i++) {
                self.item.progressHandlers[i](self.item.url, totalBytesWritten, totalBytesExpectedToWrite);
            }
        });
    }
}

- (void)URLSession:(nonnull NSURLSession *)session downloadTask:(nonnull NSURLSessionDownloadTask *)downloadTask
                                      didFinishDownloadingToURL:(nonnull NSURL *)location {
    @try {
        NSFileManager *fileManager = NSFileManager.defaultManager;
        NSURL *documentsURL = [fileManager URLForDirectory:NSDocumentDirectory
                                                  inDomain:NSUserDomainMask
                                         appropriateForURL:nil
                                                    create:NO
                                                     error:nil];
        NSURL *savedURL = [documentsURL URLByAppendingPathComponent:location.lastPathComponent];
        
        [fileManager moveItemAtURL:location toURL:savedURL error:nil];
        
        // Cache this location path
        [[URLDownloadCache instance] setLocationPath:[savedURL absoluteString]
                                              forUrl:self.item.url];
        
    } @catch (NSError *error) {
        NSLog(@"Error: %@", error.userInfo);
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
                           didCompleteWithError:(NSError *)error {
    if (error)
        NSLog(@"URL Session error: %@", error.userInfo);
    
    if (task && self.item && self.item.completionHandlers) {
        dispatch_async(self.callBackQueue, ^{
            for (int i = 0; i < self.item.completionHandlers.count; i++) {
                self.item.completionHandlers[i](self.item.url, @"", error);
            }
            
            [self removeAllProgressHandlers];
            [self removeAllCompletionHandlers];
            
            [self finish];
        });
    }
}

#pragma mark - NSURLSessionDelegate

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    dispatch_async(dispatch_get_main_queue(), ^{
        AppDelegate *appDelegate =  (AppDelegate *)[UIApplication.sharedApplication delegate];
        if (appDelegate) {
            dispatch_block_t backgroundCompletionHandler = appDelegate.backgroundCompletionHandler;
            if (backgroundCompletionHandler) {
                backgroundCompletionHandler();
            }
        }
    });
}

@end
