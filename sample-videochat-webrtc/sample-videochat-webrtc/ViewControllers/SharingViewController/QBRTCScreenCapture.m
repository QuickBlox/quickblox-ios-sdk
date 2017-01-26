//
//  QBRTCScreenCaptuerer.m
//  QuickbloxWebRTC
//
//  Created by Andrey Ivanov on 08/10/15.
//  Copyright © 2015 QuickBlox Team. All rights reserved.
//

#import "QBRTCScreenCapture.h"

/**
 *  By default sending frames in screen share using BiPlanarFullRange pixel format type.
 *  You can also send them using ARGB by setting this constant to NO.
 */
static const BOOL kQBRTCUseBiPlanarFormatTypeForShare = YES;

@interface QBRTCScreenCapture()

@property (weak, nonatomic) UIView * view;
@property (strong, nonatomic) CADisplayLink *displayLink;

@end

@implementation QBRTCScreenCapture

- (instancetype)initWithView:(UIView *)view {
    
    self = [super init];
    if (self) {
        
        _view = view;
    }
    
    return self;
}

#pragma mark - Enter BG / FG notifications

- (void)willEnterForeground:(NSNotification *)note {
    
    self.displayLink.paused = NO;
}

- (void)didEnterBackground:(NSNotification *)note {
    
    self.displayLink.paused = YES;
}

#pragma mark -

- (UIImage *)screenshot {
    
    UIGraphicsBeginImageContextWithOptions(_view.frame.size, YES, 1);
    [_view drawViewHierarchyInRect:_view.bounds afterScreenUpdates:NO];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (CIContext *)qb_sharedGPUContext {
    static CIContext *sharedContext;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary *options = @{
                                  kCIContextPriorityRequestLow: @YES
                                  };
        sharedContext = [CIContext contextWithOptions:options];
    });
    return sharedContext;
}

- (void)sendPixelBuffer:(CADisplayLink *)sender {
    
    dispatch_async(self.videoQueue, ^{
        
        @autoreleasepool {
            
            UIImage *image = [self screenshot];
            
            int renderWidth = image.size.width;
            int renderHeight = image.size.height;
            
            CVPixelBufferRef buffer = NULL;
            
            OSType pixelFormatType;
            CFDictionaryRef pixelBufferAttributes = NULL;
            if (kQBRTCUseBiPlanarFormatTypeForShare) {
                
                pixelFormatType = kCVPixelFormatType_420YpCbCr8BiPlanarFullRange;
                pixelBufferAttributes = (__bridge CFDictionaryRef) @
                {
                    (__bridge NSString *)kCVPixelBufferIOSurfacePropertiesKey: @{},
                };
            }
            else {
                
                pixelFormatType = kCVPixelFormatType_32ARGB;
                pixelBufferAttributes = (__bridge CFDictionaryRef) @
                {
                    (NSString *)kCVPixelBufferCGImageCompatibilityKey : @NO,
                    (NSString *)kCVPixelBufferCGBitmapContextCompatibilityKey : @NO
                };
                
            }
            
            CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault,
                                                  renderWidth,
                                                  renderHeight,
                                                  pixelFormatType,
                                                  pixelBufferAttributes,
                                                  &buffer);
            
            if (status == kCVReturnSuccess && buffer != NULL) {
                
                CVPixelBufferLockBaseAddress(buffer, 0);
                
                if (kQBRTCUseBiPlanarFormatTypeForShare) {
                    
                    CIImage *rImage = [[CIImage alloc] initWithImage:image];
                    [self.qb_sharedGPUContext render:rImage toCVPixelBuffer:buffer];
                }
                else {
                    
                    void *pxdata = CVPixelBufferGetBaseAddress(buffer);
                    
                    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
                    
                    uint32_t bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst;
                    
                    CGContextRef context =
                    CGBitmapContextCreate(pxdata, renderWidth, renderHeight, 8, renderWidth * 4, rgbColorSpace, bitmapInfo);
                    CGContextDrawImage(context, CGRectMake(0, 0, renderWidth, renderHeight), [image CGImage]);
                    CGColorSpaceRelease(rgbColorSpace);
                    CGContextRelease(context);
                }
                
                CVPixelBufferUnlockBaseAddress(buffer, 0);
                
                QBRTCVideoFrame *videoFrame = [[QBRTCVideoFrame alloc] initWithPixelBuffer:buffer
                                                                             videoRotation:QBRTCVideoRotation_0];
                
                [super sendVideoFrame:videoFrame];
            }
            
            CVPixelBufferRelease(buffer);
        }
    });
}

#pragma mark - <QBRTCVideoCapture>

- (void)didSetToVideoTrack:(QBRTCLocalVideoTrack *)videoTrack {
    [super didSetToVideoTrack:videoTrack];
    
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(sendPixelBuffer:)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    self.displayLink.frameInterval = 12; //5 fps
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
}

- (void)didRemoveFromVideoTrack:(QBRTCLocalVideoTrack *)videoTrack {
    [super didRemoveFromVideoTrack:videoTrack];
    
    self.displayLink.paused = YES;
    [self.displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    self.displayLink = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
}

@end
