//
//  QMMessageNotification.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 5/16/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMMessageNotification.h"

static const NSTimeInterval kQMMessageNotificationDuration = 2.0f;

@interface QMMessageNotification ()

@property (strong, nonatomic) MPGNotification *messageNotification;
@property (strong, nonatomic) NSMutableArray * notificationsQueue;

@end

@implementation QMMessageNotification

- (instancetype)init {
    if (self = [super init]) {
        _notificationsQueue = [NSMutableArray array];
    }
    return self;
}

- (void)showNotificationWithTitle:(NSString*)title
                         subtitle:(NSString*)subtitle
                            color:(UIColor*)color
                        iconImage:(UIImage*)iconImage {
    
    MPGNotification * notification = [MPGNotification notificationWithTitle:title
                                                                   subtitle:subtitle
                                                            backgroundColor:color
                                                                  iconImage:iconImage];
    
    notification.duration = kQMMessageNotificationDuration;
    notification.swipeToDismissEnabled = NO;
    [notification setAnimationType:MPGNotificationAnimationTypeLinear];
    [self showNotification:notification usingOneByOneMode:self.isOneByOneMode];
    
}

- (void)showNotification:(MPGNotification*)notification usingOneByOneMode:(BOOL)isOneByOneMode {
    
    if (isOneByOneMode) {
        
        __weak __typeof__(self) weakSelf = self;
        
        notification.dismissHandler = ^(MPGNotification *notification) {
            
            __typeof__(self) strongSelf = weakSelf;
            
            [strongSelf.notificationsQueue removeObject:notification];
            [strongSelf checkNotificationsToShow];
            strongSelf.messageNotification = nil;
        };
    }
    
    if (self.messageNotification != nil) {
        
        if (isOneByOneMode) {
            [self.notificationsQueue addObject:notification];
        }
        else {
            [self.messageNotification dismissWithAnimation:NO];
        }
        
    }
    else {
        self.messageNotification = notification;
        [self.messageNotification show];
    }
}

- (void)checkNotificationsToShow {
    if (self.notificationsQueue.lastObject) {
        MPGNotification * notification  = self.notificationsQueue.lastObject;
        self.messageNotification = notification;
        [notification show];
    }
}

@end