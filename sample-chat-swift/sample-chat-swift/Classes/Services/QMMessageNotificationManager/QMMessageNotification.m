//
//  QMMessageNotification.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 5/16/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMMessageNotification.h"

static const NSUInteger kQMMessageNotificationQueueLimit = 5;
static const NSTimeInterval kQMMessageNotificationDuration = 2.0f;

@interface QMMessageNotification ()

@property (strong, nonatomic) MPGNotification *messageNotification;
@property (strong, nonatomic) NSMutableArray *notificationsQueue;

@end

@implementation QMMessageNotification

- (instancetype)init {
    
    if (self = [super init]) {
        
        _notificationsQueue = [NSMutableArray arrayWithCapacity:kQMMessageNotificationQueueLimit];
    }
    
    return self;
}

- (void)showNotificationWithTitle:(NSString *)title
                         subtitle:(NSString *)subtitle
                            color:(UIColor *)color
                        iconImage:(UIImage *)iconImage {
    
    MPGNotification *notification = [MPGNotification notificationWithTitle:title
                                                                  subtitle:subtitle
                                                           backgroundColor:color
                                                                 iconImage:iconImage];
    
    notification.duration = kQMMessageNotificationDuration;
    notification.swipeToDismissEnabled = NO;
    [notification setAnimationType:MPGNotificationAnimationTypeLinear];
    
    [self showNotification:notification usingOneByOneMode:self.isOneByOneMode];
    
}

- (void)showNotification:(MPGNotification*)notification usingOneByOneMode:(BOOL)isOneByOneMode {
    
    __weak __typeof__(self) weakSelf = self;
    
    notification.dismissHandler = ^(MPGNotification *notification_t) {
        
        if (isOneByOneMode) {
            __typeof__(self) strongSelf = weakSelf;
            
            strongSelf.messageNotification = nil;
            [strongSelf.notificationsQueue removeObject:notification_t];
            [strongSelf checkNotificationsToShow];
        }
    };
    
    if (self.messageNotification != nil) {
        
        if (isOneByOneMode) {
            
            if (self.notificationsQueue.count == kQMMessageNotificationQueueLimit) {
                [self.notificationsQueue removeObjectAtIndex:0];
            }
            
            [self.notificationsQueue addObject:notification];
            
            return;
        }
        else {
            [self.messageNotification dismissWithAnimation:NO];
        }
    }
    
    self.messageNotification = notification;
    [self.messageNotification show];
}

- (void)checkNotificationsToShow {
    if (self.notificationsQueue.firstObject) {
        MPGNotification * notification  = self.notificationsQueue.firstObject;
        self.messageNotification = notification;
        [notification show];
    }
}

@end