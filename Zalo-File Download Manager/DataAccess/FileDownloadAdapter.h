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

- (void)executeDownloadTasks:(NSArray<NSURLSessionDownloadTask *> *)downloadTasks withProgressHandler:(void (^)(float, NSURLSessionDownloadTask *))progressHandler completionHandler:(void (^)(NSError *, NSURLSessionDownloadTask *))completionHandler onDispatchQueue:(dispatch_queue_t)dispatchQueue;

- (void)pauseDownloadTask:(NSURLSessionDownloadTask *)downloadTask withCompletionHandler:(void (^)(NSError *error, NSData *resumeData))completionHandler onDispatchQueue:(dispatch_queue_t)dispatchQueue;

- (void)resumeDownloadTask:(NSURLSessionDownloadTask *)downloadTask withResumeData:(NSData *)resumeData completionHandler:(void (^)(NSError *error))completionHandler onDispatchQueue:(dispatch_queue_t)dispatchQueue;

@end

NS_ASSUME_NONNULL_END
