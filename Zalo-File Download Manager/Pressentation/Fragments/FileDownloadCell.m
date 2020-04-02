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

@property (nonatomic, strong) UIImageView *headerImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *stateLabel;
@property (nonatomic, strong) UIProgressView *progressBar;
@property (nonatomic, strong) UIButton *stopButton;
           
@end


@implementation FileDownloadCell

- (void)initAndLayoutView {
    for (UIView *subView in self.contentView.subviews) {
        [subView removeFromSuperview];
    }
    
    _headerImageView = [[UIImageView alloc] init];
    _nameLabel = [[UILabel alloc] init];
    _stateLabel = [[UILabel alloc] init];
    _progressBar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    _stopButton = [[UIButton alloc] init];
    
    [self.contentView addSubview:self.headerImageView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.stateLabel];
    [self.contentView addSubview:self.progressBar];
    [self.contentView addSubview:self.stopButton];
    
    self.headerImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.headerImageView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:15].active = YES;
    [self.headerImageView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:15].active = YES;
    [self.headerImageView.heightAnchor constraintEqualToConstant:DOWNLOAD_CELL_HEADER_IMAGE_HEIGHT].active = YES;
    [self.headerImageView.widthAnchor constraintEqualToConstant:DOWNLOAD_CELL_HEADER_IMAGE_WIDTH].active = YES;
    
    self.nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.nameLabel.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:13].active = YES;
    [self.nameLabel.leadingAnchor constraintEqualToAnchor:self.headerImageView.trailingAnchor constant:15].active = YES;
    [self.nameLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-10].active = YES;
    self.nameLabel.font = [UIFont boldSystemFontOfSize:17];
    
    self.stateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.stateLabel.topAnchor constraintEqualToAnchor:self.nameLabel.bottomAnchor constant:4].active = YES;
    [self.stateLabel.leadingAnchor constraintEqualToAnchor:self.headerImageView.trailingAnchor constant:15].active = YES;
    [self.stateLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-10].active = YES;
    self.stateLabel.font = [UIFont systemFontOfSize:13];
    self.stateLabel.textColor = [UIColor darkGrayColor];
    
    self.progressBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.progressBar.topAnchor constraintEqualToAnchor:self.headerImageView.bottomAnchor constant:8].active = YES;
    [self.progressBar.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:10].active = YES;
    [self.progressBar.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-10].active = YES;
    [self.progressBar.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-10].active = YES;
    self.progressBar.tintColor = [UIColor systemGreenColor];
    [self.progressBar setProgress:0 animated:NO];
    
    self.stopButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.stopButton.heightAnchor constraintEqualToConstant:35].active = YES;
    [self.stopButton.widthAnchor constraintEqualToConstant:35].active = YES;
    [self.stopButton.centerYAnchor constraintEqualToAnchor:self.headerImageView.centerYAnchor].active = YES;
    [self.stopButton.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-10].active = YES;
    [self.stopButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
    [self.stopButton addTarget:self action:@selector(stopButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
}

- (void)stopButtonTapped {
    if (self.delegate && [self.delegate respondsToSelector:@selector(pauseButtonTappedInCell:)]) {
        [self.delegate pauseButtonTappedInCell:self];
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.stateLabel setTextColor:[UIColor darkGrayColor]];
    self.progressBar.hidden = NO;
    self.stopButton.hidden = NO;
}

#pragma mark - NICellProtocol

- (BOOL)shouldUpdateCellWithObject:(id)object {
    if (!object) {
        return NO;
    }
    
    if (!self.headerImageView || !self.nameLabel || !self.stateLabel || !self.progressBar) {
        [self initAndLayoutView];
    }
    
    FileDownloadViewModel *viewModel = (FileDownloadViewModel *)object;
    
    [self.headerImageView setImage:[UIImage imageNamed:viewModel.imageName]];
    [self.nameLabel setText:viewModel.fileName];
    if (viewModel.state == FileDownloading) {
        [self.stateLabel setText:@"Đang tải"];
        [self.stopButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
        
    } else if (viewModel.state == FileDownloadFinish) {
        [self.stateLabel setText:@"Đã tải xong"];
        self.stopButton.hidden = YES;
        self.progressBar.hidden = YES;
        self.stateLabel.textColor = [UIColor systemGreenColor];
        
    } else if (viewModel.state == FileDownloadPause) {
        [self.stateLabel setText:@"Tạm dừng"];
        [self.stopButton setImage:[UIImage imageNamed:@"resume"] forState:UIControlStateNormal];
        
    } else if (viewModel.state == FileDownloadCancel) {
        [self.stateLabel setText:@"Đã huỷ"];
        self.stateLabel.textColor = [UIColor systemRedColor];
        self.progressBar.hidden = YES;
        [self.stopButton setImage:[UIImage imageNamed:@"retry"] forState:UIControlStateNormal];
    }
    
    [self.progressBar setProgress:viewModel.progress];
    
    return YES;
}

@end

