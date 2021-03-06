//
//  FileDownloadItem.m
//  Zalo-File Download Manager
//
//  Created by Trần Đình Tôn Hiếu on 4/5/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "FileDownloadItem.h"

@interface FileDownloadItem ()

@end

@implementation FileDownloadItem

- (instancetype)init {
    self = [super init];
    if (self) {
        _identifier = [[NSUUID UUID] UUIDString];
        _url = [[NSString alloc] init];
        _progressHandlers = [[NSMutableArray alloc] init];
        _completionHandlers = [[NSMutableArray alloc] init];
    }
    return self;
}

- (instancetype)initWithDownloadUrl:(NSString *)url
                    progressHandler:(void (^)(NSString *url, long long bytesWritten, long long totalBytes))progressHandler
                  completionHandler:(void (^)(NSString *url, NSString *locationPath, NSError *error))completionHandler {
    self = [super init];
    if (self) {
        _identifier = [[NSUUID UUID] UUIDString];
        _url = url;
        
        _progressHandlers = [[NSMutableArray alloc] init];
        [_progressHandlers addObject:progressHandler];
        
        _completionHandlers = [[NSMutableArray alloc] init];
        [_completionHandlers addObject:completionHandler];
    }
    return self;
}

@end
