//
//  QMSoundManager.m
//  Qmunicate
//
//  Created by Andrey Ivanov on 01.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMSoundManager.h"

NSString * const kSystemSoundTypeCAF = @"caf";
NSString * const kSystemSoundTypeAIF = @"aif";
NSString * const kSystemSoundTypeAIFF = @"aiff";
NSString * const kystemSoundTypeWAV = @"wav";

static NSString * const kQMSoundManagerSettingKey = @"kQMSoundManagerSettingKey";

@interface QMSoundManager()

@property (strong, nonatomic) NSMutableDictionary *sounds;
@property (strong, nonatomic) NSMutableDictionary *completionBlocks;

@end

@implementation QMSoundManager

- (void)dealloc {
    
    NSNotificationCenter *notifcationCenter =
    [NSNotificationCenter defaultCenter];
    [notifcationCenter removeObserver:self];
}

void systemServicesSoundCompletion(SystemSoundID  soundID, void *data) {
    
    void(^completion)(void) = [QMSoundManager.instance completionBlockForSoundID:soundID];
    
    if (completion) {
        
        completion();
        [QMSoundManager.instance  removeCompletionBlockForSoundID:soundID];
    }
}

+ (instancetype)instance {
    
    static id instance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        self.on = YES;
        
        _sounds = [NSMutableDictionary dictionary];
        _completionBlocks = [NSMutableDictionary dictionary];
        
        NSNotificationCenter *notifcationCenter =
        [NSNotificationCenter defaultCenter];
        
        [notifcationCenter addObserver:self
                              selector:@selector(didReceiveMemoryWarningNotification:)
                                  name:UIApplicationDidReceiveMemoryWarningNotification
                                object:nil];
    }
    
    return self;
}

- (void)setOn:(BOOL)on {
    
    _on = on;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:on forKey:kQMSoundManagerSettingKey];
    [userDefaults synchronize];
    
    if (!on) {
        
        [self stopAllSounds];
    }
}

#pragma mark - Playing sounds

- (void)playSoundWithName:(NSString *)filename
                extension:(NSString *)extension
                  isAlert:(BOOL)isAlert
               completion:(void(^)(void))completion {
    
    if (!self.on) {
        return;
    }
    
    if (!filename || !extension) {
        return;
    }
    
    if (!self.sounds[filename]) {
        
        [self addSoundIDForAudioFileWithName:filename
                                   extension:extension];
    }
    
    SystemSoundID soundID = [self soundIDForFilename:filename];
    
    if (soundID) {
        
        if (completion) {
            
            OSStatus error =
            AudioServicesAddSystemSoundCompletion(soundID,
                                                  NULL,
                                                  NULL,
                                                  systemServicesSoundCompletion,
                                                  NULL);
            if (error) {
                
                [self logError:error
                   withMessage:@"Warning! Completion block could not be added to SystemSoundID."];
            }
            else {
                
                [self addCompletionBlock:completion
                               toSoundID:soundID];
            }
        }
        
        if (isAlert) {
            
            AudioServicesPlayAlertSound(soundID);
        }
        else {
            
            AudioServicesPlaySystemSound(soundID);
        }
    }
}

- (void)playSoundWithName:(NSString *)filename extension:(NSString *)extension {
    
    [self playSoundWithName:filename
                  extension:extension
                 completion:nil];
}

- (void)playSoundWithName:(NSString *)filename
                extension:(NSString *)extension
               completion:(void(^)(void))completion {
    
    [self playSoundWithName:filename
                  extension:extension
                    isAlert:NO
                 completion:completion];
}

- (void)playAlertSoundWithName:(NSString *)filename
                     extension:(NSString *)extension
                    completion:(void(^)(void))completion {
    
    [self playSoundWithName:filename
                  extension:extension
                    isAlert:YES
                 completion:completion];
}

- (void)playAlertSoundWithName:(NSString *)filename
                     extension:(NSString *)extension {
    
    [self playAlertSoundWithName:filename
                       extension:extension
                      completion:nil];
}

