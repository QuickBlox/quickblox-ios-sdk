//
//  ToolBar.h
//  sample-videochat-webrtc
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface ToolBar : UIToolbar

- (void)addButton:(UIButton *)button action:(void(^)(UIButton *sender))action;

- (void)updateItems;

@end
