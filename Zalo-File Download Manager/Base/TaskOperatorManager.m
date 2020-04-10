//
//  TaskOperatorManager.m
//  Zalo-File Download Manager
//
//  Created by Trần Đình Tôn Hiếu on 4/5/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "TaskOperatorManager.h"
#import "AppConsts.h"

@interface TaskOperatorManager () <TaskOperatorDelegate>

@property (nonatomic, strong) NSMutableArray<TaskOperator *> *highPriorityTasks;
@property (nonatomic, strong) NSMutableArray<TaskOperator *> *normalPriorityTasks;
@property (nonatomic, strong) NSMutableArray<TaskOperator *> *lowPriorityTasks;

@property (nonatomic, assign) int workingTaskCount;

@end

@implementation TaskOperatorManager

- (instancetype)init {
    self = [super init];
    if (self) {
        _highPriorityTasks = [[NSMutableArray alloc] init];
        _normalPriorityTasks = [[NSMutableArray alloc] init];
        _lowPriorityTasks = [[NSMutableArray alloc] init];
        _serialQueue = dispatch_queue_create("TaskOperatorManagerQueue", DISPATCH_QUEUE_SERIAL);
        _workingTaskCount = 0;
    }
    return self;
}

- (void)performTaskOperator:(TaskOperator *)taskOperator {
    if (!taskOperator)
        return;
    
    dispatch_async(self.serialQueue, ^{
        [self addTaskOperatorToQueue:taskOperator];
        taskOperator.delegate = self;
        
        if (self.workingTaskCount <= maxCurrentTask) {
            TaskOperator *task = [self nextTaskOperator];
            [task execute];
        }
    });
}

- (void)performTask:(dispatch_block_t)taskBlock {
    if (!taskBlock)
        return;
    
    dispatch_async(self.serialQueue, ^{
        taskBlock();
    });
}

#pragma mark - InternalMethods

- (void)addTaskOperatorToQueue:(TaskOperator *)taskOperator {
    if (!taskOperator)
        return;
    
    if (taskOperator.priority == TaskPriorityHigh) {
        [self.highPriorityTasks addObject:taskOperator];
    } else if (taskOperator.priority == TaskPriorityNormal) {
        [self.normalPriorityTasks addObject:taskOperator];
    } else {
        [self.lowPriorityTasks addObject:taskOperator];
    }
    
    self.workingTaskCount++;
}

- (TaskOperator *)nextTaskOperator {
    TaskOperator *task = [self.highPriorityTasks firstObject];
    if (task) {
        return task;
    }
    
    task = [self.normalPriorityTasks firstObject];
    if (task) {
        return task;
    }
    
    task = [self.lowPriorityTasks firstObject];
    if (task) {
        return task;
    }
    
    return nil;
}

#pragma mark - TaskOperatorDelegate

- (void)taskOperatorDidFinish:(nonnull TaskOperator *)taskOperator {
    self.workingTaskCount--;
    
    if ([self.highPriorityTasks containsObject:taskOperator]) {
        [self.highPriorityTasks removeObject:taskOperator];
        
    } else if ([self.normalPriorityTasks containsObject:taskOperator]) {
        [self.normalPriorityTasks removeObject:taskOperator];
        
    } else if ([self.lowPriorityTasks containsObject:taskOperator]) {
        [self.lowPriorityTasks removeObject:taskOperator];
    }
}

@end
