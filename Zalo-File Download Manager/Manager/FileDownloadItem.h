//
//  FileDownloadItem.h
//  Zalo-File Download Manager
//
//  Created by Trần Đình Tôn Hiếu on 4/5/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FileDownloadItem : NSObject

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) void (^progressHandler)(NSString *url, long long bytesWritten, long long totalBytes);
@property (nonatomic, strong) void (^completionHandler)(NSString *url, NSString *locationPath, NSError  * _Nullable error);

- (instancetype)initWithDownloadUrl:(NSString *)url
                    progressHandler:(void (^)(NSString *url, long long bytesWritten, long long totalBytes))progressHandler
                  completionHandler:(void (^)(NSString *url, NSString *locationPath, NSError *error))completionHandler;

@end

NS_ASSUME_NONNULL_END
