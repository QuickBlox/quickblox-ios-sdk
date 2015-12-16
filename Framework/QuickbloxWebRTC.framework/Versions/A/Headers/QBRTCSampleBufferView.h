//
//  QBRTCSampleBufferView.h
//  QuickbloxWebRTC
//
//  Created by Andrey Ivanov on 30.06.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  Class used native iOS sample buffer AVSampleBufferDisplayLayer to display content
 *  @note: Faster then OpenGL view
 */
@interface QBRTCSampleBufferView : UIView

/// Video Gravity
@property (copy, nonatomic) NSString *videoGravity;

/* Sample provider.
 * The CMSampleBuffer refs provided will be released after they are enqueued for display.
 */
- (void)addSampleProviderWithBlock:(CMSampleBufferRef (^)(void))providerBlock inQueue:(dispatch_queue_t)providerQueue;

/// Stop Sample provider from requesting data
- (void)stopSampleProvider;

/**
 *  Display CMSampleBufferRef
 *
 *  @param sampleBuffer CMSampleBufferRef
 */
- (void)displaySampleBuffer:(CMSampleBufferRef)sampleBuffer;

/// Flush view
- (void)flush;

@end
