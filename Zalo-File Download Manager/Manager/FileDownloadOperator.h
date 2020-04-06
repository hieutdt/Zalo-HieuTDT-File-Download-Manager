//
//  FileDownloadOperator.h
//  Zalo-File Download Manager
//
//  Created by Trần Đình Tôn Hiếu on 4/5/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TaskOperator.h"
#import "FileDownloadItem.h"
#import "AppConsts.h"

NS_ASSUME_NONNULL_BEGIN

@interface FileDownloadOperator : TaskOperator

- (instancetype)initWithFileDownloadItem:(FileDownloadItem *)item
                                priority:(TaskPriority)priority;

- (instancetype)initWithFileDownloadItem:(FileDownloadItem *)item
                                priority:(TaskPriority)priority
                       timeOutForRequest:(int)timeOut;

@end

NS_ASSUME_NONNULL_END
