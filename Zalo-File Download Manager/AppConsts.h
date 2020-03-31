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
    FileDownloadStop,
    FileDownloadCancel,
    FileDownloadFinish
};

static int DOWNLOAD_CELL_HEADER_IMAGE_HEIGHT = 50;
static int DOWNLOAD_CELL_HEADER_IMAGE_WIDTH = 50;


#endif /* AppConsts_h */
