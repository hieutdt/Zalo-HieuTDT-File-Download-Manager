//
//  DownloadDataCache.h
//  Zalo-File Download Manager
//
//  Created by Trần Đình Tôn Hiếu on 3/31/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DownloadDataCache : NSObject

+ (instancetype)instance;

- (NSData *)dataForKey:(NSString *)key;
- (void)setData:(NSData *)data forKey:(NSString *)key;
- (void)removeDataByKey:(NSString *)key;
- (void)removeAllDatas;

@end

NS_ASSUME_NONNULL_END
