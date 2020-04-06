//
//  FileDownloadOperator.m
//  Zalo-File Download Manager
//
//  Created by Trần Đình Tôn Hiếu on 4/5/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "FileDownloadOperator.h"

@interface FileDownloadOperator () <NSURLSessionDownloadDelegate>

@property (nonatomic, assign) FileDownloadItem *item;
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;

@end

@implementation FileDownloadOperator

- (instancetype)init {
    self = [super initWithTaskBlock:^{} priority:TaskPriorityNormal];
    if (self) {
    }
    return self;
}

- (instancetype)initWithFileDownloadItem:(FileDownloadItem *)item
                                priority:(TaskPriority)priority {
    return [self initWithFileDownloadItem:item priority:priority timeOutForRequest:30];
}

- (instancetype)initWithFileDownloadItem:(FileDownloadItem *)item
                                priority:(TaskPriority)priority
                       timeOutForRequest:(int)timeOut {
    self = [super init];
    if (self) {
        _item = item;
        _downloadTask = [self downloadTaskFromUrl:item.url timeOutIntervalForRequest:timeOut];
        
        __weak FileDownloadOperator *weakSelf = self;
        self.priority = priority;
        self.taskBlock = ^{
            if (weakSelf.downloadTask) {
                [weakSelf.downloadTask resume];
            }
        };
    }
    return self;
}

- (NSURLSessionDownloadTask *)downloadTaskFromUrl:(NSString *)url
                        timeOutIntervalForRequest:(int)timeOut {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.timeoutIntervalForRequest = timeOut;
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithRequest:request];
    return downloadTask;
}

#pragma mark - NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    if (downloadTask == self.downloadTask && self.item && self.item.progressHandler) {
        self.item.progressHandler(self.item.url, bytesWritten, totalBytesWritten);
    }
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    if (downloadTask == self.downloadTask && self.item && self.item.completionHandler) {
        self.item.completionHandler(self.item.url, @"");
    }
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error && self.item && self.item.errorHandler) {
        self.item.errorHandler(self.item.url, error);
    }
}

@end
