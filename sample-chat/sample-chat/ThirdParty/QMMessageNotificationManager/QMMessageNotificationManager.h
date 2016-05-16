//
//  QMMessageNotificationManager.h
//  sample-chat
//
//  Created by Vitaliy Gurkovsky on 5/16/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

typedef NS_ENUM (NSUInteger, QMMessageNotificationType) {
    QMMessageNotificationTypeInfo = 0,
    QMMessageNotificationTypeWarning = 1,
    QMMessageNotificationTypeError = 2
};

/**
 *  Manager for notifications' sending inside the application
 */
@interface QMMessageNotificationManager : NSObject

/**
 *  Show notification with title, subtitle and type
 *
 *  @param title    Notification title
 *  @param subtitle Notification subtitle
 */
+ (void)showNotificationWithTitle:(NSString*)title
                         subtitle:(NSString*)subtitle
                             type:(QMMessageNotificationType)type;

/**
 *  Show notification with title, subtitle and custom parameters
 *
 *  @param title    Notification title
 *  @param subtitle Notification subtitle
 *  @param color    Notification background color
 *  @param iconImage Notification icon image
  */
+ (void)showNotificationWithTitle:(NSString*)title
                         subtitle:(NSString*)subtitle
                            color:(UIColor*)color
                        iconImage:(UIImage*)iconImage;
/**
 *  Enable or disable oneByOne notification mode
 *
 *  @param enabled
 */
+ (void)oneByOneModeSetEnabled:(BOOL)enabled;

@end
