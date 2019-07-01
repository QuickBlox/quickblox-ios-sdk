//
//  SoundManager.m
//  Qmunicate
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "SoundManager.h"
#import "Log.h"

static NSString * const kSystemSoundTypeCAF = @"caf";
static NSString * const kSystemSoundTypeAIF = @"aif";
static NSString * const kSystemSoundTypeAIFF = @"aiff";
static NSString * const kystemSoundTypeWAV = @"wav";

static NSString * const kSoundManagerSettingKey = @"kSoundManagerSettingKey";

@interface SoundManager() {
    
    NSMutableDictionary *_sounds;
    NSMutableDictionary *_completionBlocks;
    BOOL _audioDeviceChanged;
}

@end

@implementation SoundManager

- (void)dealloc {
    
    NSNotificationCenter *notifcationCenter =
    [NSNotificationCenter defaultCenter];
    [notifcationCenter removeObserver:self];
}

void systemServicesSoundCompletion(SystemSoundID  soundID, void *data) {
    
    void(^completion)(void) = [SoundManager.instance completionBlockForSoundID:soundID];
    
    if (completion) {
        
        completion();
        [SoundManager.instance  removeCompletionBlockForSoundID:soundID];
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
    [userDefaults setBool:on forKey:kSoundManagerSettingKey];
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
    
    if (!_sounds[filename]) {
        
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
    
    [_sounds removeObjectForKey:filename];
    [_completionBlocks removeObjectForKey:data];
}

- (void)preloadSoundWithFilename:(NSString *)filename
                       extension:(NSString *)extension {
    
    if (!_sounds[filename]) {
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
    
    NSData *soundData = _sounds[filenameKey];
    return [self soundIDFromData:soundData];
}

- (void)addSoundIDForAudioFileWithName:(NSString *)filename
                             extension:(NSString *)extension {
    
    SystemSoundID soundID = [self createSoundIDWithName:filename
                                              extension:extension];
    if (soundID) {
        
        NSData *data = [self dataWithSoundID:soundID];
        _sounds[filename] = data;
    }
}

#pragma mark - Sound completion blocks

- (void(^)(void))completionBlockForSoundID:(SystemSoundID)soundID {
    
    NSData *data = [self dataWithSoundID:soundID];
    return _completionBlocks[data];
}

- (void)addCompletionBlock:(void(^)(void))block
                 toSoundID:(SystemSoundID)soundID {
    
    NSData *data = [self dataWithSoundID:soundID];
    _completionBlocks[data] = [block copy];
}

- (void)removeCompletionBlockForSoundID:(SystemSoundID)soundID {
    
    NSData *key = [self dataWithSoundID:soundID];
    [_completionBlocks removeObjectForKey:key];
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
    Log(@"[%@] Error: audio file not found at URL: %@",  NSStringFromClass([SoundManager class]), fileURL);
    
    return 0;
}

- (void)unloadSoundIDs {
    
    for(NSString *eachFilename in [_sounds allKeys]) {
        [self unloadSoundIDForFileNamed:eachFilename];
    }
    
    [_sounds removeAllObjects];
    [_completionBlocks removeAllObjects];
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

    Log(@"[%@] %@ Error: (code %d) %@",  NSStringFromClass([SoundManager class]), message, (int)error, errorMessage);
}

#pragma mark - Did Receive Memory Warning Notification

- (void)didReceiveMemoryWarningNotification:(NSNotification *)notification {
    
    [self unloadSoundIDs];
}

#pragma mark - Default sounds

NSString *const kCallingSoundName = @"calling";
NSString *const kBusySoundName = @"busy";
NSString *const kEndOfCallSoundName = @"end_of_call";
NSString *const kRingtoneSoundName = @"ringtone";

+ (void)playCallingSound {
    
    [[SoundManager instance] playSoundWithName:kCallingSoundName
                                       extension:kystemSoundTypeWAV];
}

+ (void)playBusySound {
    
    [[SoundManager instance] playSoundWithName:kBusySoundName
                                       extension:kystemSoundTypeWAV];
}

+ (void)playEndOfCallSound {
    
    [[SoundManager instance] playSoundWithName:kEndOfCallSoundName
                                       extension:kystemSoundTypeWAV];
}

+ (void)playRingtoneSound {
    
    [[SoundManager instance] playAlertSoundWithName:kRingtoneSoundName
                                            extension:kystemSoundTypeWAV];
}

@end
