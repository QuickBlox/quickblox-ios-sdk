//
//  QBRTCScreenCapture.h
//  QuickbloxWebRTC
//
//  Created by Andrey Ivanov on 08/10/15.
//  Copyright © 2015 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Class implements screen sharing and converting screenshots to destination format
 *  in order to send frames to your opponents
 */
@interface QBRTCScreenCapture: QBRTCVideoCapture

/**
 * Initialize a video capturer view and start grabbing content of given view
 */
- (instancetype)initWithView:(UIView *)view;

@end