- (void)playVibrateSound {
    
    if (self.on) {
        
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
}

- (void)stopAllSounds {
    
    [self unloadSoundIDs];
}

- (void)stopSoundWithFilename:(NSString *)filename {
    
    SystemSoundID soundID = [self soundIDForFilename:filename];
    NSData *data = [self dataWithSoundID:soundID];
    
    [self unloadSoundIDForFileNamed:filename];
    
    [self.sounds removeObjectForKey:filename];
    [self.completionBlocks removeObjectForKey:data];
}

- (void)preloadSoundWithFilename:(NSString *)filename
                       extension:(NSString *)extension {
    
    if (!self.sounds[filename]) {
        [self addSoundIDForAudioFileWithName:filename
                                   extension:extension];
    }
}

#pragma mark - Sound data

- (NSData *)dataWithSoundID:(SystemSoundID)soundID {
    
    return [NSData dataWithBytes:&soundID
                          length:sizeof(SystemSoundID)];
}

- (SystemSoundID)soundIDFromData:(NSData *)data {
    
    if (data) {
        
        SystemSoundID soundID;
        [data getBytes:&soundID length:sizeof(SystemSoundID)];
        return soundID;
    }
    
    return 0;
}

#pragma mark - Sound files

- (SystemSoundID)soundIDForFilename:(NSString *)filenameKey {
    
    NSData *soundData = self.sounds[filenameKey];
    return [self soundIDFromData:soundData];
}

- (void)addSoundIDForAudioFileWithName:(NSString *)filename
                             extension:(NSString *)extension {
    
    SystemSoundID soundID = [self createSoundIDWithName:filename
                                              extension:extension];
    if (soundID) {
        
        NSData *data = [self dataWithSoundID:soundID];
        self.sounds[filename] = data;
    }
}

#pragma mark - Sound completion blocks

- (void(^)(void))completionBlockForSoundID:(SystemSoundID)soundID {
    
    NSData *data = [self dataWithSoundID:soundID];
    return self.completionBlocks[data];
}

- (void)addCompletionBlock:(void(^)(void))block
                 toSoundID:(SystemSoundID)soundID {
    
    NSData *data = [self dataWithSoundID:soundID];
    self.completionBlocks[data] = [block copy];
}

- (void)removeCompletionBlockForSoundID:(SystemSoundID)soundID {
    
    NSData *key = [self dataWithSoundID:soundID];
    [self.completionBlocks removeObjectForKey:key];
    AudioServicesRemoveSystemSoundCompletion(soundID);
}

#pragma mark - Managing sounds

- (SystemSoundID)createSoundIDWithName:(NSString *)filename
                             extension:(NSString *)extension {
    
    NSURL *fileURL = [[NSBundle mainBundle] URLForResource:filename
                                             withExtension:extension];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[fileURL path]]) {
        
        SystemSoundID soundID;
        OSStatus error = AudioServicesCreateSystemSoundID((__bridge CFURLRef)fileURL, &soundID);
        
        if (error) {
            [self logError:error withMessage:@"Warning! SystemSoundID could not be created."];
            return 0;
        }
        else {
            return soundID;
        }
    }
    
    NSLog(@"Error: audio file not found at URL: %@", fileURL);
    
    return 0;
}

- (void)unloadSoundIDs {
    
    for(NSString *eachFilename in [_sounds allKeys]) {
        [self unloadSoundIDForFileNamed:eachFilename];
    }
    
    [self.sounds removeAllObjects];
    [self.completionBlocks removeAllObjects];
}

- (void)unloadSoundIDForFileNamed:(NSString *)filename {
    
    SystemSoundID soundID = [self soundIDForFilename:filename];
    
    if(soundID) {
        AudioServicesRemoveSystemSoundCompletion(soundID);
        
        OSStatus error = AudioServicesDisposeSystemSoundID(soundID);
        
        if(error) {
            
            [self logError:error withMessage:@"Warning! SystemSoundID could not be disposed."];
        }
    }
}

- (void)logError:(OSStatus)error withMessage:(NSString *)message {
    
    NSString *errorMessage = nil;
    
    switch (error) {
            
        case kAudioServicesUnsupportedPropertyError: errorMessage = @"The property is not supported."; break;
        case kAudioServicesBadPropertySizeError: errorMessage = @"The size of the property data was not correct."; break;
        case kAudioServicesBadSpecifierSizeError: errorMessage = @"The size of the specifier data was not correct."; break;
        case kAudioServicesSystemSoundUnspecifiedError:errorMessage = @"An unspecified error has occurred."; break;
        case kAudioServicesSystemSoundClientTimedOutError: errorMessage = @"System sound client message timed out."; break;
    }
    
    NSLog(@"%@ Error: (code %d) %@", message, (int)error, errorMessage);
}

#pragma mark - Did Receive Memory Warning Notification

- (void)didReceiveMemoryWarningNotification:(NSNotification *)notification {
    
    [self unloadSoundIDs];
}

#pragma mark - Default sounds

NSString *const kQMCallingSoundName = @"calling";
NSString *const kQMBusySoundName = @"busy";
NSString *const kQMEndOfCallSoundName = @"end_of_call";
NSString *const kQMRingtoneSoundName = @"ringtone";

+ (void)playCallingSound {
    
    [QMSysPlayer playSoundWithName:kQMCallingSoundName
                         extension:kystemSoundTypeWAV];
}

+ (void)playBusySound {
    
    [QMSysPlayer playSoundWithName:kQMBusySoundName
                         extension:kystemSoundTypeWAV];
}

+ (void)playEndOfCallSound {
    
    [QMSysPlayer playSoundWithName:kQMEndOfCallSoundName
                         extension:kystemSoundTypeWAV];
}

+ (void)playRingtoneSound {
    
    [QMSysPlayer playAlertSoundWithName:kQMRingtoneSoundName
                              extension:kystemSoundTypeWAV];
}

@end
