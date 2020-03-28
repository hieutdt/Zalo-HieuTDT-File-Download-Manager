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
@property (nonatomic, strong) NSMutableArray<void (^)(float)> *progressHandlers;
@property (nonatomic, strong) NSMutableArray<NSURLSessionDownloadTask *> *downloadTasks;

@end

@implementation FileDownloadAdapter

- (instancetype)init {
    self = [super init];
    if (self) {
        _serialQueue = dispatch_queue_create("FileDownLoadAdapterSerialQueue", DISPATCH_QUEUE_SERIAL);
        _downloadTasks = [[NSMutableArray alloc] init];
        _progressHandlers = [[NSMutableArray alloc] init];
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

- (void)downloadFiles:(NSArray<File *> *)files withProgressHandler:(NSArray<void (^)(float)> *)progressHandlers completionHandler:(NSArray<void (^)(NSError *error)> *) completionHandlers onDispatchQueue:(dispatch_queue_t)dispatchQueue {
    if (!files || !completionHandlers) {
        return;
    }
    
    if (progressHandlers) {
        self.progressHandlers = [NSMutableArray arrayWithArray:progressHandlers];
    }
    
    dispatch_async(self.serialQueue, ^{
        dispatch_group_t dispatchGroup = dispatch_group_create();
        
        for (int i = 0; i < files.count; i++) {
            dispatch_group_enter(dispatchGroup);
            
            NSURLSession *session = [NSURLSession sharedSession];
            NSURL *url = [NSURL URLWithString:files[i].url];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            
            NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                dispatch_async(dispatchQueue, ^{
                    completionHandlers[i](error);
                    
                    dispatch_group_leave(dispatchGroup);
                });
            }];

            [self.downloadTasks addObject:downloadTask];
            [downloadTask resume];
        }
    });
}


#pragma mark - NSURLSessionDownloadDelegateProtocol

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    unsigned long taskIndex = [self.downloadTasks indexOfObject:downloadTask];
    float progress = (float)totalBytesWritten / totalBytesExpectedToWrite;
    
    if (taskIndex < self.progressHandlers.count) {
        self.progressHandlers[taskIndex](progress);
    }
}

- (void)URLSession:(nonnull NSURLSession *)session downloadTask:(nonnull NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(nonnull NSURL *)location {
    
}


@end
