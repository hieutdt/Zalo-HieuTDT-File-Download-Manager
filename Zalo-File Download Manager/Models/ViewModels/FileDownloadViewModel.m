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

- (instancetype)initWithFileName:(NSString *)fileName
                             url:(NSString *)url
                           state:(FileDownloadState)state
                      totalBytes:(long long)totalBytes
                    bytesWritten:(long long)bytesWritten; {
    self = [super init];
    if (self) {
        _fileName = fileName;
        _state = state;
        _url = url;
        _totalBytes = totalBytes;
        _bytesWritten = bytesWritten;
        _progress = 0;
    }
    return self;
}

- (Class)cellClass {
    return [FileDownloadCell class];
}

@end
