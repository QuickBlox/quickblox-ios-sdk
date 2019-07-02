//
//  ScreenCapture.h
//  sample-videochat-webrtc
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Class implements screen sharing and converting screenshots to destination format
 *  in order to send frames to your opponents
 */
@interface ScreenCapture: QBRTCVideoCapture

/**
 * Initialize a video capturer view and start grabbing content of given view
 */
- (instancetype)initWithView:(UIView *)view;

@end
