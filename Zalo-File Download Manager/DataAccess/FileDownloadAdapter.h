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

@interface FileDownloadAdapter : NSObject

+ (instancetype)instance;

- (void)downloadFiles:(NSArray<File *> *)files
  withProgressHandler:(NSArray<void (^)(float, unsigned long)> *)progressHandlers
    completionHandler:(NSArray<void (^)(NSError *error, unsigned long)> *) completionHandlers
      onDispatchQueue:(dispatch_queue_t)dispatchQueue;

- (void)stopDownloadTaskAtIndex:(int)index
          withCompletionHandler:(void (^)(NSError *error, NSData *resumeData))completionHandler
                onDispatchQueue:(dispatch_queue_t)dispatchQueue;

- (void)resumeDownloadTaskAtIndex:(int)index
            withCompletionHandler:(void (^)(NSError *))completionHandler
                  onDispatchQueue:(dispatch_queue_t)dispatchQueue;


@end

NS_ASSUME_NONNULL_END
