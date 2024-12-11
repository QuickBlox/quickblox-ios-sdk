//
//  QBRTCAudioSessionDelegate.h
//  QuickbloxWebRTC
//
//  Created by Injoit on 22.03.2020.
//  Copyright © 2020 QuickBlox Team. All rights reserved.
//

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
 *  @param shouldResumeSession whether session should resume
 */
- (void)audioSessionDidEndInterruption:(QBRTCAudioSession *)session shouldResumeSession:(BOOL)shouldResumeSession;

/**
 *  Called when the AVAudioSession output volume value changes.
 *
 *  @param audioSession QBRTCAudioSession instance
 *  @param outputVolume output volume value
 */
- (void)audioSession:(QBRTCAudioSession *)audioSession didChangeOutputVolume:(float)outputVolume;

@end

NS_ASSUME_NONNULL_END
