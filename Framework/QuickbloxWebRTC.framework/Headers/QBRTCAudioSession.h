//
//  QBRTCAudioSession.h
//  QuickbloxWebRTC
//
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QBRTCAudioSession;
@class QBRTCAudioSessionConfiguration;

/**
 *  Audio devices enumeration.
 *
 *  - QBRTCAudioDeviceNotSpecified: When audio session is not initialized
 *  - QBRTCAudioDeviceReceiver: Receiver device (default for devices that have receiver)
 *  - QBRTCAudioDeviceSpeaker: Speaker device (can't be used on tvOS and watchOS)
 */
typedef NS_ENUM(NSUInteger, QBRTCAudioDevice) {
    
    QBRTCAudioDeviceNotSpecified,
    QBRTCAudioDeviceReceiver,
    QBRTCAudioDeviceSpeaker __TVOS_PROHIBITED __WATCHOS_PROHIBITED
};

NS_ASSUME_NONNULL_BEGIN

/**
 *  QBRTCAudioSessionDelegate protocol.
 *  Notifying about important audio session events.
 */
@protocol QBRTCAudioSessionDelegate <NSObject>

/**
 *  Protocol methods down below are optional and can be skipped in protocol implementation.
 */
@optional

/**
 *  Notifying about current audio device being updated by QBRTCAudioSession.
 *
 *  @param audioSession        QBRTCAudioSession instance
 *  @param updatedAudioDevice  new audio device
 *
 *  @discussion Called, for example, when headphones plugged in. In that case audio will automatically be updated from speaker/receiver to headphones. Headphones are considered to be receiver. You can use this delegate to keep your current audio device state up-to-date in your UI.
 *
 *  @note Only called if audio device was changed by QBRTCAudioSession itself, and not on user request.
 */
- (void)audioSession:(QBRTCAudioSession *)audioSession didChangeCurrentAudioDevice:(QBRTCAudioDevice)updatedAudioDevice;

/**
 *  Notifying when audio device change on user request was failed.
 *
 *  @param audioSession QBRTCAudioSession instance
 *  @param error        error
 *
 *  @discussion Called when audio device change is not possible. For example, when audio session options set to speaker only, you cannot update device to receiver, etc.
 */
- (void)audioSession:(QBRTCAudioSession *)audioSession didFailToChangeAudioDeviceWithError:(NSError *)error;

/**
 *  Called when the audio device is notified to begin playback or recording.
 *
 *  @param audioSession QBRTCAudioSesson instance.
 */
- (void)audioSessionDidStartPlayOrRecord:(QBRTCAudioSession *)audioSession;

/**
 *  Called when the audio device is notified to stop playback or recording.
 *
 *  @param audioSession QBRTCAudioSesson instance.
 */
- (void)audioSessionDidStopPlayOrRecord:(QBRTCAudioSession *)audioSession;

/**
 *  Called when AVAudioSession starts an interruption event.
 *
 *  @param session QBRTCAudioSession instance
 */
- (void)audioSessionDidBeginInterruption:(QBRTCAudioSession *)session;

/**
 *  Called when AVAudioSession ends an interruption event.
 *
 *  @param session QBRTCAudioSession instance
 */
- (void)audioSessionDidEndInterruption:(QBRTCAudioSession *)session shouldResumeSession:(BOOL)shouldResumeSession;

@end

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

// MARK: Properties

/**
 *  Determines whether QBRTCAudioSession is initialized and have saved previous active audio session settings.
 */
@property (nonatomic, readonly, getter=isInitialized) BOOL initialized;

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
 *  Current audio device.
 *
 *  @remark QBRTCAudioDeviceNotSpecified if not initialized
 *
 *  @discussion Change this property value in order to change current audio device.
 *
 *  @note Audio device change is being performed on background thread and is not an instant operation.
 *  Cannot be changed if QBRTCAudioSession is not initialized.
 */
@property (assign, nonatomic) QBRTCAudioDevice currentAudioDevice;

// MARK: Instance

/**
 *  QBRTCAudioSession class shared instance.
 *
 *  @return QBRTCAudioSession shared instance
 */
+ (instancetype)instance;

// Unavailable initializers
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

// MARK: QBRTCAudioSessionDelegate

/**
 *  Add class that conforms to QBRTCAudioSessionDelegate protocol to observer list.
 *
 *  @param delegate Class that conforms to QBRTCAudioSessionDelegate
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

// MARK: Initialize and configuration

/**
 *  Initialize audio session if not initialized yet.
 *
 *  @discussion Initialization of QBRTCAudioSession will perform configuration of AVAudioSession shared instance.
 *  using suggested default QBRTCAudioSessionConfiguration settings. Use 'initializeWithConfigurationBlock:' method
 *  to perform in-depth audio session configuration.
 *
 *  @note Previous configuration will be saved. In order to restore it deinitialize QBRTCAudioSession using
 *  'deinitialize' method.
 *
 *  @code
 [[QBRTCAudioSession instance] initializeWithConfigurationBlock:^(QBRTCAudioSessionConfiguration *configuration) {
 // adding blutetooth support
 configuration.categoryOptions |= AVAudioSessionCategoryOptionAllowBluetooth;
 configuration.categoryOptions |= AVAudioSessionCategoryOptionAllowBluetoothA2DP;
 
 // adding airplay support
 configuration.categoryOptions |= AVAudioSessionCategoryOptionAllowAirPlay;
 
 if (_session.conferenceType == QBRTCConferenceTypeVideo) {
 // setting mode to video chat to enable airplay audio and speaker only
 configuration.mode = AVAudioSessionModeVideoChat;
 }
 }];
 *  @endcode
 *
 *  @return Boolean value of whether operation was successful
 */
- (BOOL)initialize;

/**
 *  Initialize audio session if not initialized yet using configuration block.
 *
 *  @param configurationBlock configuration block
 *
 *  @see QBRTCAudioSessionConfiguration class.
 *
 *  @return Boolean value of whether operation was successful
 */
- (BOOL)initializeWithConfigurationBlock:(nullable void(^)(QBRTCAudioSessionConfiguration *configuration))configurationBlock;

/**
 *  Deinitialize QBRTCAudioSession.
 *
 *  @note Previous AVAudioSession configuration will be restored (which was saved upon
 *  QBRTCAudioSession initialization).
 *
 *  @return Boolean value of whether operation was successful
 */
- (BOOL)deinitialize;

@end

NS_ASSUME_NONNULL_END
