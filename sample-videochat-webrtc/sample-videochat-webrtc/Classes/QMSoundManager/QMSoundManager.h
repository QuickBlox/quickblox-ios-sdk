//
//  QMSoundManager.h
//  Qmunicate
//
//  Created by Andrey Ivanov on 01.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QMSoundManager : NSObject

@property (assign, nonatomic) BOOL on;

// MARK: Initializers
+ (instancetype)instance;

/**
 *  Plays a system sound object corresponding to an audio file with the given filename and extension.
 *  The system sound player will lazily initialize and load the file before playing it, and then cache its corresponding `SystemSoundID`.
 *  If this file has previously been played, it will be loaded from cache and played immediately.
 *
 *  @param filename      A string containing the base name of the audio file to play.
 *  @param fileExtension A string containing the extension of the audio file to play.
 *  This parameter must be one of `caf`, `aif`, `aiff`, or `wav`
 *
 *  @warning If the system sound object cannot be created, this method does nothing.
 */
- (void)playSoundWithName:(NSString *)filename
                extension:(NSString *)extension;

/**
 *  Plays a system sound object corresponding to an audio file with the given filename and extension,
 *  and excutes completionBlock when the sound has stopped playing.
 *  The system sound player will lazily initialize and load the file before playing it, and then cache its corresponding `SystemSoundID`.
 *  If this file has previously been played, it will be loaded from cache and played immediately.
 *
 *  @param filename      A string containing the base name of the audio file to play.
 *  @param fileExtension A string containing the extension of the audio file to play.
 *  This parameter must be one of `caf`, `aif`, `aiff`, or `wav`
 *
 *  @param completion A block called after the sound has stopped playing.
 *
 *  @warning If the system sound object cannot be created, this method does nothing.
*/
- (void)playSoundWithName:(NSString *)filename
                extension:(NSString *)extension
               completion:(void(^)(void))completion;

/**
 *  Plays a system sound object *as an alert* corresponding to an audio file with the given filename and extension.
 *  The system sound player will lazily initialize and load the file before playing it, and then cache its corresponding `SystemSoundID`.
 *  If this file has previously been played, it will be loaded from cache and played immediately.
 *
 *  @param filename     A string containing the base name of the audio file to play.
 *  @param extension    A string containing the extension of the audio file to play.
 *  This parameter must be one of `caf`, `aif`, `aiff`, or `wav
 *
 *  @warning If the system sound object cannot be created, this method does nothing.
 *
 *  @warning This method performs the same functions as `playSoundWithName: extension:`, with the excepion that,
 *  depending on the particular iOS device, this method may invoke vibration.
 */

- (void)playAlertSoundWithName:(NSString *)filename
                     extension:(NSString *)extension;
/**
 *  Plays a system sound object *as an alert* corresponding to an audio file with the given filename and extension,
 *  and and executes completionBlock when the sound has stopped playing.
 *  The system sound player will lazily initialize and load the file before playing it, and then cache its corresponding `SystemSoundID`.
 *  If this file has previously been played, it will be loaded from cache and played immediately.
 *
 *  @param filename     A string containing the base name of the audio file to play.
 *  @param extension    A string containing the extension of the audio file to play.
 *  This parameter must be one of `caf`, `aif`, `aiff`, or `wav`.
 *
 *  @param completion A block called after the sound has stopped playing.
 *
 *  @warning If the system sound object cannot be created, this method does nothing.
 *
 *  @warning This method performs the same functions as `playSoundWithName: extension: completion:`,
 *  with the excepion that, depending on the particular iOS device, this method may invoke vibration.
 */
- (void)playAlertSoundWithName:(NSString *)filename
                     extension:(NSString *)extension
                    completion:(void(^)(void))completion;

/**
 *  On some iOS devices, you can call this method to invoke vibration.
 *  On other iOS devices this functionaly is not available, and calling this method does nothing.
 */
- (void)playVibrateSound;

/**
 *  Stops playing all sounds immediately.
 *
 *  @warning Any completion blocks attached to any currently playing sound will *not* be executed.
 *  Also, calling this method will purge all `SystemSoundID` objects from cache, regardless of whether or not they were currently playing.
 */
- (void)stopAllSounds;

/**
 *  Stops playing the sound with the given filename immediately.
 *
 *  @param filename The filename of the sound to stop playing.
 *
 *  @warning If a completion block is attached to the given sound, it will *not* be executed.
 *  Also, calling this method will purge the `SystemSoundID` object for this file from cache, regardless of whether or not it was currently playing.
 */
- (void)stopSoundWithFilename:(NSString *)filename;

/**
 *  Preloads a system sound object corresponding to an audio file with the given filename and extension.
 *  The system sound player will initialize, load, and cache the corresponding `SystemSoundID`.
 *
 *  @param filename      A string containing the base name of the audio file to play.
 *  @param fileExtension A string containing the extension of the audio file to play.
 *  This parameter must be one of `caf`, `aif`, `aiff`, or `wav`.
 */
- (void)preloadSoundWithFilename:(NSString *)filename
                       extension:(NSString *)extension;

// MARK: Preset sounds

+ (void)playCallingSound;
+ (void)playBusySound;
+ (void)playEndOfCallSound;
+ (void)playRingtoneSound;

@end
