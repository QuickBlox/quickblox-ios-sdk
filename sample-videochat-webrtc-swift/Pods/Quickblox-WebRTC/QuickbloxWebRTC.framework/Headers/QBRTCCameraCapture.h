//
//  QBRTCCameraCapture.h
//  QuickbloxWebRTC
//
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import "QBRTCVideoCapture.h"

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class QBRTCVideoFormat;

NS_ASSUME_NONNULL_BEGIN

/**
 *  QBRTCCameraCapture class interface.
 *  This class represent native camera capture based on QBRTCVideoCapture rtc capture.
 *
 *  @see QBRTCVideoCapture
 */
@interface QBRTCCameraCapture : QBRTCVideoCapture

/**
 *   AVCaptureSession is the central hub of the AVFoundation capture classes.
 */
@property (nonatomic, strong, readonly) AVCaptureSession *captureSession;

/**
 *  A CoreAnimation layer subclass for previewing the visual output of an AVCaptureSession.
 */
@property (nonatomic, strong, readonly) AVCaptureVideoPreviewLayer *previewLayer;

/**
 *  Current camera position.
 */
@property (nonatomic, assign) AVCaptureDevicePosition position;

/**
 *  Determines whether camera capture has started, but is not running yet (in set-up state).
 */
@property (nonatomic, readonly) BOOL hasStarted;

/**
 *  Determines whether capture session is running.
 */
@property (nonatomic, readonly) BOOL isRunning;

/**
 *  Initialize video capture with specific capture position.
 *
 *  @param videoFormat QBRTCVideoFormat video format
 *  @param position    AVCaptureDevicePosition, must be back or front
 *
 *  @return QBRTCVideoCapture instance
 */
- (instancetype)initWithVideoFormat:(QBRTCVideoFormat *)videoFormat
                           position:(AVCaptureDevicePosition)position NS_DESIGNATED_INITIALIZER;

/**
 *  Allows you to batch configuration changes to the session. Works while the session is stopped or running.
 *  @note It is safe to call prepare/teardown or start/stop methods from capturer.
 *  Also, the session preset may be changed.
 *
 *  @param configureBlock A handler block which applies the changes to the session.
 *  @note if capture is running, this block will be called on the serial session queue.
 */
- (void)configureSession:(dispatch_block_t)configureBlock;

/**
 *  Start the capture session asynchronously with completion block.
 *
 *  @param completion   operation completion block
 */
- (void)startSession:(nullable dispatch_block_t)completion;

/**
 *  Stop the capture session asynchronously with completion block.
 *
 *  @param completion   operation completion block
 */
- (void)stopSession:(nullable dispatch_block_t)completion;

// MARK: Video format management

/**
 *  Current video format that is in use for requested camera position.
 *
 *  @param position requested camera position
 *
 *  @return QBRTCVideoFormat video format
 */
- (QBRTCVideoFormat *)videoFormatForPosition:(AVCaptureDevicePosition)position;

/**
 *  Set a specific video format for a requested camera position.
 *
 *  @param videoFormat QBRTCVideoFormat wanted video format
 *  @param position requested camera position
 */
- (void)setVideoFormat:(QBRTCVideoFormat *)videoFormat forPosition:(AVCaptureDevicePosition)position;

// MARK: Helpers

/**
 *  Retrieve available array of QBRTCVideoFormat instances for given camera position.
 *
 *  @param position requested camera position
 *
 *  @return Array of possible QBRTCVideoFormat video formats for requested position
 */
+ (NSArray <QBRTCVideoFormat *> *)formatsWithPosition:(AVCaptureDevicePosition)position;

/**
 *  Check if device has back or front camera.
 *
 *  @param cameraPosition AVCaptureDevicePosition
 */
- (BOOL)hasCameraForPosition:(AVCaptureDevicePosition)cameraPosition;

@end

NS_ASSUME_NONNULL_END
