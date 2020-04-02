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
        _state = file.state;
        _imageName = @"download";
        _totalBytes = file.totalBytes;
        _bytesWritten = file.bytesWritten;
    }
    return self;
}

- (instancetype)initWithFileName:(NSString *)fileName state:(FileDownloadState)state imageName:(NSString *)imageName totalBytes:(long long)totalBytes bytesWritten:(long long)bytesWritten {
    self = [super init];
    if (self) {
        _fileName = fileName;
        _state = state;
        _imageName = @"download";
        _totalBytes = totalBytes;
        _bytesWritten = bytesWritten;
    }
    return self;
}

- (void)updateByFile:(File *)file {
    if (!self) {
        return;
    }
    
    self.fileName = file.fileName;
    self.state = file.state;
    self.totalBytes = file.totalBytes;
    self.bytesWritten = file.bytesWritten;
}

- (Class)cellClass {
    return [FileDownloadCell class];
}

@end
