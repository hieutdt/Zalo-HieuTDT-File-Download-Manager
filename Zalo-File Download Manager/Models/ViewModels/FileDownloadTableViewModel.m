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
#import "FileDownloadCell.h"

@interface FileDownloadTableViewModel () <NITableViewModelDelegate, UITableViewDelegate, FileDownloadCellDelegate>

@end

@implementation FileDownloadTableViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _tableViewDelegate = self;
        _tableViewDataSource = [[NITableViewModel alloc] initWithDelegate:self];
    }
    return self;
}

- (instancetype)initWithListArray:(NSArray<FileDownloadViewModel *> *)array {
    self = [super init];
    if (self) {
        _tableViewDelegate = self;
        _tableViewDataSource = [[NITableViewModel alloc] initWithListArray:array delegate:self];
    }
    return self;
}

- (instancetype)initWithSectionedArray:(NSArray *)array {
    self = [super init];
    if (self) {
        _tableViewDelegate = self;
        _tableViewDataSource = [[NITableViewModel alloc] initWithSectionedArray:array delegate:self];
    }
    return self;
}

#pragma mark - NITableViewModelDelegate

- (nonnull UITableViewCell *)tableViewModel: (nonnull NITableViewModel *)tableViewModel cellForTableView: (nonnull UITableView *)tableView atIndexPath: (nonnull NSIndexPath *)indexPath withObject: (nonnull id)object {
    FileDownloadCell *cell = (FileDownloadCell *)[NICellFactory tableViewModel:tableViewModel cellForTableView:tableView atIndexPath:indexPath withObject:object];
    cell.delegate = self;
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - FileDownloadCellDelegate

- (void)pauseButtonTappedInCell:(UIView *)cell {
    if (self.delegate && [self.delegate respondsToSelector:@selector(pauseButtonTappedAtCell:)]) {
        [self.delegate pauseButtonTappedAtCell:(FileDownloadCell *)cell];
    }
}

@end
