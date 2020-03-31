//
//  FileDownloadTableViewModel.m
//  Zalo-File Download Manager
//
//  Created by Trần Đình Tôn Hiếu on 3/31/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "FileDownloadTableViewModel.h"
#import "NimbusModels.h"
#import "NimbusCore.h"
#import "FileDownloadViewModel.h"

@interface FileDownloadTableViewModel () <UITableViewDelegate>

@end

@implementation FileDownloadTableViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _delegate = self;
        _dataSource = [[NITableViewModel alloc] initWithDelegate:(id)[NICellFactory class]];
    }
    return self;
}

- (instancetype)initWithListArray:(NSArray<FileDownloadViewModel *> *)array {
    self = [super init];
    if (self) {
        _delegate = self;
        _dataSource = [[NITableViewModel alloc] initWithListArray:array delegate:(id)[NICellFactory class]];
    }
    return self;
}

- (instancetype)initWithSectionedArray:(NSArray *)array {
    self = [super init];
    if (self) {
        _delegate = self;
        _dataSource = [[NITableViewModel alloc] initWithSectionedArray:array delegate:(id)[NICellFactory class]];
    }
    return self;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Did select row at indexpath: %@", indexPath);
}

@end
