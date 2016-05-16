//
//  QMMessageNotificationManager.m
//  sample-chat
//
//  Created by Vitaliy Gurkovsky on 5/16/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMMessageNotificationManager.h"
#import "QMMessageNotification.h"

@implementation QMMessageNotificationManager

#pragma mark - Message notification

+ (void)showNotificationWithTitle:(NSString*)title
                         subtitle:(NSString*)subtitle
                            color:(UIColor*)color
                        iconImage:(UIImage*)iconImage {
    
    [messageNotification() showNotificationWithTitle:title
                                            subtitle:subtitle
                                               color:color
                                           iconImage:iconImage];
}

#pragma mark - Static notifications

QMMessageNotification *messageNotification() {
    
    static QMMessageNotification *messageNotification = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        messageNotification = [[QMMessageNotification alloc] init];
        messageNotification.oneByOneMode = YES;
    });
    
    return messageNotification;
}

@end
