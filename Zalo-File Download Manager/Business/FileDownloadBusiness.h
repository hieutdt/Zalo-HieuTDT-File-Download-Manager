//
//  FileDownloadBusiness.h
//  Zalo-File Download Manager
//
//  Created by Trần Đình Tôn Hiếu on 3/27/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "File.h"

NS_ASSUME_NONNULL_BEGIN

@interface FileDownloadBusiness : NSObject

- (instancetype)initWithDownloadFilesCount:(int)count;

- (void)downloadMultiFiles:(NSArray<File *> *)files
      withProgressHandlers:(NSArray<void (^)(float, unsigned long)> *)progressHandlers
        completionHandlers:(NSArray<void (^)(NSError *, unsigned long)> *)completionHandlers;

- (void)pauseDownloadTaskAtIndex:(int)index withCompletionHandler:(void (^)(NSError *))completionHandler;

- (void)resumeDownloadTaskAtIndex:(int)index
              withProgressHandler:(void (^)(float, unsigned long))progressHandler
          downloadCompleteHandler:(void(^)(NSError *, unsigned long))downloadCompleteHandler
          resumeCompletionHandler:(void (^)(NSError *))completionHandler;

- (void)cancelDownloadTaskAtIndex:(int)index withCompletionHandler:(void (^)(NSError *))completionHandler;

- (void)retryDownloadFile:(File *)file atIndex:(int)index
      withProgressHandler:(void (^)(float, unsigned long))progressHandler
  downloadCompleteHandler:(void(^)(NSError *, unsigned long))completionHandler;

- (NSMutableArray<File *> *)getDownloadFiles;

@end

NS_ASSUME_NONNULL_END
