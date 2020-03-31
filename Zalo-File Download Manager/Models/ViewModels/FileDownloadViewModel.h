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
@property (nonatomic) float progress;
@property (nonatomic) FileDownloadState state;
@property (nonatomic, strong) NSString *imageName;

- (instancetype)initWithFile:(File *)file;
- (instancetype)initWithFileName:(NSString *)fileName progress:(float)progress state:(FileDownloadState)state imageName:(NSString *)imageName;

- (void)updateByFile:(File *)file;

@end

NS_ASSUME_NONNULL_END
