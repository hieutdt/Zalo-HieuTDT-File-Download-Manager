//
//  File.h
//  Zalo-File Download Manager
//
//  Created by Trần Đình Tôn Hiếu on 3/27/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppConsts.h"

NS_ASSUME_NONNULL_BEGIN

@interface File : NSObject

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *locationPath;
@property (nonatomic, assign) FileDownloadState state;
@property (nonatomic, assign) long long totalBytes;
@property (nonatomic, assign) long long bytesWritten;

- (instancetype)initWithName:(NSString *)fileName url:(NSString *)url;

@end

NS_ASSUME_NONNULL_END
