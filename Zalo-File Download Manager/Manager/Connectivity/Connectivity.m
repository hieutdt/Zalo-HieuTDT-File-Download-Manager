//
//  Connectivity.m
//  Zalo-File Download Manager
//
//  Created by Trần Đình Tôn Hiếu on 4/11/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "Connectivity.h"
#import "Reachability.h"

@interface Connectivity ()

@end

@implementation Connectivity

+ (instancetype)instance {
    static Connectivity *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[Connectivity alloc] init];
    });
    return sharedInstance;
}

- (ConnectState)currentNetwork {
    ConnectState currentNetwork = ConnectStateNone;
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    
    if (reachability) {
        [reachability startNotifier];
        NetworkStatus status = [reachability currentReachabilityStatus];
        if (status == NotReachable) {
            currentNetwork = ConnectStateNone;
        } else if (status == ReachableViaWiFi) {
            currentNetwork = ConnectStateWifi;
        } else if (status == ReachableViaWWAN) {
            currentNetwork = ConnectState3G4G;
        }
    }
    
    return currentNetwork;
}

@end
