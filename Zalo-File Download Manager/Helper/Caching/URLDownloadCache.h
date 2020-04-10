//
//  URLDownloadCache.h
//  Zalo-File Download Manager
//
//  Created by Trần Đình Tôn Hiếu on 4/10/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface URLDownloadCache : NSObject

+ (instancetype)instance;

- (NSString *)pathForUrl:(NSString *)url;
- (void)setLocationPath:(NSString *)path forUrl:(NSString *)url;
- (void)removePathByUrl:(NSString *)url;
- (void)removeAllDatas;

@end

NS_ASSUME_NONNULL_END
