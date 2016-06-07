//
//  QMMessageNotificationManager.h
//  sample-chat
//
//  Created by Vitaliy Gurkovsky on 5/16/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QMMessageNotificationManager : NSObject

+ (void)showNotificationWithTitle:(NSString*)title
                         subtitle:(NSString*)subtitle
                            color:(UIColor*)color
                        iconImage:(UIImage*)iconImage;

+ (void)oneByOneModeSetEnabled:(BOOL)enabled;

@end
