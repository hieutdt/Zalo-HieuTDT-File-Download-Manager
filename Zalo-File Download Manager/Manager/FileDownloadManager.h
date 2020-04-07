//
//  FileDownloadManager.h
//  Zalo-File Download Manager
//
//  Created by Trần Đình Tôn Hiếu on 4/5/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TaskOperatorManager.h"
#import "AppConsts.h"
#import "FileDownloadItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface FileDownloadManager : TaskOperatorManager

+ (instancetype)instance;

- (void)performDownloadFileWithUrl:(NSString *)url
                          priority:(TaskPriority)priority
         timeOutIntervalForRequest:(int)timeOut
                   progressHandler:(void (^)(NSString *url, long long bytesWritten, long long totalBytes))progressHandler
                 completionHandler:(void (^)(NSString *url, NSString *locationPath, NSError *error))completionHandler;

- (void)pauseDownloadFileWithUrl:(NSString *)url
                        priority:(TaskPriority)priority
                sameUrlFilesLeft:(unsigned long)leftCount
               completionHandler:(void (^)(NSString *url, NSError *error))completionHandler;

@end

NS_ASSUME_NONNULL_END
