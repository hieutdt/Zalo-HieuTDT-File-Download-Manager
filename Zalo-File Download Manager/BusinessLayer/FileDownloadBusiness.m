//
//  FileDownloadBusiness.m
//  Zalo-File Download Manager
//
//  Created by Trần Đình Tôn Hiếu on 3/27/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "FileDownloadBusiness.h"
#import "FileDownloadAdapter.h"

@interface FileDownloadBusiness ()

@property (nonatomic, strong) dispatch_queue_t serialQueue;

@end

@implementation FileDownloadBusiness

- (instancetype)init {
    self = [super init];
    if (self) {
        _serialQueue = dispatch_queue_create("FileDownloadBusinessSerialQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)downloadMultiFiles:(NSArray<File *> *)files withProgressHandlers:(NSArray<void (^)(float)> *)progressHandlers completionHandlers:(NSArray<void (^)(NSError *)> *)completionHandlers {
    if (!files || !completionHandlers) {
        return;
    }
    
    dispatch_async(self.serialQueue, ^{
        [[FileDownloadAdapter instance] downloadFiles:files withProgressHandler:progressHandlers completionHandler:completionHandlers onDispatchQueue:self.serialQueue];
    });
}

@end
