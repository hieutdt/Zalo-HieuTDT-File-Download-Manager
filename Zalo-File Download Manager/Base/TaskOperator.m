//
//  TaskOperator.m
//  Zalo-File Download Manager
//
//  Created by Trần Đình Tôn Hiếu on 4/4/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "TaskOperator.h"

@interface TaskOperator ()

@end

@implementation TaskOperator

- (instancetype)initWithTaskBlock:(dispatch_block_t)block priority:(TaskPriority)priority {
    self = [super init];
    if (self) {
        _taskBlock = block;
        _priority = priority;
    }
    return self;
}

- (void)execute {
    if (self.taskBlock) {
        self.taskBlock();
    }
}

- (void)finish {
    if (self.delegate && [self.delegate conformsToProtocol:@protocol(TaskOperatorDelegate)]) {
        [self.delegate taskOperatorDidFinish:self];
    }
}

@end
