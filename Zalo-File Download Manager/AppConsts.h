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

typedef NS_ENUM(NSInteger, FileDownloadState) {
    FileDownloading,
    FileDownloadPause,
    FileDownloadCancel,
    FileDownloadFinish
};

static NSString *googleDrive1GBFileUrl = @"https://speed.hetzner.de/100MB.bin";

static int DOWNLOAD_CELL_HEADER_IMAGE_HEIGHT = 40;
static int DOWNLOAD_CELL_HEADER_IMAGE_WIDTH = 40;

static int ERROR_GET_RESUME_DATA_FAILED = 1;

static int DOWNLOAD_DATA_CACHE_SIZE = 10;


#endif /* AppConsts_h */
