//
//  FileDownloadCell.m
//  Zalo-File Download Manager
//
//  Created by Trần Đình Tôn Hiếu on 3/30/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "FileDownloadCell.h"
#import "AppConsts.h"
#import "NimbusCore.h"
#import "NimbusModels.h"
#import "FileDownloadViewModel.h"

@interface FileDownloadCell () <NICell>

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *stateLabel;
@property (nonatomic, strong) UIProgressView *progressBar;
@property (nonatomic, strong) UIImageView *actionImageView;

@property (nonatomic, strong) UIImage *pauseImage;
@property (nonatomic, strong) UIImage *resumeImage;
@property (nonatomic, strong) UIImage *retryImage;
           
@end


@implementation FileDownloadCell

- (void)initAndLayoutView {
    for (UIView *subView in self.contentView.subviews) {
        [subView removeFromSuperview];
    }
    
    _nameLabel = [[UILabel alloc] init];
    _stateLabel = [[UILabel alloc] init];
    _progressBar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    _actionImageView = [[UIImageView alloc] init];
    
    _retryImage = [[UIImage imageNamed:@"retry"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _pauseImage = [[UIImage imageNamed:@"pause"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _resumeImage = [[UIImage imageNamed:@"resume"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.stateLabel];
    [self.contentView addSubview:self.progressBar];
    [self.contentView addSubview:self.actionImageView];
    
    [self.contentView.heightAnchor constraintEqualToConstant:70].active = YES;
    
    self.nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.nameLabel.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:13].active = YES;
    [self.nameLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:20].active = YES;
    [self.nameLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-10].active = YES;
    self.nameLabel.font = [UIFont boldSystemFontOfSize:17];
    
    self.stateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.stateLabel.topAnchor constraintEqualToAnchor:self.nameLabel.bottomAnchor constant:4].active = YES;
    [self.stateLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:20].active = YES;
    [self.stateLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-10].active = YES;
    self.stateLabel.font = [UIFont systemFontOfSize:13];
    self.stateLabel.textColor = [UIColor darkGrayColor];
    
    self.progressBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.progressBar.topAnchor constraintEqualToAnchor:self.stateLabel.bottomAnchor constant:8].active = YES;
    [self.progressBar.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:10].active = YES;
    [self.progressBar.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-10].active = YES;
    self.progressBar.tintColor = [UIColor systemBlueColor];
    [self.progressBar setProgress:0 animated:NO];
    
    self.actionImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.actionImageView.heightAnchor constraintEqualToConstant:35].active = YES;
    [self.actionImageView.widthAnchor constraintEqualToConstant:35].active = YES;
    [self.actionImageView.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor].active = YES;
    [self.actionImageView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-10].active = YES;
    [self.actionImageView setImage:self.pauseImage];
    self.actionImageView.tintColor = [UIColor grayColor];
    
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.stateLabel setTextColor:[UIColor darkGrayColor]];
    self.progressBar.hidden = NO;
    self.actionImageView.hidden = NO;
}

#pragma mark - NICellProtocol

- (BOOL)shouldUpdateCellWithObject:(id)object {
    if (!object) {
        return NO;
    }
    
    if (!self.nameLabel || !self.stateLabel || !self.progressBar) {
        [self initAndLayoutView];
    }
    
    FileDownloadViewModel *viewModel = (FileDownloadViewModel *)object;
    
    [self.nameLabel setText:viewModel.fileName];
    if (viewModel.state == FileDownloading) {
        if (viewModel.totalBytes > 0) {
            [self.stateLabel setText:[NSString stringWithFormat:@"Đang tải (%.1f MB/%.1f MB)", viewModel.bytesWritten * 1.0 / (1024 * 1024),
                                      viewModel.totalBytes * 1.0 / (1024 * 1024)]];
        } else {
            [self.stateLabel setText:@"Đang tải"];
        }
        [self.actionImageView setImage:self.pauseImage];
        
    } else if (viewModel.state == FileDownloadFinish) {
        [self.stateLabel setText:@"Đã tải xong"];
        self.actionImageView.hidden = YES;
        self.progressBar.hidden = YES;
        self.stateLabel.textColor = [UIColor systemBlueColor];
        
    } else if (viewModel.state == FileDownloadPause) {
        if (viewModel.totalBytes > 0) {
            [self.stateLabel setText:[NSString stringWithFormat:@"Tạm dừng (%.1f MB/%.1f MB)", viewModel.bytesWritten * 1.0 / (1024 * 1024),
            viewModel.totalBytes * 1.0 / (1024 * 1024)]];
        } else {
            [self.stateLabel setText:@"Tạm dừng"];
        }
        [self.actionImageView setImage:self.resumeImage];
        
    } else if (viewModel.state == FileDownloadCancel) {
        [self.stateLabel setText:@"Đã huỷ"];
        self.stateLabel.textColor = [UIColor systemRedColor];
        self.progressBar.hidden = YES;
        [self.actionImageView setImage:self.retryImage];
    }
    
    float progress = 0;
    if (viewModel.totalBytes > 0) {
        progress = (float)viewModel.bytesWritten / viewModel.totalBytes;
        progress *= 40;
        progress /= 40;
    } else {
        progress = 0;
    }
    
    [self.progressBar setProgress:progress];
    
    return YES;
}

@end

