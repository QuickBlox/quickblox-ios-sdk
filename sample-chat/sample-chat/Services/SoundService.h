//
//  SoundService.h
//  sample-chat
//
//  Created by Igor Khomenko on 4/27/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SoundService : NSObject

+ (instancetype)instance;

- (void)playNotificationSound;

@end
