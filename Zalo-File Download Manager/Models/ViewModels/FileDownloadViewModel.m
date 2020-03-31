//
//  FileDownloadViewModel.m
//  Zalo-File Download Manager
//
//  Created by Trần Đình Tôn Hiếu on 3/30/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "FileDownloadViewModel.h"
#import "NimbusCore.h"
#import "NimbusModels.h"
#import "FileDownloadCell.h"
#import "File.h"

@interface FileDownloadViewModel () <NICellObject>

@end

@implementation FileDownloadViewModel

- (instancetype)initWithFile:(File *)file {
    self = [super init];
    if (self) {
        _fileName = file.fileName;
        _progress = file.progress;
        _state = file.state;
        _imageName = @"download";
    }
    return self;
}

- (instancetype)initWithFileName:(NSString *)fileName progress:(float)progress state:(FileDownloadState)state imageName:(NSString *)imageName {
    self = [super init];
    if (self) {
        _fileName = fileName;
        _progress = progress;
        _state = state;
        _imageName = imageName;
    }
    return self;
}

- (void)updateByFile:(File *)file {
    if (!self) {
        return;
    }
    
    self.fileName = file.fileName;
    self.progress = file.progress;
    self.state = file.state;
}

- (Class)cellClass {
    return [FileDownloadCell class];
}

@end
