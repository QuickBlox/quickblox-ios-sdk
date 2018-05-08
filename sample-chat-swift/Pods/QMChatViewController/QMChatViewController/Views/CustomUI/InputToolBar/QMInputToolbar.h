//
//  QMInputToolbar.h
//  QMChatViewController
//
//  Created by Andrey Ivanov on 20.04.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QMToolbarContentView.h"

@class QMInputToolbar;
@class QMToolbarContentView;
@class QMAudioRecordButton;

@protocol QMAudioRecordToolbarDelegate <NSObject>

@optional
/**
 Asks the delegate if it can start the audio recording by touching the audio record button.
 
 @param toolbar An instance of `QMInputToolbar`
 @return YES if the audio recording should start or NO if it should not.
 */
- (BOOL)audioRecordingShouldStart:(QMInputToolbar *)toolbar;

/**
 This method is called when an audio recording has started.
 
 @param toolbar An instance of `QMInputToolbar`
 */
- (void)audioRecordingStart:(QMInputToolbar *)toolbar;

/**
 This method is called when an audio recording has cancelled.
 
 @param toolbar An instance of `QMInputToolbar`
 */
- (void)audioRecordingCancel:(QMInputToolbar *)toolbar;

/**
 This method is called when an audio recording has completed.
 
 @param toolbar An instance of `QMInputToolbar`
 */
- (void)audioRecordingComplete:(QMInputToolbar *)toolbar;

/**
 This method is called when an audio recording has paused because of timeout.
 @discussion: This mehod will be called only if 'audioRecordingMaximumDuration:' is adopted.
 @param toolbar An instance of `QMInputToolbar`.
 */
- (void)audioRecordingPausedByTimeOut:(QMInputToolbar *)toolbar;

/**
 Tells the delegate to return the current duration.
 
 @param toolbar An instance of `QMInputToolbar`
 @return Current duration of the audio recorder.
 */
- (NSTimeInterval)audioRecordingDuration:(QMInputToolbar *)toolbar;

/**
 Tells the delegate to return the maximum duration.
 
 @param toolbar An instance of `QMInputToolbar`
 @return The maximum duration of the recorded audio.
 */
- (NSTimeInterval)audioRecordingMaximumDuration:(QMInputToolbar *)toolbar;

@end

/**
 *  The `QMInputToolbarDelegate` protocol defines methods for interacting with
 *  a `QBChatMessageInputToolbar` object.
 */
@protocol QMInputToolbarDelegate <UIToolbarDelegate>

@required

/**
 *  Tells the delegate that the toolbar's `rightBarButtonItem` has been pressed.
 *
 *  @param toolbar The object representing the toolbar sending this information.
 *  @param sender  The button that received the touch event.
 */
- (void)messagesInputToolbar:(QMInputToolbar *)toolbar
      didPressRightBarButton:(UIButton *)sender;

/**
 *  Tells the delegate that the toolbar's `leftBarButtonItem` has been pressed.
 *
 *  @param toolbar The object representing the toolbar sending this information.
 *  @param sender  The button that received the touch event.
 */
- (void)messagesInputToolbar:(QMInputToolbar *)toolbar
       didPressLeftBarButton:(UIButton *)sender;

@optional

/**
 Asks the delegate if it can start the audio recording by touching the audio record button.
 
 @param toolbar An instance of `QMInputToolbar`
 @return YES if the audio recording should start or NO if it should not.
 */
- (BOOL)messagesInputToolbarAudioRecordingShouldStart:(QMInputToolbar *)toolbar
__deprecated_msg("Method deprecated. Use audioRecordingShouldStart");

/**
 This method is called when an audio recording has started.
 
 @param toolbar An instance of `QMInputToolbar`
 */
- (void)messagesInputToolbarAudioRecordingStart:(QMInputToolbar *)toolbar
__deprecated_msg("Method deprecated. Use audioRecordingStart");

/**
 This method is called when an audio recording has cancelled.
 
 @param toolbar An instance of `QMInputToolbar`
 */
- (void)messagesInputToolbarAudioRecordingCancel:(QMInputToolbar *)toolbar
__deprecated_msg("Method deprecated. Use audioRecordingCancel");

