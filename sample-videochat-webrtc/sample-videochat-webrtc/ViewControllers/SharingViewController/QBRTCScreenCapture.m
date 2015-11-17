//
//  QBRTCScreenCaptuerer.m
//  QuickbloxWebRTC
//
//  Created by Andrey Ivanov on 08/10/15.
//  Copyright © 2015 QuickBlox Team. All rights reserved.
//

#import "QBRTCScreenCapture.h"

@interface QBRTCScreenCapture()

@property (nonatomic, weak) UIView * view;
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
    
    UIGraphicsBeginImageContextWithOptions(_view.frame.size, NO, 1);
    [_view drawViewHierarchyInRect:_view.bounds afterScreenUpdates:NO];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)sendPixelBuffer:(CADisplayLink *)sender {
    //Convert to unix nanosec
    int64_t timeStamp = sender.timestamp * NSEC_PER_SEC;
    
    dispatch_async(self.videoQueue, ^{
        
        @autoreleasepool {
            
            UIImage *image = [self screenshot];
            
            int w = image.size.width;
            int h = image.size.height;
            
            NSDictionary *options = @{
                                      (NSString *)kCVPixelBufferCGImageCompatibilityKey : @NO,
                                      (NSString *)kCVPixelBufferCGBitmapContextCompatibilityKey : @NO
                                      };
            
            CVPixelBufferRef pixelBuffer = nil;
            CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault,
                                                  w,
                                                  h,
                                                  kCVPixelFormatType_32ARGB,
                                                  (__bridge CFDictionaryRef)(options),
                                                  &pixelBuffer);
            
            if(status == kCVReturnSuccess && pixelBuffer != NULL) {
                
      
                CVPixelBufferLockBaseAddress(pixelBuffer, 0);
                void *pxdata = CVPixelBufferGetBaseAddress(pixelBuffer);
                
                CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
                
                uint32_t bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst;
                
                CGContextRef context =
                CGBitmapContextCreate(pxdata, w, h, 8, w * 4, rgbColorSpace, bitmapInfo);
                CGContextDrawImage(context, CGRectMake(0, 0, w, h), [image CGImage]);
                CGColorSpaceRelease(rgbColorSpace);
                CGContextRelease(context);
                
                QBRTCVideoFrame *videoFrame = [[QBRTCVideoFrame alloc] initWithPixelBuffer:pixelBuffer];
                videoFrame.timestamp = timeStamp;
                
                [super sendVideoFrame:videoFrame];
                
                CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
                
            }
            
            CVPixelBufferRelease(pixelBuffer);   
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
