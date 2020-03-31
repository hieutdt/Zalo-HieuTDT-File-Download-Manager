//
//  FileDownloadAdapter.m
//  Zalo-File Download Manager
//
//  Created by Trần Đình Tôn Hiếu on 3/27/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "FileDownloadAdapter.h"

@interface FileDownloadAdapter ()

@property (nonatomic, strong) dispatch_queue_t serialQueue;

@property (nonatomic, strong) NSMutableArray<NSURLSessionDownloadTask *> *downloadTasks;
@property (nonatomic, strong) NSMutableDictionary<NSURLSessionDownloadTask *, dispatch_queue_t> *taskQueueDictionary;

@property (nonatomic, strong) NSMutableArray<dispatch_queue_t> *dispatchQueues;
@property (nonatomic, strong) NSMutableArray<void (^)(float, NSURLSessionDownloadTask *)> *progressHandlers;
@property (nonatomic, strong) NSMutableArray<void (^)(NSError *, NSURLSessionDownloadTask *)> *completionHandlers;

@end

@implementation FileDownloadAdapter

- (instancetype)init {
    self = [super init];
    if (self) {
        _serialQueue = dispatch_queue_create("FileDownLoadAdapterSerialQueue", DISPATCH_QUEUE_SERIAL);
        _downloadTasks = [[NSMutableArray alloc] init];
        _progressHandlers = [[NSMutableArray alloc] init];
        _completionHandlers = [[NSMutableArray alloc] init];
        _dispatchQueues = [[NSMutableArray alloc] init];
        _taskQueueDictionary = [[NSMutableDictionary alloc] init];
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

- (void)executeDownloadTasks:(NSArray<NSURLSessionDownloadTask *> *)downloadTasks withProgressHandler:(void (^)(float, NSURLSessionDownloadTask *))progressHandler completionHandler:(void (^)(NSError *, NSURLSessionDownloadTask *))completionHandler onDispatchQueue:(dispatch_queue_t)dispatchQueue {
    dispatch_async(self.serialQueue, ^{
        [self.dispatchQueues addObject:dispatchQueue];
        [self.progressHandlers addObject:progressHandler];
        [self.completionHandlers addObject:completionHandler];
        
        for (int i = 0; i < downloadTasks.count; i++) {
            [self.downloadTasks addObject:downloadTasks[i]];
            [self.taskQueueDictionary addEntriesFromDictionary:@{downloadTasks[i] : dispatchQueue}];
            
            // Execute task
            [downloadTasks[i] resume];
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

- (void)resumeDownloadTaskAtIndex:(int)index withCompletionHandler:(void (^)(NSError *))completionHandler onDispatchQueue:(dispatch_queue_t)dispatchQueue {
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
        dispatch_queue_t queue = [self.taskQueueDictionary objectForKey:downloadTask];
        // This index is index use in queues, progressHandlers and completionHandlers;
        unsigned long index = [self.dispatchQueues indexOfObject:queue];
        
        float progress = (float)totalBytesWritten / totalBytesExpectedToWrite;
        progress = (int)(progress * 40);
        progress /= 40.0;
        
        if (index < self.progressHandlers.count) {
            dispatch_async(queue, ^{
                self.progressHandlers[index](progress, downloadTask);
            });
        }
    }
}

- (void)URLSession:(nonnull NSURLSession *)session downloadTask:(nonnull NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(nonnull NSURL *)location {
    @synchronized (self) {
        dispatch_queue_t queue = [self.taskQueueDictionary objectForKey:downloadTask];
        unsigned long index = [self.dispatchQueues indexOfObject:queue];
        
        if (index < self.completionHandlers.count) {
            dispatch_async(queue, ^{
                self.completionHandlers[index](nil, downloadTask);
                
//                [self.completionHandlers removeObjectAtIndex:index];
//                [self.progressHandlers removeObjectAtIndex:index];
            });
        }
    }
}


@end
