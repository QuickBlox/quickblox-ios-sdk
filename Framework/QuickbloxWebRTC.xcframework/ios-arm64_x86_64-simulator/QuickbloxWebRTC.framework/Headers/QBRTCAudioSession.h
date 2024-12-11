//
//  QBRTCAudioSession.h
//  QuickbloxWebRTC
//
//  Copyright (c) 2018 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import <QuickbloxWebRTC/QBRTCAudioSessionDelegate.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  This is a protocol used to inform QBRTCAudioSession when the audio session
 *  activation state has changed outside of QBRTCAudioSession. The current known use
 *  case of this is when CallKit activates the audio session for the application
 */
@protocol QBRTCAudioSessionActivationDelegate <NSObject>

/**
 *  Called when the audio session is activated outside of the app by iOS.
 */
- (void)audioSessionDidActivate:(AVAudioSession *)session;

/**
 *  Called when the audio session is deactivated outside of the app by iOS.
 */
- (void)audioSessionDidDeactivate:(AVAudioSession *)session;

/**
 *  Called in order to determine whether audio session was activated ourside of the app by iOS and is still active.
 */
- (BOOL)audioSessionIsActivatedOutside:(AVAudioSession *)session;

@end

/**
 *  QBRTCAudioSession class interface.
 *  This class is used to manage and configure audio session of web rtc including sound route management.
 */

@interface QBRTCAudioSession : NSObject <QBRTCAudioSessionActivationDelegate>

/**
 *  QBRTCAudioSession class shared instance.
 *
 *  @return QBRTCAudioSession shared instance
 */
+ (instancetype)instance;

// Unavailable initializers
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

/**
*  Detected whether the session is active based on results of calls to
*  AVAudioSession.
*/
@property (nonatomic, readonly, getter=isActive) BOOL active;

/**
 *  If YES, WebRTC will not initialize the audio unit automatically when an
 *  audio track is ready for playout or recording. Instead, applications should
 *  call setAudioEnabled. If NO, WebRTC will initialize the audio unit
 *  as soon as an audio track is ready for playout or recording.
 *
 *  @remark Default value is NO.
 */
@property (assign, nonatomic) BOOL useManualAudio;

/**
 *  This property is only effective if useManualAudio is YES.
 *  Represents permission for WebRTC to initialize the VoIP audio unit.
 *  When set to NO, if the VoIP audio unit used by WebRTC is active, it will be
 *  stopped and uninitialized. This will stop incoming and outgoing audio.
 *  When set to YES, WebRTC will initialize and start the audio unit when it is
 *  needed (e.g. due to establishing an audio connection).
 *  This property was introduced to work around an issue where if an AVPlayer is
 *  playing audio while the VoIP audio unit is initialized, its audio would be
 *  either cut off completely or played at a reduced volume. By preventing
 *  the audio unit from being initialized until after the audio has completed,
 *  we are able to prevent the abrupt cutoff.
 *
 *  @remark Default value is NO.
 */
@property (assign, nonatomic, getter=isAudioEnabled) BOOL audioEnabled;

/**
 *  If |active|, activates the audio session if it isn't already active.
 *  Successful calls must be balanced with a setActive:NO when activation is no
 *  longer required. If not |active|, deactivates the audio session if one is
 *  active and this is the last balanced call. When deactivating, the
 *  AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation option is passed to
 *  AVAudioSession.
*/
- (BOOL)setActive:(BOOL)isActive;

/**
 *  Add class that conforms to QBRTCAudioSessionDelegate protocol to observer list.
 *
 *  @param delegate Class that conforms to QBRTCAudioSessionDelegate.
 */
- (void)addDelegate:(id<QBRTCAudioSessionDelegate>)delegate;

/**
 *  Remove class that conforms to QBRTCAudioSessionDelegate protocol from observers list.
 *
 *  @param delegate Class that conforms to QBRTCAudioSessionDelegate
 */
- (void)removeDelegate:(id<QBRTCAudioSessionDelegate>)delegate;

/**
 *  List of added delegates.
 *
 *  @return List of delegates that were added to observer's list.
 */
- (NSArray *)delegates;

/**
 *  This method are proxies for the associated methods on AVAudioSession.
 */
- (BOOL)overrideOutputAudioPort:(AVAudioSessionPortOverride)portOverride;

/**
 *  Applies the configuration to the current session.
 *
 *  @param configuration the object to setup session configuration.
 *
 *  @discussion To set the default configuration use [[QBRTCAudioSessionConfiguration alloc] init].
 *
 *  @see QBRTCAudioSessionConfiguration class.
 *
 *  @return Boolean value of whether operation was successful
 */
- (BOOL)setConfiguration:(QBRTCAudioSessionConfiguration * _Nonnull)configuration;

/**
 *  Convenience method that calls both setConfiguration and setActive.
 */
- (BOOL)setConfiguration:(QBRTCAudioSessionConfiguration * _Nonnull)configuration
                  active:(BOOL)active;

@end

NS_ASSUME_NONNULL_END
