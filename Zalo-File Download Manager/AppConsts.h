//
//  AppConsts.h
//  Zalo-File Download Manager
//
//  Created by Trần Đình Tôn Hiếu on 3/30/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifndef AppConsts_h
#define AppConsts_h

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

typedef NS_ENUM(NSInteger, FileDownloadState) {
    FileDownloading,
    FileDownloadPause,
    FileDownloadCancel,
    FileDownloadFinish
};

typedef NS_ENUM(NSInteger, TaskPriority) {
    TaskPriorityLow = 0,
    TaskPriorityNormal,
    TaskPriorityHigh
};

typedef NS_ENUM(NSInteger, ConnectState) {
    ConnectStateNone = 0,
    ConnectStateWifi,
    ConnectState3G4G
};

static int DOWNLOAD_CELL_HEADER_IMAGE_HEIGHT = 40;
static int DOWNLOAD_CELL_HEADER_IMAGE_WIDTH = 40;

static int ERROR_GET_RESUME_DATA_FAILED = 1;
static int ERROR_RETRY_DOWNLOAD_FAILED = 2;
static int ERROR_GET_OPERATOR_FAILED = 3;

static int DOWNLOAD_DATA_CACHE_SIZE = 10;


#endif /* AppConsts_h */
