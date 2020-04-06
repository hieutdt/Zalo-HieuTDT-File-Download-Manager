//
//  TaskOperatorManager.h
//  Zalo-File Download Manager
//
//  Created by Trần Đình Tôn Hiếu on 4/5/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TaskOperator.h"

NS_ASSUME_NONNULL_BEGIN

@interface TaskOperatorManager : NSObject

- (void)performTaskOperator:(TaskOperator *)taskOperator;

@end

NS_ASSUME_NONNULL_END
