//
//  URLDownloadCache.m
//  Zalo-File Download Manager
//
//  Created by Trần Đình Tôn Hiếu on 4/10/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "URLDownloadCache.h"
#import "AppConsts.h"

@interface URLDownloadCache ()

@property (nonatomic, strong) NSCache<NSString *, NSString *> *cache;

@end

@implementation URLDownloadCache

- (instancetype)init {
    self = [super init];
    if (self) {
        _cache = [[NSCache alloc] init];
    }
    return self;
}

+ (instancetype)instance {
    static URLDownloadCache *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[URLDownloadCache alloc] init];
    });
    return sharedInstance;
}

- (NSString *)pathForUrl:(NSString *)url {
    if (!url)
        return nil;
    
    return [self.cache objectForKey:url];
}

- (void)setLocationPath:(NSString *)path forUrl:(NSString *)url {
    if (path && url) {
        [self.cache setObject:path forKey:url];
    }
}

- (void)removePathByUrl:(NSString *)url {
    if (url) {
        [self.cache removeObjectForKey:url];
    }
}

- (void)removeAllDatas {
    [self.cache removeAllObjects];
}

@end
