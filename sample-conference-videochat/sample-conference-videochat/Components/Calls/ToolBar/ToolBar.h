//
//  ToolBar.h
//  sample-conference-videochat
//
//  Created by Injoit on 13/10/15.
//  Copyright © 2015 QuickBlox Team. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface ToolBar : UIToolbar

- (void)addButton:(UIButton *)button action:(void(^)(UIButton *sender))action;

- (void)updateItems;
- (void)removeAllButtons;

@end
