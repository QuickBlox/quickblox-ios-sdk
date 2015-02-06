//
//  QMSoundManager.h
//  Qmunicate
//
//  Created by Andrey Ivanov on 01.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^QMSoundManagerCompletionBlock)(void);

@interface QMSoundManager : NSObject

@property (assign, nonatomic, readonly) BOOL on;

+ (QMSoundManager *)shared;

- (void)toggleSoundPlayerOn:(BOOL)on;
- (void)playSoundWithName:(NSString *)filename extension:(NSString *)extension;
- (void)playSoundWithName:(NSString *)filename
                extension:(NSString *)extension
               completion:(QMSoundManagerCompletionBlock)completionBlock;
- (void)playAlertSoundWithName:(NSString *)filename extension:(NSString *)extension;
- (void)playAlertSoundWithName:(NSString *)filename
                     extension:(NSString *)extension
                    completion:(QMSoundManagerCompletionBlock)completionBlock;
- (void)playVibrateSound;
- (void)stopAllSounds;
- (void)stopSoundWithFilename:(NSString *)filename;
- (void)preloadSoundWithFilename:(NSString *)filename extension:(NSString *)extension;
/*Default sounds*/
+ (void)playCallingSound;
+ (void)playBusySound;
+ (void)playEndOfCallSound;
+ (void)playRingtoneSound;

@end
