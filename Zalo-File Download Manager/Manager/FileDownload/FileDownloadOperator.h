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

@property (nonatomic, assign, getter=isRunning) BOOL running;

#pragma mark - InitMethods

- (instancetype)initWithFileDownloadItem:(FileDownloadItem *)item
                                priority:(TaskPriority)priority
                           callBackQueue:(dispatch_queue_t)callBackQueue;

- (instancetype)initWithFileDownloadItem:(FileDownloadItem *)item
                                priority:(TaskPriority)priority
                       timeOutForRequest:(int)timeOutForRequest
                      timeOutForResource:(int)timeOutForResource
                           callBackQueue:(dispatch_queue_t)callBackQueue;


#pragma mark - UpdateTaskBlockMethods

- (void)updateTaskToPauseDownloadWithPriority:(TaskPriority)priority
                           completionHandler:(void (^)(NSString *url, NSError *error))completionHandler
                               callBackQueue:(dispatch_queue_t)callBackQueue;

- (void)updateTaskToResumeDownloadWithPriority:(TaskPriority)priority
                             timeOutForRequest:(int)timeOutForRequest
                            timeOutForResource:(int)timeOutForResource
                             completionHandler:(void (^)(NSString *url, NSError *error))completionHandler
                                 callBackQueue:(dispatch_queue_t)callBackQueue;

- (void)updateTaskToCancelDownloadWithPriority:(TaskPriority)priority
                     completionHandler:(void (^)(NSString *url))completionHandler
                         callBackQueue:(dispatch_queue_t)callBackQueue;

- (void)updateTaskToReDownloadWithPriority:(TaskPriority)priority
                         timeOutForRequest:(int)timeOutForRequest
                        timeOutForResoucre:(int)timeOutForResource
                         completionHandler:(void (^)(NSString *url, NSError *error))completionHandler
                             callBackQueue:(dispatch_queue_t)callBackQueue;

@end

NS_ASSUME_NONNULL_END
