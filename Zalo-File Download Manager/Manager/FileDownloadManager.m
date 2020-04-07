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

- (instancetype)init {
    self = [super init];
    if (self) {
        _fileOperatorDictionary = [[NSMutableDictionary alloc] init];
    }
    return self;
}

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
         timeOutIntervalForRequest:(int)timeOut
                   progressHandler:(void (^)(NSString *url, long long bytesWritten, long long totalBytes))progressHandler
                 completionHandler:(void (^)(NSString *url, NSString *locationPath, NSError *error))completionHandler {
    if (!url || !progressHandler || !completionHandler)
        return;
    
    if ([self.fileOperatorDictionary valueForKey:url]) {
        return;
    }
    
    @synchronized (self) {
        FileDownloadItem *downloadItem = [[FileDownloadItem alloc] initWithDownloadUrl:url
                                                                       progressHandler:progressHandler
                                                                     completionHandler:completionHandler];
        FileDownloadOperator *downloadOperator = [[FileDownloadOperator alloc] initWithFileDownloadItem:downloadItem
                                                                                               priority:priority
                                                                                      timeOutForRequest:timeOut
                                                                                          callBackQueue:self.serialQueue];
        
        [self.fileOperatorDictionary addEntriesFromDictionary:@{url : downloadOperator}];
        
        [self performTaskOperator:downloadOperator];
    }
}

- (void)pauseDownloadFileWithUrl:(NSString *)url
                        priority:(TaskPriority)priority
                sameUrlFilesLeft:(unsigned long)leftCount
               completionHandler:(void (^)(NSString *url, NSError *error))completionHandler {
    if (!url || !completionHandler)
        return;
    
    if (leftCount > 0) {
        completionHandler(url, nil);
        return;
    }
    
    FileDownloadOperator *downloadOperator = [self.fileOperatorDictionary objectForKey:url];
    [downloadOperator updateTaskToStopDownloadWithPriority:TaskPriorityHigh completionHandler:^(NSString * _Nonnull url, NSError *error) {
        completionHandler(url, error);
    } callBackQueue:self.serialQueue];
    
    [self performTaskOperator:downloadOperator];
}

@end
