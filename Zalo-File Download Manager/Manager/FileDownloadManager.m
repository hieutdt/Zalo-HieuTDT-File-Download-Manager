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
    
    if ([self.fileOperatorDictionary valueForKey:url] && [self.fileOperatorDictionary valueForKey:url].isRunning) {
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
        
        if ([self.fileOperatorDictionary valueForKey:url]) {
            [self.fileOperatorDictionary setObject:downloadOperator forKey:url];
        } else {
            [self.fileOperatorDictionary addEntriesFromDictionary:@{url : downloadOperator}];
        }
        
        [self performTaskOperator:downloadOperator];
    }
}

- (void)pauseDownloadFileWithUrl:(NSString *)url
                        priority:(TaskPriority)priority
               completionHandler:(void (^)(NSString *url, NSError *error))completionHandler {
    if (!url || !completionHandler)
        return;
    
    @synchronized (self) {
        FileDownloadOperator *downloadOperator = [self.fileOperatorDictionary objectForKey:url];
        
        if (!downloadOperator) {
            NSError *error = [[NSError alloc] initWithDomain:@"FileDownloadOperator"
                                                        code:ERROR_GET_OPERATOR_FAILED
                                                    userInfo:@{@"Can't find DownloadOperator": NSLocalizedDescriptionKey}];
            completionHandler(url, error);
        }
        
        [downloadOperator updateTaskToPauseDownloadWithPriority:priority completionHandler:^(NSString * _Nonnull url, NSError *error) {
            completionHandler(url, error);
        } callBackQueue:self.serialQueue];
        
        [self performTaskOperator:downloadOperator];
    }
}

- (void)resumeDownloadFileWithUrl:(NSString *)url
                         priority:(TaskPriority)priority
                completionHandler:(void (^)(NSString *url, NSError *error))completionHandler {
    if (!url || !completionHandler)
        return;
    
    @synchronized (self) {
        FileDownloadOperator *downloadOperator = [self.fileOperatorDictionary objectForKey:url];
        
        if (!downloadOperator) {
            NSError *error = [[NSError alloc] initWithDomain:@"FileDownloadOperator"
                                                        code:ERROR_GET_OPERATOR_FAILED
                                                    userInfo:@{@"Can't find DownloadOperator": NSLocalizedDescriptionKey}];
            completionHandler(url, error);
        }
        
        [downloadOperator updateTaskToResumeDownloadWithPriority:priority
                                               completionHandler:^(NSString * _Nonnull url, NSError *error) {
            completionHandler(url, error);
        } callBackQueue:self.serialQueue];
        
        [self performTaskOperator:downloadOperator];
    }
}

- (void)cancelDownloadFileWithUrl:(NSString *)url
                         priority:(TaskPriority)priority
                completionHandler:(void (^)(NSString *url))completionHandler {
    if (!url || !completionHandler)
        return;
    
    @synchronized (self) {
        FileDownloadOperator *downloadOperator = [self.fileOperatorDictionary objectForKey:url];
        
        if (!downloadOperator) {
            completionHandler(url);
            return;
        }
        
        [downloadOperator updateTaskToCancelDownloadWithPriority:priority
                                               completionHandler:^(NSString * _Nonnull url) {
            completionHandler(url);
        } callBackQueue:self.serialQueue];
        
        [self performTaskOperator:downloadOperator];
    }
}

- (void)retryDownloadFileWithUrl:(NSString *)url
                        priority:(TaskPriority)priority
               completionHandler:(void (^)(NSString *url, NSError *error))completionHandler {
    if (!url || !completionHandler)
        return;
    
    @synchronized (self) {
        FileDownloadOperator *downloadOperator = [self.fileOperatorDictionary objectForKey:url];
        if (!downloadOperator) {
            NSError *error = [[NSError alloc] initWithDomain:@"FileDownloadOperator"
                                                        code:ERROR_GET_OPERATOR_FAILED
                                                    userInfo:@{@"Can't find DownloadOperator": NSLocalizedDescriptionKey}];
            completionHandler(url, error);
        }
        
        [downloadOperator updateTaskToReDownloadWithPriority:priority
                                           timeOutForRequest:30
                                           completionHandler:^(NSString * _Nonnull url, NSError *error) {
            completionHandler(url, error);
        } callBackQueue:self.serialQueue];
        
        [self performTaskOperator:downloadOperator];
    }
}

@end
