//
//  UITableView+Chat.h
//  sample-chat
//
//  Created by Injoit on 04.02.2020.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITableView (Chat)
- (void)setupEmptyViewWithAlert:(NSString *)alert;
- (void)removeEmptyView;
- (void)addShadowWithColor:(UIColor *)shadowColor;
@end

NS_ASSUME_NONNULL_END
