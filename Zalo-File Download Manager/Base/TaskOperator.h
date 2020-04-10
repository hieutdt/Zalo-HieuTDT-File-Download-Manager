//
//  TaskOperator.h
//  Zalo-File Download Manager
//
//  Created by Trần Đình Tôn Hiếu on 4/4/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppConsts.h"

NS_ASSUME_NONNULL_BEGIN

@class TaskOperator;

@protocol TaskOperatorDelegate <NSObject>

- (void)taskOperatorDidFinish:(TaskOperator *)taskOperator;

@end

@interface TaskOperator : NSObject

@property (nonatomic, strong) id<TaskOperatorDelegate> delegate;
@property (nonatomic, strong) dispatch_block_t taskBlock;
@property (nonatomic, assign) TaskPriority priority;

- (void)execute;

- (instancetype)initWithTaskBlock:(dispatch_block_t)block priority:(TaskPriority)priority;

- (void)finish;

@end

NS_ASSUME_NONNULL_END
