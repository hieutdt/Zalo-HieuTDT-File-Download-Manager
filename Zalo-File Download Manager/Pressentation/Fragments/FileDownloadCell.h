//
//  FileDownloadCell.h
//  Zalo-File Download Manager
//
//  Created by Trần Đình Tôn Hiếu on 3/30/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FileDownloadCellDelegate <NSObject>

- (void)pauseButtonTappedInCell:(UIView *)cell;

@end

@interface FileDownloadCell : UITableViewCell

@property (nonatomic, assign) id<FileDownloadCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
