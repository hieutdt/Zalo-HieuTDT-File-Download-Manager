//
//  MainViewController.m
//  Zalo-File Download Manager
//
//  Created by Trần Đình Tôn Hiếu on 3/27/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "MainViewController.h"
#import "NimbusCore.h"
#import "NimbusModels.h"
#import "File.h"
#import "FileDownloadBusiness.h"

@interface MainViewController ()

@property (nonatomic, strong) UIBarButtonItem *downloadBarButton;
@property (nonatomic, strong) UILabel *progressLabel;
@property (nonatomic, strong) File *downloadFile;
@property (nonatomic, strong) FileDownloadBusiness *fileDownloadBusiness;

@end

@implementation MainViewController

#pragma mark - Lifecycle

- (void)customInit {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Download Manager";
    
    _downloadBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Download" style:UIBarButtonItemStylePlain target:self action:@selector(downloadButtonTapped)];
    self.navigationItem.rightBarButtonItem = _downloadBarButton;
    
    _progressLabel = [[UILabel alloc] init];
    _progressLabel.text = @"0 %";
    [self.view addSubview:_progressLabel];
    
    _progressLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_progressLabel.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
    [_progressLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    
    _downloadFile = [[File alloc] initWithName:@"DownloadFile" url:@"http://ipv4.download.thinkbroadband.com/5MB.zip"];
    
    _fileDownloadBusiness = [[FileDownloadBusiness alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self customInit];
}

- (void)downloadButtonTapped {
    [self.fileDownloadBusiness downloadMultiFiles:@[self.downloadFile] withProgressHandlers:@[^(float progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.progressLabel setText:[NSString stringWithFormat:@"%.0f %@", progress * 100, @"%"]];
        });
    }] completionHandlers:@[^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.progressLabel.text = @"Download completed!";
        });
    }]];
}

@end
