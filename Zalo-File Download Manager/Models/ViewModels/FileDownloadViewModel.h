//
//  FileDownloadViewModel.h
//  Zalo-File Download Manager
//
//  Created by Trần Đình Tôn Hiếu on 3/30/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppConsts.h"

NS_ASSUME_NONNULL_BEGIN

@interface FileDownloadViewModel : NSObject

@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, assign) FileDownloadState state;
@property (nonatomic, assign) long long totalBytes;
@property (nonatomic, assign) long long bytesWritten;
@property (nonatomic, assign) float progress;

- (instancetype)initWithFileName:(NSString *)fileName
                             url:(NSString *)url
                           state:(FileDownloadState)state
                      totalBytes:(long long)totalBytes
                    bytesWritten:(long long)bytesWritten;

@end

NS_ASSUME_NONNULL_END
