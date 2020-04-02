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

- (void)executeDownloadTask:(NSURLSessionDownloadTask *)downloadTask
        withProgressHandler:(void (^)(float, NSURLSessionDownloadTask *))progressHandler
          completionHandler:(void (^)(NSError *, NSURLSessionDownloadTask *))completionHandler
            onDispatchQueue:(dispatch_queue_t)dispatchQueue;


- (void)executeDownloadTasks:(NSArray<NSURLSessionDownloadTask *> *)downloadTasks
         withProgressHandler:(void (^)(float, NSURLSessionDownloadTask *))progressHandler
           completionHandler:(void (^)(NSError *, NSURLSessionDownloadTask *))completionHandler
             onDispatchQueue:(dispatch_queue_t)dispatchQueue;

- (void)pauseDownloadTask:(NSURLSessionDownloadTask *)downloadTask
    withCompletionHandler:(void (^)(NSError *error, NSData *resumeData))completionHandler
          onDispatchQueue:(dispatch_queue_t)dispatchQueue;

- (void)cancelDownloadTask:(NSURLSessionDownloadTask *)downloadTask
     withCompletionHandler:(void (^)(void))completionHandler
           onDispatchQueue:(dispatch_queue_t)dispatchQueue;

@end

NS_ASSUME_NONNULL_END