/**
 This method is called when an audio recording has completed.
 
 @param toolbar An instance of `QMInputToolbar`
 */
- (void)messagesInputToolbarAudioRecordingComplete:(QMInputToolbar *)toolbar
__deprecated_msg("Method deprecated. Use audioRecordingComplete");

/**
 This method is called when an audio recording has paused because of timeout.
 @discussion: This mehod will be called only if 'inputPanelAudioRecordingMaximumDuration:' is adopted.
 @param toolbar An instance of `QMInputToolbar`.
 */
- (void)messagesInputToolbarAudioRecordingPausedByTimeOut:(QMInputToolbar *)toolbar
__deprecated_msg("Method deprecated. Use audioRecordingPausedByTimeOut");

/**
 Tells the delegate to return the current duration.
 
 @param toolbar An instance of `QMInputToolbar`
 @return Current duration of the audio recorder.
 */
- (NSTimeInterval)inputPanelAudioRecordingDuration:(QMInputToolbar *)toolbar
__deprecated_msg("Method deprecated. Use audioRecordingDuration:");

/**
 Tells the delegate to return the maximum duration.
 
 @param toolbar An instance of `QMInputToolbar`
 @return The maximum duration of the recorded audio.
 */
- (NSTimeInterval)inputPanelAudioRecordingMaximumDuration:(QMInputToolbar *)toolbar
__deprecated_msg("Method deprecated. Use audioRecordingMaximumDuration:");

@end

/**
 *  An instance of `QMInputToolbar` defines the input toolbar for
 *  composing a new message. It is displayed above and follow the movement of
 *  the system keyboard.
 */
@interface QMInputToolbar : UIToolbar

/**
 *  The object that acts as the delegate of the toolbar.
 */
@property (weak, nonatomic) id<QMInputToolbarDelegate> delegate;

/**
 The object that acts as the audio record delegate of the toolbar
 */
@property (weak, nonatomic) id<QMAudioRecordToolbarDelegate> audioRecordDelegate;

/**
 *  Returns the content view of the toolbar. This view contains all subviews of the toolbar.
 */
@property (weak, nonatomic, readonly) QMToolbarContentView *contentView;

/**
 *  A boolean value indicating whether the send button is on the right side of the toolbar or not.
 *
 *  @discussion The default value is `YES`, which indicates that the send button is the right-most subview of
 *  the toolbar's `contentView`. Set to `NO` to specify that the send button is on the left. This
 *  property is used to determine which touch events correspond to which actions.
 *
 *  @warning Note, this property *does not* change the positions of buttons in the toolbar's content view.
 *  It only specifies whether the `rightBarButtonItem `or the `leftBarButtonItem` is the send button.
 *  The other button then acts as the accessory button.
 */
@property (assign, nonatomic) BOOL sendButtonOnRight;

/**
 *  Specifies the default height for the toolbar. The default value is `44.0f`. This value must be positive.
 */
@property (assign, nonatomic) CGFloat preferredDefaultHeight;

/**
 *  Enables or disables the send button based on whether or not its `textView` has text.
 *  That is, the send button will be enabled if there is text in the `textView`, and disabled otherwise.
 */
- (void)toggleSendButtonEnabled;

/**
 *  Loads the content view for the toolbar.
 *
 *  @discussion Override this method to provide a custom content view for the toolbar.
 *
 *  @return An initialized `QMToolbarContentView` if successful, otherwise `nil`.
 */
- (QMToolbarContentView *)loadToolbarContentView;

/**
 Enables ability to record and send audio attachments.
 @default NO
 @discussion: If YES, the 'audio record' button is enabled on the 'send button' side.
 @warning: Methods of delegate for audio recording should be adopted.
 */
@property (assign, nonatomic) BOOL audioRecordingEnabled;

/**
 Cancels current audio recording and calls the delegate method 'messagesInputToolbarAudioRecordingCancel:'
 */
- (void)cancelAudioRecording;

/**
 Performs the shake animation for audio record button.
 */
- (void)shakeControls;

@end
