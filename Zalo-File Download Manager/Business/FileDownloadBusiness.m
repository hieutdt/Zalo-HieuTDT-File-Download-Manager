//
//  FileDownloadBusiness.m
//  Zalo-File Download Manager
//
//  Created by Trần Đình Tôn Hiếu on 3/27/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "FileDownloadBusiness.h"
#import "FileDownloadAdapter.h"

@interface FileDownloadBusiness ()

@property (nonatomic, strong) dispatch_queue_t serialQueue;
@property (nonatomic, strong) NSMutableArray<File *> *downloadFiles;
@property (nonatomic, strong) NSMutableArray<NSURLSessionDownloadTask *> *downloadTasks;

@end

@implementation FileDownloadBusiness

- (instancetype)init {
    self = [self initWithDownloadFilesCount:5];
    return self;
}

- (instancetype)initWithDownloadFilesCount:(int)count {
    self = [super init];
    if (self) {
        _serialQueue = dispatch_queue_create("FileDownloadBusinessSerialQueue", DISPATCH_QUEUE_SERIAL);
        _downloadTasks = [[NSMutableArray alloc] init];
        _downloadFiles = [[NSMutableArray alloc] init];
        for (unsigned long i = 0; i < count; i++) {
            File *file = [[File alloc] initWithName:[NSString stringWithFormat:@"File %lu", i] url:@"http://ipv4.download.thinkbroadband.com/5MB.zip"];
            [_downloadFiles addObject:file];
        }
    }
    return self;
}

- (NSMutableArray<File *> *)getDownloadFiles {
    return self.downloadFiles;
}

- (void)downloadMultiFiles:(NSArray<File *> *)files withProgressHandlers:(NSArray<void (^)(float, unsigned long)> *)progressHandlers completionHandlers:(NSArray<void (^)(NSError *, unsigned long)> *)completionHandlers {
    
    if (!files || !completionHandlers || !progressHandlers) {
        return;
    }
    
    dispatch_async(self.serialQueue, ^{
        for (int i = 0; i < files.count; i++) {
            [self.downloadTasks addObject:[self downloadTaskByFile:files[i]]];
        }
        
        [[FileDownloadAdapter instance] executeDownloadTasks:self.downloadTasks withProgressHandler:^(float progress, NSURLSessionDownloadTask *task) {
            unsigned long index = [self.downloadTasks indexOfObject:task];
            
            if (index < progressHandlers.count) {
                if (progress > files[index].progress)
                    progressHandlers[index](progress, index);
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
                completionHandler(nil);
            }
        } onDispatchQueue:self.serialQueue];
    });
}

- (NSURLSessionDownloadTask *)downloadTaskByFile:(File *)file {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.timeoutIntervalForRequest = 30.0;
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:[FileDownloadAdapter instance] delegateQueue:nil];
    NSURL *url = [NSURL URLWithString:file.url];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithRequest:request];
    
    return downloadTask;
}

@end
