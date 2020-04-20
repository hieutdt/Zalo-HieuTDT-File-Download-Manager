//
//  Connectivity.m
//  Zalo-File Download Manager
//
//  Created by Trần Đình Tôn Hiếu on 4/11/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "Connectivity.h"

#import "Reachability.h"
#import <Network/Network.h>

#import "AppConsts.h"

@interface Connectivity ()

@property (nonatomic, strong) nw_path_monitor_t monitor;
@property (nonatomic, strong) void (^getNetworkStateCompletionBlock)(ConnectState state);

@end

@implementation Connectivity

- (instancetype)init {
    self = [super init];
    if (self) {
        _getNetworkStateCompletionBlock = nil;
        _monitor = nw_path_monitor_create();
    }
    return self;
}

+ (instancetype)instance {
    static Connectivity *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[Connectivity alloc] init];
    });
    return sharedInstance;
}

- (void)connectStateByReachability {
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
        [reachability stopNotifier];
        
        if (self.getNetworkStateCompletionBlock) {
            self.getNetworkStateCompletionBlock(currentNetwork);
        }
    }
}

- (void)connectStateByNetwork {
    __block ConnectState currentNetwork = ConnectStateNone;
    
    nw_path_monitor_set_update_handler(_monitor, ^(nw_path_t  _Nonnull path) {
        if (nw_path_uses_interface_type(path, nw_interface_type_wifi)) {
            currentNetwork = ConnectStateWifi;
        } else if (nw_path_uses_interface_type(path, nw_interface_type_cellular)) {
            currentNetwork = ConnectState3G4G;
        }
        
        if (self.getNetworkStateCompletionBlock) {
            self.getNetworkStateCompletionBlock(currentNetwork);
        }
    });
    
    dispatch_queue_t concurrentQueue = dispatch_queue_create("ConcurrentQueue", DISPATCH_QUEUE_CONCURRENT);
    nw_path_monitor_set_queue(_monitor, concurrentQueue);
    nw_path_monitor_start(_monitor);
}

- (void)getCurrentNetworkStateWithCompletionHandler:(void (^)(ConnectState state))completionHandler {
    self.getNetworkStateCompletionBlock = completionHandler;
    
    if (SYSTEM_VERSION_LESS_THAN(@"12.0")) {
        [self connectStateByReachability];
    } else {
        [self connectStateByNetwork];
    }
}


@end
