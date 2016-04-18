//
//  QBButtonsFactory.h
//  sample-videochat-webrtc
//
//  Created by Andrey Ivanov on 23/10/15.
//  Copyright © 2015 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QBButton;

@interface QBButtonsFactory : NSObject

+ (QBButton *)videoEnable;
+ (QBButton *)auidoEnable;
+ (QBButton *)dynamicEnable;
+ (QBButton *)screenShare;
+ (QBButton *)decline;
+ (QBButton *)circleDecline;
+ (QBButton *)answer;

@end
