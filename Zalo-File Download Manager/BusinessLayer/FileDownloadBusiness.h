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

- (void)downloadMultiFiles:(NSArray<File *> *)files withProgressHandlers:(NSArray<void (^)(float)> *)progressHandlers completionHandlers:(NSArray<void (^)(NSError *)> *)completionHandlers;

@end

NS_ASSUME_NONNULL_END
