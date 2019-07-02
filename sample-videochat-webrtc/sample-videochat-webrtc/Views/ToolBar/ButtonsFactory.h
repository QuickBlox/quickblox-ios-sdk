//
//  ButtonsFactory.h
//  sample-videochat-webrtc
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Button;

@interface ButtonsFactory : NSObject

+ (Button *)videoEnable;
+ (Button *)auidoEnable;
+ (Button *)dynamicEnable;
+ (Button *)screenShare;
+ (Button *)decline;
+ (Button *)circleDecline;
+ (Button *)answer;

@end
