//
//  FileDownloadAdapter.h
//  Zalo-File Download Manager
//
//  Created by Trần Đình Tôn Hiếu on 3/27/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "File.h"

NS_ASSUME_NONNULL_BEGIN

@interface FileDownloadAdapter : NSObject <NSURLSessionDownloadDelegate>

+ (instancetype)instance;

/// Execute a download task
/// @param downloadTask downloadTask passed by Business.
/// @param progressHandler the function that will be called when Adapter has writted data to dictionary.
/// @param completionHandler the function that will be called when Adapter has finished download data.
/// @param dispatchQueue the dispatchQueue that ProgressHandler and CompletionHandler are called in.
- (void)executeDownloadTask:(NSURLSessionDownloadTask *)downloadTask
        withProgressHandler:(void (^)(NSURLSessionDownloadTask *, long long, long long))progressHandler
          completionHandler:(void (^)(NSError *, NSURLSessionDownloadTask *))completionHandler
            onDispatchQueue:(dispatch_queue_t)dispatchQueue;


/// Execute mutiple download processes at the same time
/// @param downloadTasks array of DownloadTasks.
/// @param progressHandler the function that will be called when Adapter has writted data to dictionary.
/// @param completionHandler the function that will be called when Adapter has finished download data.
/// @param dispatchQueue the dispatchQueue that ProgressHandler and CompletionHandler are called there.
- (void)executeDownloadTasks:(NSArray<NSURLSessionDownloadTask *> *)downloadTasks
         withProgressHandler:(void (^)(NSURLSessionDownloadTask *, long long, long long))progressHandler
           completionHandler:(void (^)(NSError *, NSURLSessionDownloadTask *))completionHandler
             onDispatchQueue:(dispatch_queue_t)dispatchQueue;


/// Pause a download task
/// @param downloadTask downloadTask is paused.
/// @param completionHandler the function will be called after pausing downloadTask.
/// @param dispatchQueue the dispatchQueue that completionHandler is called in.
- (void)pauseDownloadTask:(NSURLSessionDownloadTask *)downloadTask
    withCompletionHandler:(void (^)(NSError *error, NSData *resumeData))completionHandler
          onDispatchQueue:(dispatch_queue_t)dispatchQueue;


/// Cancel a download task
/// @param downloadTask downloadTask is canceled
/// @param completionHandler the function will be called after canceling downloadTask.
/// @param dispatchQueue the dispatchQueue that completionHandler is called in.
- (void)cancelDownloadTask:(NSURLSessionDownloadTask *)downloadTask
     withCompletionHandler:(void (^)(void))completionHandler
           onDispatchQueue:(dispatch_queue_t)dispatchQueue;

@end

NS_ASSUME_NONNULL_END
