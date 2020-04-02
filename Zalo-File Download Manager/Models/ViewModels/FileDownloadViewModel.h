//
//  FileDownloadViewModel.h
//  Zalo-File Download Manager
//
//  Created by Trần Đình Tôn Hiếu on 3/30/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppConsts.h"
#import "File.h"

NS_ASSUME_NONNULL_BEGIN

@interface FileDownloadViewModel : NSObject

@property (nonatomic, strong) NSString *fileName;
@property (nonatomic) FileDownloadState state;
@property (nonatomic, strong) NSString *imageName;
@property (nonatomic) long long totalBytes;
@property (nonatomic) long long bytesWritten;

- (instancetype)initWithFile:(File *)file;
- (instancetype)initWithFileName:(NSString *)fileName state:(FileDownloadState)state imageName:(NSString *)imageName totalBytes:(long long)totalBytes bytesWritten:(long long)bytesWritten;

- (void)updateByFile:(File *)file;

@end

NS_ASSUME_NONNULL_END
