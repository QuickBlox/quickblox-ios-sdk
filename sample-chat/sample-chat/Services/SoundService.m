//
//  SoundService.m
//  sample-chat
//
//  Created by Igor Khomenko on 4/27/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import "SoundService.h"

@implementation SoundService

+ (instancetype)instance{
    static id instance_ = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance_ = [[self alloc] init];
    });
    
    return instance_;
}

static SystemSoundID soundID;
- (void)playNotificationSound {
    if(soundID == 0){
        NSString *path = [NSString stringWithFormat: @"%@/sound.mp3", [[NSBundle mainBundle] resourcePath]];
        NSURL *filePath = [NSURL fileURLWithPath: path isDirectory: NO];
        
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)filePath, &soundID);
    }
    
    AudioServicesPlaySystemSound(soundID);
}

@end
