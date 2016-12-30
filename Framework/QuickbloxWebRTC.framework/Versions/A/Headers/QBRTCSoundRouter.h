//
//  QBRTCSoundRouter.h
//  QuickbloxWebRTC
//
//  Copyright (c) 2016 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, QBRTCSoundRoute) {
    
    QBRTCSoundRouteNotDefined,
    QBRTCSoundRouteSpeaker,
    QBRTCSoundRouteReceiver
} DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.3. Use QBRTCAudioSession class instead.");

/**
 *  Class used to manage audio routes
 *  To change output from speaker to receiver(headset) use currentSoundRoute property.
 *
 *  @warning *Deprecated in 2.3.* Use QBRTCAudioSession class instead.
 */
DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.3. Use QBRTCAudioSession class instead.")
@interface QBRTCSoundRouter : NSObject

- (instancetype)init __attribute__((unavailable("init is not a supported initializer for this class.")));

/**
 *  @warning *Deprecated in 2.3.* Use 'instance' of QBRTCAudioSession class instead.
 *  @return QBRTCSoundRouter instance
 */
+ (instancetype)instance DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.3. Use 'instance' QBRTCAudioSession class instead.");

/**
 *  Shows if we have saved current audio router settings with -initialize method
 *
 *  @warning *Deprecated in 2.3.* Use 'isInitialized' QBRTCAudioSession class instead.
 *
 *  @return YES if we successfully called -initialize method before, NO otherwise
 */
- (BOOL)isActive DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.3. Use 'isInitialized' of QBRTCAudioSession class instead.");

/**
 *  Call this method when you want to start a call and you want to save current audio router settings
 *
 *  @warning *Deprecated in 2.3.* Use 'initialize' QBRTCAudioSession class instead.
 *
 *  @return YES if success, NO if router failed to save current audio settings
 */
- (BOOL)initialize DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.3. Use 'initialize' of QBRTCAudioSession class instead.");

/**
 *  call this method when you want to restore previously saved audio router settings saved with "-initialize" method
 *
 *  @warning *Deprecated in 2.3.* Use 'deinitialize' QBRTCAudioSession class instead.
 *
 *  @return YES if audio router settings is successfully restored to initial state, NO if router can not restore
 */
- (BOOL)deinitialize DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.3. Use 'deinitialize' of QBRTCAudioSession class instead.");

/**
 *  @warning *Deprecated in 2.3.* No longer in use due to QBRTCAudioSession class manages headphones and other devices transition by itself.
 *
 *  @return YES if headset or headphones are plugged in
 */
@property (assign, nonatomic, readonly) BOOL isHeadsetPluggedIn DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.3. No longer in use due to QBRTCAudioSession class manages headphones and other devices transition by itself.");

/**
 *  @warning *Deprecated in 2.3.* Use 'currentAudioDevice' of QBRTCAudioSession class instead.
 *  @return QBRTCSoundRouteReceiver, QBRTCSoundRouteSpeaker, or QBRTCSoundRouteNotDefined if there is a problem
 */
@property (assign, nonatomic) QBRTCSoundRoute currentSoundRoute DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.3. Use 'currentAudioDevice' of QBRTCAudioSession class instead.");

@end
