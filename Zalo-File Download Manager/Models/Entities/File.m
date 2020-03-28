//
//  File.m
//  Zalo-File Download Manager
//
//  Created by Trần Đình Tôn Hiếu on 3/27/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "File.h"

@implementation File

- (instancetype)init {
    self = [super init];
    if (self) {
        _fileName = [[NSString alloc] init];
        _url = [[NSString alloc] init];
    }
    return self;
}

- (instancetype)initWithName:(NSString *)fileName url:(NSString *)url {
    self = [super init];
    if (self) {
        _fileName = fileName;
        _url = url;
    }
    return self;
}

@end
