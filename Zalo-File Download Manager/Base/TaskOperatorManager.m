//
//  TaskOperatorManager.m
//  Zalo-File Download Manager
//
//  Created by Trần Đình Tôn Hiếu on 4/5/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "TaskOperatorManager.h"
#import "AppConsts.h"

@interface TaskOperatorManager ()

@property (nonatomic, strong) NSMutableArray<TaskOperator *> *highPriorityTasks;
@property (nonatomic, strong) NSMutableArray<TaskOperator *> *normalPriorityTasks;
@property (nonatomic, strong) NSMutableArray<TaskOperator *> *lowPriorityTasks;
@property (nonatomic, strong) dispatch_queue_t serialQueue;

@end

@implementation TaskOperatorManager

- (instancetype)init {
    self = [super init];
    if (self) {
        _highPriorityTasks = [[NSMutableArray alloc] init];
        _normalPriorityTasks = [[NSMutableArray alloc] init];
        _lowPriorityTasks = [[NSMutableArray alloc] init];
        _serialQueue = dispatch_queue_create("TaskOperatorManagerQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)performTaskOperator:(TaskOperator *)taskOperator {
    if (!taskOperator)
        return;
    
    [self addTaskOperatorToQueue:taskOperator];
    
    dispatch_async(self.serialQueue, ^{
        TaskOperator *task = [self nextTaskOperator];
        [task execute];
    });
}

#pragma mark - InternalMethods

- (void)addTaskOperatorToQueue:(TaskOperator *)taskOperator {
    @synchronized (self) {
        if (taskOperator.priority == TaskPriorityHigh) {
            [self.highPriorityTasks addObject:taskOperator];
        } else if (taskOperator.priority == TaskPriorityNormal) {
            [self.normalPriorityTasks addObject:taskOperator];
        } else {
            [self.lowPriorityTasks addObject:taskOperator];
        }
    }
}

- (TaskOperator *)nextTaskOperator {
    @synchronized (self) {
        TaskOperator *task = [self.highPriorityTasks lastObject];
        if (task) {
            [self.highPriorityTasks removeLastObject];
            return task;
        }
        
        task = [self.normalPriorityTasks lastObject];
        if (task) {
            [self.normalPriorityTasks removeLastObject];
            return task;
        }
        
        task = [self.lowPriorityTasks lastObject];
        if (task) {
            [self.lowPriorityTasks removeLastObject];
            return task;
        }
        
        return nil;
    }
}

@end
