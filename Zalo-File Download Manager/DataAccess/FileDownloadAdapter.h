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

- (void)downloadFiles:(NSArray<File *> *)files withProgressHandler:(NSArray<void (^)(float)> *)progressHandlers completionHandler:(NSArray<void (^)(NSError *error)> *) completionHandlers onDispatchQueue:(dispatch_queue_t)dispatchQueue;

@end

NS_ASSUME_NONNULL_END
