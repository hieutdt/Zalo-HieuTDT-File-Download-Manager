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
#import "FileDownloadCell.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FileDownloadTableViewModelDelegate <NSObject>

- (void)pauseButtonTappedAtCell:(FileDownloadCell *)cell;

- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)scrollViewDidBeginScroll;

- (void)scrollViewDidEndScroll;

@end

@interface FileDownloadTableViewModel : NSObject

@property (nonatomic, strong) id<FileDownloadTableViewModelDelegate> delegate;

@property (nonatomic, strong) NITableViewModel *tableViewDataSource;
@property (nonatomic, strong) id<UITableViewDelegate> tableViewDelegate;

- (instancetype)initWithListArray:(NSArray<FileDownloadViewModel *> *)array;

- (instancetype)initWithSectionedArray:(NSArray *)array;

@end

NS_ASSUME_NONNULL_END
