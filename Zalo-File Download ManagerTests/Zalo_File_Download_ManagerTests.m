//
//  Zalo_File_Download_ManagerTests.m
//  Zalo-File Download ManagerTests
//
//  Created by Trần Đình Tôn Hiếu on 3/27/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TaskOperatorManager.h"
#import "TaskOperator.h"

@interface Zalo_File_Download_ManagerTests : XCTestCase

@property (nonatomic, strong) TaskOperatorManager *manager;

@end

@implementation Zalo_File_Download_ManagerTests

- (void)setUp {
    _manager = [[TaskOperatorManager alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    dispatch_apply(20, dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^(size_t size){
        TaskOperator *operator = [[TaskOperator alloc] initWithTaskBlock:^{
            NSLog(@"Task %d", size);
            sleep(2);
        } priority:TaskPriorityHigh];
        [self.manager performTaskOperator:operator];
    });
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
