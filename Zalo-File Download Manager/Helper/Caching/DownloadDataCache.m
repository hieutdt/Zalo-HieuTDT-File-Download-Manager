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

@property (nonatomic, strong) NSCache<NSString *, NSData *> *dataCache;

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

- (void)setData:(NSData *)data forKey:(NSString *)key {
    if (!data || !key)
        return;
    
    [self.dataCache setObject:data forKey:key];
}

- (NSData *)dataForKey:(NSString *)key {
    if (!key)
        return nil;
    
    return [self.dataCache objectForKey:key];
}

- (void)removeDataByKey:(NSString *)key {
    if (!key)
        return;
    
    [self.dataCache removeObjectForKey:key];
}

- (void)removeAllDatas {
    [self.dataCache removeAllObjects];
}


@end
