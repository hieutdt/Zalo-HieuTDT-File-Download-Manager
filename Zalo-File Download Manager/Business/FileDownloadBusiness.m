//
//  FileDownloadBusiness.m
//  Zalo-File Download Manager
//
//  Created by Trần Đình Tôn Hiếu on 3/27/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "FileDownloadBusiness.h"
#import "FileDownloadAdapter.h"
#import "DownloadDataCache.h"

@interface FileDownloadBusiness ()

@property (nonatomic, strong) dispatch_queue_t serialQueue;
@property (nonatomic, strong) NSMutableArray<NSURLSessionDownloadTask *> *downloadTasks;

@end

@implementation FileDownloadBusiness

- (instancetype)init
{
    self = [super init];
    if (self) {
        _serialQueue = dispatch_queue_create("FileDownloadBusinessSerialQueue", DISPATCH_QUEUE_SERIAL);
        _downloadTasks = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)downloadMultiFiles:(NSArray<File *> *)files
      withProgressHandlers:(NSArray<void (^)(unsigned long, long long, long long)> *)progressHandlers
        completionHandlers:(NSArray<void (^)(NSError *, unsigned long)> *)completionHandlers {
    
    if (!files || !completionHandlers || !progressHandlers) {
        return;
    }
    
    dispatch_async(self.serialQueue, ^{
        for (int i = 0; i < files.count; i++) {
            [self.downloadTasks addObject:[self downloadTaskByFile:files[i]]];
        }
        
        [[FileDownloadAdapter instance] executeDownloadTasks:self.downloadTasks withProgressHandler:^(NSURLSessionDownloadTask *task, long long bytesWritten, long long totalBytes) {
            unsigned long index = [self.downloadTasks indexOfObject:task];
            
            if (index < progressHandlers.count) {
                    progressHandlers[index](index, bytesWritten, totalBytes);
            }
        } completionHandler:^(NSError *error, NSURLSessionDownloadTask *task) {
            unsigned long index = [self.downloadTasks indexOfObject:task];
            
            if (index < completionHandlers.count) {
                completionHandlers[index](error, index);
            }
        } onDispatchQueue:self.serialQueue];
    });
}

- (void)pauseDownloadTaskAtIndex:(int)index withCompletionHandler:(void (^)(NSError *))completionHandler {
    if (!completionHandler)
        return;
    
    if (index >= self.downloadTasks.count)
        return;
    
    dispatch_async(self.serialQueue, ^{
        NSURLSessionDownloadTask *downloadTask = self.downloadTasks[index];
        
        [[FileDownloadAdapter instance] pauseDownloadTask:downloadTask withCompletionHandler:^(NSError *error, NSData *resumeData) {
            if (error) {
                completionHandler(error);
            } else {
                [[DownloadDataCache instance] setData:resumeData forDownloadTask:downloadTask];
                completionHandler(nil);
            }
        } onDispatchQueue:self.serialQueue];
    });
}

- (void)resumeDownloadTaskAtIndex:(int)index
              withProgressHandler:(void (^)(unsigned long, long long, long long))progressHandler
          downloadCompleteHandler:(void (^)(NSError *, unsigned long))downloadCompleteHandler
          resumeCompletionHandler:(void (^)(NSError *))completionHandler {
    if (!completionHandler)
            return;
        
    if (index >= self.downloadTasks.count)
        return;
    
    dispatch_async(self.serialQueue, ^{
        NSURLSessionDownloadTask *oldDownloadTask = self.downloadTasks[index];
        NSData *resumeData = [[DownloadDataCache instance] dataForDownloadTask:oldDownloadTask];
        
        if (!resumeData || !self.downloadTasks[index]) {
            NSError *error = [[NSError alloc] initWithDomain:@"FileDownloadBusiness" code:ERROR_GET_RESUME_DATA_FAILED userInfo:@{@"Tiếp tục download thất bại!": NSLocalizedDescriptionKey}];
            completionHandler(error);
        } else {
            self.downloadTasks[index] = [self downloadTaskByResumeData:resumeData];
            [[FileDownloadAdapter instance] executeDownloadTask:self.downloadTasks[index] withProgressHandler:^(NSURLSessionDownloadTask *downloadTask, long long bytesWritten, long long totalBytes) {
                progressHandler(index, bytesWritten, totalBytes);
                
            } completionHandler:^(NSError *error, NSURLSessionDownloadTask *downloadTask) {
                downloadCompleteHandler(error, index);
                [[DownloadDataCache instance] removeDataForDownloadTask:oldDownloadTask];
                
            } onDispatchQueue:self.serialQueue];
            
            completionHandler(nil);
        }
    });
}

- (void)cancelDownloadTaskAtIndex:(int)index withCompletionHandler:(void (^)(NSError *))completionHandler {
    if (!completionHandler)
        return;
    
    if (index >= self.downloadTasks.count)
        return;
    
    dispatch_async(self.serialQueue, ^{
        NSURLSessionDownloadTask *downloadTask = self.downloadTasks[index];
        if (!downloadTask) {
            NSError *error = [[NSError alloc] initWithDomain:@"FileDownloadBusiness" code:ERROR_GET_RESUME_DATA_FAILED userInfo:@{@"Tiếp tục download thất bại!": NSLocalizedDescriptionKey}];
            completionHandler(error);
        } else {
            [[FileDownloadAdapter instance] cancelDownloadTask:downloadTask withCompletionHandler:^{
                completionHandler(nil);
            } onDispatchQueue:self.serialQueue];
        }
    });
}

- (void)retryDownloadFile:(File *)file atIndex:(int)index
      withProgressHandler:(void (^)(unsigned long, long long, long long))progressHandler
  downloadCompleteHandler:(void (^)(NSError *, unsigned long))completionHandler {
    if (!completionHandler)
            return;
        
    if (index >= self.downloadTasks.count)
        return;
    
    dispatch_async(self.serialQueue, ^{
        self.downloadTasks[index] = [self downloadTaskByFile:file];
        
        if (!self.downloadTasks[index]) {
            NSError *error = [[NSError alloc] initWithDomain:@"FileDownloadBusiness" code:ERROR_GET_RESUME_DATA_FAILED userInfo:@{@"Download thất bại!": NSLocalizedDescriptionKey}];
            completionHandler(error, index);
        } else {
            [[FileDownloadAdapter instance] executeDownloadTask:self.downloadTasks[index] withProgressHandler:^(NSURLSessionDownloadTask *downloadTask, long long bytesWritten, long long totalBytes) {
                progressHandler(index, bytesWritten, totalBytes);
                
            } completionHandler:^(NSError *error, NSURLSessionDownloadTask *downloadTask) {
                completionHandler(error, index);
                
            } onDispatchQueue:self.serialQueue];
        }
    });
}


#pragma mark - GenerateDownloadTask

- (NSURLSessionDownloadTask *)downloadTaskByFile:(File *)file {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.timeoutIntervalForRequest = 30.0;
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:[FileDownloadAdapter instance] delegateQueue:nil];
    NSURL *url = [NSURL URLWithString:file.url];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithRequest:request];
    
    return downloadTask;
}

- (NSURLSessionDownloadTask *)downloadTaskByResumeData:(NSData *)resumeData {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.timeoutIntervalForRequest = 30.0;
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:[FileDownloadAdapter instance] delegateQueue:nil];
    
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithResumeData:resumeData];
    return downloadTask;
}

@end
