//
//  StatsView.h
//  sample-videochat-webrtc
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CallInfo;

@interface StatsView : UIView

@property (strong, nonatomic) CallInfo *callInfo;

@end
