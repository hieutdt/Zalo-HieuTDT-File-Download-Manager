//
//  DownloadDataCache.m
//  Zalo-File Download Manager
//
//  Created by Trần Đình Tôn Hiếu on 3/31/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "DownloadDataCache.h"
#import "AppConsts.h"

@interface DownloadDataCache ()

@property (nonatomic, strong) NSCache<NSURLSessionDownloadTask *, NSData *> *dataCache;

@end

@implementation DownloadDataCache

- (instancetype)init {
    self = [super init];
    if (self) {
        _dataCache = [[NSCache alloc] init];
        _dataCache.countLimit = DOWNLOAD_DATA_CACHE_SIZE;
    }
    return self;
}

+ (instancetype)instance {
    static DownloadDataCache *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DownloadDataCache alloc] init];
    });
    return sharedInstance;
}

- (void)setData:(NSData *)resumeData forDownloadTask:(NSURLSessionDownloadTask *)task {
    if (!resumeData || !task)
        return;
    
    [self.dataCache setObject:resumeData forKey:task];
}

- (NSData *)dataForDownloadTask:(NSURLSessionDownloadTask *)task {
    if (!task)
        return nil;
    
    return [self.dataCache objectForKey:task];
}

- (void)removeDataForDownloadTask:(NSURLSessionDownloadTask *)task {
    if (!task)
        return;
    
    [self.dataCache removeObjectForKey:task];
}

- (void)removeAllDatas {
    [self.dataCache removeAllObjects];
}


@end
