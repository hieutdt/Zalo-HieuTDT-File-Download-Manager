//
//  Connectivity.h
//  Zalo-File Download Manager
//
//  Created by Trần Đình Tôn Hiếu on 4/11/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppConsts.h"

NS_ASSUME_NONNULL_BEGIN

@interface Connectivity : NSObject

+ (instancetype)instance;

- (void)getCurrentNetworkStateWithCompletionHandler:(void (^)(ConnectState state))completionHandler;

@end

NS_ASSUME_NONNULL_END
