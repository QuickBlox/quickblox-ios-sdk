//
//  QBRTCCameraCapture.h
//  QuickbloxWebRTC
//
//  Created by Andrey Ivanov on 02.07.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "QBRTCVideoCapture.h"

@class QBRTCVideoFormat;

// This class used to capture frames using AVFoundation APIs
@interface QBRTCCameraCapture : QBRTCVideoCapture

/**
 *  A CoreAnimation layer subclass for previewing the visual output of an AVCaptureSession.
 */
@property (nonatomic, strong, readonly) AVCaptureVideoPreviewLayer *previewLayer;

/**
 *   AVCaptureSession is the central hub of the AVFoundation capture classes.
 */
@property (nonatomic, strong, readonly) AVCaptureSession *captureSession;

/**
 *  Initialize video capture with specific capture position
 *
 *  @param videoFormat QBRTCVideoFormat instance
 *  @param position    AVCaptureDevicePosition, must be back or front
 *
 *  @return QBRTCVideoCapture instance
 */
- (instancetype)initWithVideoFormat:(QBRTCVideoFormat *)videoFormat
                           position:(AVCaptureDevicePosition)position NS_DESIGNATED_INITIALIZER;

// retrieve available array of QBRTCVideoFormat instances for given camera position
+ (NSArray *)formatsWithPosition:(AVCaptureDevicePosition)position;


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
 *  Start the capture session.
 */
- (void)startSession;

/**
 *  Stop the capture session asynchronously.
 */
- (void)stopSession;

/**
 * Stop the capture session and close video output
 */
- (void)stopSessionAndTeardownOutputs:(BOOL)teardownOutputs;

/**
 *  Selects a new camera position.
 *
 *  @param currentPosition The camera position to select.
 */
- (AVCaptureDevicePosition)currentPosition;

/**
 *  Select back or front camera position
 *
 *  @param cameraPosition AVCaptureDevicePosition
 */
- (void)selectCameraPosition:(AVCaptureDevicePosition)cameraPosition;

/**
 *  Check if device has back or front camera
 *
 *  @param cameraPosition AVCaptureDevicePosition
 */
- (BOOL)hasCameraForPosition:(AVCaptureDevicePosition)cameraPosition;

@end
