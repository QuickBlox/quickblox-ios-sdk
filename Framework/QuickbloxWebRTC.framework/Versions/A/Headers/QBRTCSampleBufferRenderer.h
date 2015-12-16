//
//  QBRTCSampleBufferRenderer.h
//  QuickbloxWebRTC
//
//  Created by Andrey Ivanov on 30.06.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import "QBRTCVideoRenderer.h"
#import "QBRTCTypes.h"
#import "QBRTCFrameConverter.h"

@class QBRTCSampleBufferView;

/**
 * QBRTCSampleBufferRenderer class creates QBSampleBufferView to render frames on it
 * When new frames come to a renderer, they processed and displayed on rendererView
 */
@interface QBRTCSampleBufferRenderer : QBRTCVideoRenderer

/// Frame output format
@property (nonatomic, assign, readonly) QBRTCFrameConverterOutput output;

/**
 *  Initializes QBRTCFrameConverter, QBSampleBufferView and starts fps timer
 *
 *  @param output desired output format
 *
 *  @return QBRTCSampleBufferRenderer instance
 */
- (instancetype)initWithOutput:(QBRTCFrameConverterOutput)output NS_DESIGNATED_INITIALIZER;

@end