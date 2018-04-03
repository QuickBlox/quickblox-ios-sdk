//
//  ToolBar.h
//  sample-videochat-webrtc
//
//  Created by Andrey Ivanov on 13/10/15.
//  Copyright © 2015 QuickBlox Team. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface QBToolBar : UIToolbar

- (void)addButton:(UIButton *)button action:(void(^)(UIButton *sender))action;

- (void)updateItems;

@end
