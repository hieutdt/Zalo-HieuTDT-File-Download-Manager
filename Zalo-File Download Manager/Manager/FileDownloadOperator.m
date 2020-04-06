//
//  FileDownloadOperator.m
//  Zalo-File Download Manager
//
//  Created by Trần Đình Tôn Hiếu on 4/5/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "FileDownloadOperator.h"

@interface FileDownloadOperator ()

@property (nonatomic, assign) FileDownloadItem *item;
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;

@end

@implementation FileDownloadOperator

- (instancetype)init {
    self = [super initWithTaskBlock:^{} priority:TaskPriorityNormal];
    if (self) {
    }
    return self;
}

- (instancetype)initWithFileDownloadItem:(FileDownloadItem *)item priority:(TaskPriority)priority {
    self = [super init];
    if (self) {
        _item = item;
        
    }
    
    return nil;
}


- (void)execute {
    
}

@end
