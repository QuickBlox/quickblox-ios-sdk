//
//  OpponentVideoWriter.m
//  VideoChat
//
//  Created by Igor Khomenko on 9/24/14.
//  Copyright (c) 2014 Ruslan. All rights reserved.
//

#import "OpponentVideoWriter.h"

@interface OpponentVideoWriter ()
@property (nonatomic) NSString *fileUrl;
@property (nonatomic) AVAssetWriter *videoWriter;
@property (nonatomic) AVAssetWriterInput *videoWriterInput;
@property (nonatomic) AVAssetWriterInputPixelBufferAdaptor *adaptor;
@property (nonatomic) int frameNumber;

@property (nonatomic, copy) OpponentVideoWriterCompletionBlock opponentVideoWriterCompletionBlock;
@end

@implementation OpponentVideoWriter

- (void)finishWithCompletionBlock:(OpponentVideoWriterCompletionBlock)completionBlock{

    [self.videoWriterInput markAsFinished];
    CVPixelBufferPoolRelease(self.adaptor.pixelBufferPool);
    
    __weak typeof(self) weakSelf = self;
    [self.videoWriter finishWritingWithCompletionHandler:^{
        if (self.videoWriter.status == AVAssetWriterStatusCompleted){
            NSURL *outputVideoFileURL = [weakSelf.videoWriter outputURL];
            
            if(completionBlock != nil){
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionBlock(outputVideoFileURL);
                });
            }
            
            weakSelf.videoWriter = nil;
            weakSelf.videoWriterInput = nil;
            weakSelf.adaptor = nil;
        }
        
        if (self.videoWriter.status == AVAssetWriterStatusFailed) {
            NSAssert(NO, [self.videoWriter.error description]);
        }
    }];
    
    _frameNumber = 0;
}

- (void)setupAssetWriter:(CGSize)frameSize
{
    [self.videoWriter cancelWriting];
    
    NSError *error = nil;
    
    self.videoWriter = [[AVAssetWriter alloc] initWithURL:[self temporaryFileUrl]
                                                 fileType:AVFileTypeQuickTimeMovie
                                                    error:&error];
    
    NSParameterAssert(self.videoWriter);
    
    NSDictionary *videoSettings = @{AVVideoCodecKey : AVVideoCodecH264,
                                    AVVideoWidthKey : [NSNumber numberWithInt:frameSize.width],
                                    AVVideoHeightKey : [NSNumber numberWithInt:frameSize.height]};
    
    self.videoWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo
                                                               outputSettings:videoSettings];
    
    NSParameterAssert(self.videoWriterInput);
    NSParameterAssert([self.videoWriter canAddInput:self.videoWriterInput]);
    
    self.videoWriterInput.expectsMediaDataInRealTime = YES;
    [self.videoWriter addInput:self.videoWriterInput];
    
    
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    [attributes setObject:[NSNumber numberWithUnsignedInt:kCVPixelFormatType_32ARGB] forKey:(NSString*)kCVPixelBufferPixelFormatTypeKey];
    [attributes setObject:[NSNumber numberWithUnsignedInt:frameSize.width] forKey:(NSString*)kCVPixelBufferWidthKey];
    [attributes setObject:[NSNumber numberWithUnsignedInt:frameSize.height] forKey:(NSString*)kCVPixelBufferHeightKey];
    
    self.adaptor = [AVAssetWriterInputPixelBufferAdaptor
                                                     assetWriterInputPixelBufferAdaptorWithAssetWriterInput:self.videoWriterInput
                                                     sourcePixelBufferAttributes:attributes];
}

- (void) writeVideoData:(CGImageRef)data {
    if(self.videoWriter == nil){
        CGSize size = CGSizeMake(CGImageGetWidth(data), CGImageGetHeight(data));
        [self setupAssetWriter:size];
    }
    
    if (self.videoWriter.status != AVAssetWriterStatusWriting) {
        [self.videoWriter startWriting];
        [self.videoWriter startSessionAtSourceTime:kCMTimeZero];
    }
    
    if (self.videoWriter.status == AVAssetWriterStatusFailed) {
        NSAssert(NO,[self.videoWriter.error description]);
    }
    
    if (self.videoWriterInput.readyForMoreMediaData && self.videoWriter.status == AVAssetWriterStatusWriting && self.videoWriterInput != nil) {
        // do stuff
        
        CVPixelBufferRef buffer = NULL;
        buffer = [self pixelBufferFromCGImage:data];
        

        CMTime time;
        int fps = 7;
        if(_frameNumber == 0){
            time = kCMTimeZero;
        }else{
            CMTime frameTime = CMTimeMake(1, fps);
            CMTime lastTime = CMTimeMake(_frameNumber, fps);
            time = CMTimeAdd(lastTime, frameTime);
        }
        
        
        BOOL result = [self.adaptor appendPixelBuffer:buffer withPresentationTime:time];
        NSAssert(result, @"appendPixelBuffer result is false");

        if(buffer){
            CVBufferRelease(buffer);
        }
        
        ++_frameNumber;
    }
}

- (CVPixelBufferRef) pixelBufferFromCGImage: (CGImageRef) image
{
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    CVPixelBufferRef pxbuffer = NULL;
    
    CVPixelBufferCreate(kCFAllocatorDefault, CGImageGetWidth(image),
                        CGImageGetHeight(image), kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef) options,
                        &pxbuffer);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, CGImageGetWidth(image),
                                                 CGImageGetHeight(image), 8, 4*CGImageGetWidth(image), rgbColorSpace,
                                                 (CGBitmapInfo)kCGImageAlphaNoneSkipFirst);
    
    CGContextConcatCTM(context, CGAffineTransformMakeRotation(0));
    
    CGAffineTransform flipVertical = CGAffineTransformMake(
                                                           1, 0, 0, -1, 0, CGImageGetHeight(image)
                                                           );
    CGContextConcatCTM(context, flipVertical);
    
    CGAffineTransform flipHorizontal = CGAffineTransformMake(
                                                             -1.0, 0.0, 0.0, 1.0, CGImageGetWidth(image), 0.0
                                                             );
    
    CGContextConcatCTM(context, flipHorizontal);
    
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image),
                                           CGImageGetHeight(image)), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

- (NSString *)uniqueFileNameWithExtension:(NSString *)extension
{
    return [NSString stringWithFormat:@"%@.%@", [[NSDate date] description], extension];
}

- (NSURL *)temporaryFileUrl
{
    return [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), [self uniqueFileNameWithExtension:@"mov"]]];
}

@end
