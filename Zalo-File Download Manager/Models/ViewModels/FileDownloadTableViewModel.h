//
//  FileDownloadTableViewModel.h
//  Zalo-File Download Manager
//
//  Created by Trần Đình Tôn Hiếu on 3/31/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NimbusCore.h"
#import "NimbusModels.h"
#import <UIKit/UIKit.h>

#import "FileDownloadViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FileDownloadTableViewModel : NSObject

@property (nonatomic, strong) NITableViewModel *dataSource;
@property (nonatomic, strong) id<UITableViewDelegate> delegate;

- (instancetype)initWithListArray:(NSArray<FileDownloadViewModel *> *)array;

- (instancetype)initWithSectionedArray:(NSArray *)array;

@end

NS_ASSUME_NONNULL_END
