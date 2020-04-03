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

@interface FileDownloadTableViewModel () <NITableViewModelDelegate, UITableViewDelegate, UIScrollViewDelegate>

@property (nonatomic) BOOL isScrolling;

@end

@implementation FileDownloadTableViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _tableViewDelegate = self;
        _tableViewDataSource = [[NITableViewModel alloc] initWithDelegate:(id)[NICellFactory class]];
        _isScrolling = NO;
    }
    return self;
}

- (instancetype)initWithListArray:(NSArray<FileDownloadViewModel *> *)array {
    self = [super init];
    if (self) {
        _tableViewDelegate = self;
        _tableViewDataSource = [[NITableViewModel alloc] initWithListArray:array delegate:(id)[NICellFactory class]];
        _isScrolling = NO;
    }
    return self;
}

- (instancetype)initWithSectionedArray:(NSArray *)array {
    self = [super init];
    if (self) {
        _tableViewDelegate = self;
        _tableViewDataSource = [[NITableViewModel alloc] initWithSectionedArray:array delegate:(id)[NICellFactory class]];
        _isScrolling = NO;
    }
    return self;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectRowAtIndexPath:)]) {
        [self.delegate didSelectRowAtIndexPath:indexPath];
    }
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(scrollViewDidBeginScroll)]) {
        [self.delegate scrollViewDidBeginScroll];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(scrollViewDidEndScroll)]) {
        [self.delegate scrollViewDidEndScroll];
    }
}

@end
