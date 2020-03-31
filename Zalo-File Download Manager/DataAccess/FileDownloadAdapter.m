//
//  FileDownloadAdapter.m
//  Zalo-File Download Manager
//
//  Created by Trần Đình Tôn Hiếu on 3/27/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "FileDownloadAdapter.h"

@interface FileDownloadAdapter () <NSURLSessionDownloadDelegate>

@property (nonatomic, strong) dispatch_queue_t serialQueue;
@property (nonatomic, strong) NSMutableArray<void (^)(float, unsigned long)> *progressHandlers;
@property (nonatomic, strong) NSMutableArray<void (^)(NSError *, unsigned long)> *completionHandlers;
@property (nonatomic, strong) NSMutableArray<NSURLSessionDownloadTask *> *downloadTasks;
@property (nonatomic, strong) dispatch_queue_t callbackQueue;

@end

@implementation FileDownloadAdapter

- (instancetype)init {
    self = [super init];
    if (self) {
        _serialQueue = dispatch_queue_create("FileDownLoadAdapterSerialQueue", DISPATCH_QUEUE_SERIAL);
        _downloadTasks = [[NSMutableArray alloc] init];
        _progressHandlers = [[NSMutableArray alloc] init];
        _completionHandlers = [[NSMutableArray alloc] init];
    }
    return self;
}

+ (instancetype)instance {
    static FileDownloadAdapter *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[FileDownloadAdapter alloc] init];
    });
    
    return sharedInstance;
}

- (void)downloadFiles:(NSArray<File *> *)files
  withProgressHandler:(NSArray<void (^)(float, unsigned long)> *)progressHandlers
    completionHandler:(NSArray<void (^)(NSError *error, unsigned long)> *) completionHandlers
      onDispatchQueue:(dispatch_queue_t)dispatchQueue {
    if (!files || !completionHandlers) {
        return;
    }
    
    dispatch_async(self.serialQueue, ^{
        if (progressHandlers)
            self.progressHandlers = [NSMutableArray arrayWithArray:progressHandlers];
        
        if (completionHandlers)
            self.completionHandlers = [NSMutableArray arrayWithArray:completionHandlers];
        
        self.callbackQueue = dispatchQueue;
        
        for (int i = 0; i < files.count; i++) {
            NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
            configuration.timeoutIntervalForRequest = 30.0;
            
            NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
            NSURL *url = [NSURL URLWithString:files[i].url];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            
            NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithRequest:request];
            [self.downloadTasks addObject:downloadTask];
            [downloadTask resume];
        }
    });
}

- (void)stopDownloadTaskAtIndex:(int)index
          withCompletionHandler:(void (^)(NSError *error, NSData * resumeData))completionHandler
                onDispatchQueue:(dispatch_queue_t)dispatchQueue {
    if (!completionHandler) {
        return;
    }
    
    if (index >= self.downloadTasks.count) {
        return;
    }
    
    dispatch_async(self.serialQueue, ^{
        NSURLSessionDownloadTask *downloadTask = self.downloadTasks[index];
        
        [downloadTask cancelByProducingResumeData:^(NSData *resumeData) {
            if (resumeData) {
                dispatch_async(dispatchQueue, ^{
                    completionHandler(nil, resumeData);
                });
            } else {
                dispatch_async(dispatchQueue, ^{
                    NSError *error = [[NSError alloc] initWithDomain:@"FileDownloadAdapter" code:ERROR_GET_RESUME_DATA_FAILED userInfo:@{@"Tạm dừng download thất bại!": NSLocalizedDescriptionKey}];
                    completionHandler(error, resumeData);
                });
            }
        }];
    });
}

- (void)resumeDownloadTaskAtIndex:(int)index
            withCompletionHandler:(void (^)(NSError * _Nonnull))completionHandler
                  onDispatchQueue:(dispatch_queue_t)dispatchQueue {
    if (!completionHandler) {
        return;
    }
    
    if (index >= self.downloadTasks.count) {
        return;
    }
    
    dispatch_async(self.serialQueue, ^{
        NSURLSessionDownloadTask *downloadTask = self.downloadTasks[index];
        
        
    });
}


#pragma mark - NSURLSessionDownloadDelegateProtocol

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    @synchronized (self) {
        unsigned long taskIndex = [self.downloadTasks indexOfObject:downloadTask];
        float progress = (float)totalBytesWritten / totalBytesExpectedToWrite;
        progress = (int)(progress * 40);
        progress /= 40.0;
        
        if (taskIndex < self.progressHandlers.count) {
            dispatch_async(self.callbackQueue, ^{
                self.progressHandlers[taskIndex](progress, taskIndex);
            });
        }
    }
}

- (void)URLSession:(nonnull NSURLSession *)session downloadTask:(nonnull NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(nonnull NSURL *)location {
    @synchronized (self) {
        unsigned long taskIndex = [self.downloadTasks indexOfObject:downloadTask];
        
        NSLog(@"Task complete! %lu", taskIndex);
        
        if (taskIndex < self.completionHandlers.count) {
            dispatch_async(self.callbackQueue, ^{
                self.completionHandlers[taskIndex](nil, taskIndex);
                
//                [self.completionHandlers removeObjectAtIndex:taskIndex];
//                [self.progressHandlers removeObjectAtIndex:taskIndex];
            });
        }
    }
}


@end
