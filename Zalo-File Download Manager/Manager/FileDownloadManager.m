//
//  FileDownloadManager.m
//  Zalo-File Download Manager
//
//  Created by Trần Đình Tôn Hiếu on 4/5/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "FileDownloadManager.h"
#import "FileDownloadOperator.h"
#import "FileDownloadItem.h"

@interface FileDownloadManager ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, FileDownloadOperator *> *fileOperatorDictionary;

@end

@implementation FileDownloadManager

+ (instancetype)instance {
    static FileDownloadManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[FileDownloadManager alloc] init];
    });
    return sharedInstance;
}

- (void)performDownloadFileWithUrl:(NSString *)url
                          priority:(TaskPriority)priority
                   progressHandler:(void (^)(NSString * _Nonnull url, long long bytesWritten, long long totalBytes))progressHandler
                 completionHandler:(void (^)(NSString * _Nonnull url, NSString * _Nonnull locationPath, NSError *error))completionHandler {
    if (!url || !progressHandler || !completionHandler)
        return;
    
    if ([self.fileOperatorDictionary valueForKey:url]) {
        return;
    }
    
    @synchronized (self) {
        FileDownloadItem *downloadItem = [[FileDownloadItem alloc] initWithDownloadUrl:url progressHandler:progressHandler completionHandler:completionHandler];
        FileDownloadOperator *downloadOperator = [[FileDownloadOperator alloc] initWithFileDownloadItem:downloadItem priority:priority];
        
        [self.fileOperatorDictionary addEntriesFromDictionary:@{url : downloadOperator}];
        
        [self performTaskOperator:downloadOperator];
    }
}

@end
