//
//  CaptureSessionManager.m
//  CallCenter
//
//  Created by QuickBlox on 17.10.13.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import "CaptureSessionManager.h"
#import "AQRecorder.h"
#import "TPCircularBuffer.h"
#import "MediaFileMerger.h"

#define kBufferLength 32768
#define qbAudioDataSizeForSecods(second) 512*(32*second)

@interface CaptureSessionManager() <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, strong) AVAssetWriterInput *videoWriterInput;
@property (nonatomic, strong) AVAssetWriter *videoWriter;
@property (nonatomic) AQRecorder *recorder;
@property (nonatomic) TPCircularBuffer circularBuffer;
@property (nonatomic, strong) MediaFileMerger *mediaFileMerger;

@end

@implementation CaptureSessionManager

#pragma mark -
#pragma mark Init

- (id)init
{
    self = [super init];
    if (self) {
        self.recorder = new AQRecorder();
        _mediaFileMerger = [MediaFileMerger new];
    }
    return self;
}

- (void)dealloc{
    
    // Release buffer resources
    TPCircularBufferCleanup(&_circularBuffer);
    
}

- (void)setEnabledRecording:(BOOL)enabledRecording{
    _enabledRecording = enabledRecording;
    
    if(_enabledRecording){
        [self setupAssetWriter];
    }else{
        [self finishWritingVideoAndAudio];
    }
}


#pragma mark -
#pragma mark Setup audio & video capture

-(AVCaptureVideoPreviewLayer *) setupVideoCapture{
    self.captureSession = [[AVCaptureSession alloc] init];
    
    __block NSError *error = nil;
    
    // set preset
    [self.captureSession setSessionPreset:AVCaptureSessionPresetLow];
    
    
    // Setup the Video input
    AVCaptureDevice *videoDevice = [self frontFacingCamera];
    //
    AVCaptureDeviceInput *captureVideoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    if(error){
        QBDLogEx(@"deviceInputWithDevice Video error: %@", error);
    }else{
        if ([self.captureSession  canAddInput:captureVideoInput]){
            [self.captureSession addInput:captureVideoInput];
        }else{
            QBDLogEx(@"cantAddInput Video");
        }
    }
    
    // Setup Video output
    AVCaptureVideoDataOutput *videoCaptureOutput = [[AVCaptureVideoDataOutput alloc] init];
    videoCaptureOutput.alwaysDiscardsLateVideoFrames = YES;
    //
    // Set the video output to store frame in BGRA (It is supposed to be faster)
    NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey;
    NSNumber* value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
    NSDictionary* videoSettings = [NSDictionary dictionaryWithObject:value forKey:key];
    [videoCaptureOutput setVideoSettings:videoSettings];
    /*And we create a capture session*/
    if([self.captureSession canAddOutput:videoCaptureOutput]){
        [self.captureSession addOutput:videoCaptureOutput];
    }else{
        QBDLogEx(@"cantAddOutput");
    }
    
    
    // set FPS
    int framesPerSecond = 7;
    AVCaptureConnection *conn = [videoCaptureOutput connectionWithMediaType:AVMediaTypeVideo];
    if (conn.isVideoMinFrameDurationSupported){
        conn.videoMinFrameDuration = CMTimeMake(1, framesPerSecond);
    }
    if (conn.isVideoMaxFrameDurationSupported){
        conn.videoMaxFrameDuration = CMTimeMake(1, framesPerSecond);
    }
    
    // set portrait orientation
    [conn setVideoOrientation:AVCaptureVideoOrientationPortrait];
    
    /*We create a serial queue to handle the processing of our frames*/
    dispatch_queue_t callbackQueue= dispatch_queue_create("cameraQueue", NULL);
    [videoCaptureOutput setSampleBufferDelegate:self queue:callbackQueue];
    
    // Add preview layer
    AVCaptureVideoPreviewLayer *prewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    
    /*We start the capture*/
    [self.captureSession startRunning];
    
    return  prewLayer;
}

-(void) setupAudioCapture{
    // start audio IO
    //
    [[QBAudioIOService shared] start];
    
    // Route audio to speaker
    //
    [[QBAudioIOService shared] routeToSpeaker];
    
    // Create ring buffer
    //
    TPCircularBufferInit(&_circularBuffer, kBufferLength);
    
    // Start processing
    //
    __weak __typeof(self)weakSelf = self;
    [[QBAudioIOService shared] setInputBlock:^(AudioBuffer buffer){
        
        @autoreleasepool {
            if(weakSelf.audioOutputBlock != nil){
                weakSelf.audioOutputBlock(buffer);
            }
        }
    }];
    //
    [[QBAudioIOService shared] start];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput  didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    @autoreleasepool {
        if(self.videoOutputBlock != nil){
            self.videoOutputBlock(sampleBuffer);
        }
    }
    
    if (self.enabledRecording) {
        [self startVideoWriteSessionWithSampleBuffer:sampleBuffer];
        [self appendBufferToInput:sampleBuffer];
        
    }
}

- (AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition) position{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}

- (AVCaptureDevice *) backFacingCamera{
    return [self cameraWithPosition:AVCaptureDevicePositionBack];
}

- (AVCaptureDevice *) frontFacingCamera{
    return [self cameraWithPosition:AVCaptureDevicePositionFront];
}

- (void)changeVideoOutput:(BOOL)useBackCamera{
    [self.captureSession beginConfiguration];
    
    // remove old input
    [self.captureSession removeInput:[self.captureSession inputs][0]];
    
    // choose proper input
    AVCaptureDevice *__videoDevice;
    if(!useBackCamera){
        __videoDevice = [self frontFacingCamera];
    }else{
        __videoDevice = [self backFacingCamera];
    }
    
    // add new one
    NSError *error = nil;
    AVCaptureDeviceInput *captureVideoInput = [AVCaptureDeviceInput deviceInputWithDevice:__videoDevice error:&error];
    if(error){
        QBDLogEx(@"deviceInputWithDevice error: %@", error);
    }else{
        if ([self.captureSession  canAddInput:captureVideoInput]){
            [self.captureSession addInput:captureVideoInput];
        }else{
            QBDLogEx(@"cantAddInput");
        }
    }
    
    // set portrait orientation
    AVCaptureConnection *conn = [self.captureSession.outputs[0] connectionWithMediaType:AVMediaTypeVideo];
    [conn setVideoOrientation:AVCaptureVideoOrientationPortrait];
    
    [self.captureSession commitConfiguration];
}


- (void)processAudioBuffer:(AudioBuffer)buffer{
    // Put audio into circular buffer
    //
    TPCircularBufferProduceBytes(&_circularBuffer, buffer.mData, buffer.mDataByteSize);
    
    // Get number of bytes in circular buffer
    //
    int32_t availableBytes;
    TPCircularBufferTail(&_circularBuffer, &availableBytes);
    
    // If output block is NIL and we have audio data for 0.5 second
    //
    if([[QBAudioIOService shared] outputBlock] == nil && availableBytes > qbAudioDataSizeForSecods(0.5)){
        
        QBDLogEx(@"Set output block");
        [[QBAudioIOService shared] setOutputBlock:^(AudioBuffer buffer) {
            
            int32_t availableBytesInBuffer;
            void *cbuffer = TPCircularBufferTail(&_circularBuffer, &availableBytesInBuffer);
            
            // Read audio data if exist
            if(availableBytesInBuffer > 0){
                int min = MIN(buffer.mDataByteSize, availableBytesInBuffer);
                memcpy(buffer.mData, cbuffer, min);
                TPCircularBufferConsume(&_circularBuffer, min);
            }else{
                // No data to play -> mute output
                QBDLogEx(@"No data to play -> mute output");
                [[QBAudioIOService shared] setOutputBlock:nil];
            }
            
            // If there is to much audio data to play -> clear buffer & mute output
            //
            if(availableBytes > qbAudioDataSizeForSecods(3)) {
                QBDLogEx(@"There is to much audio data to play -> clear buffer & mute output");
                TPCircularBufferClear(&_circularBuffer);
                
                [[QBAudioIOService shared] setOutputBlock:nil];
            }
        }];
    }
}


#pragma mark
#pragma mark Recording

- (void)setupAssetWriter
{
    [self.videoWriter cancelWriting];
    
    NSError *error = nil;

    self.videoWriter = [[AVAssetWriter alloc] initWithURL:[self temporaryFileUrl]
                                                 fileType:AVFileTypeQuickTimeMovie
                                                    error:&error];
	
    NSParameterAssert(self.videoWriter);
    
    NSDictionary *videoSettings = @{AVVideoCodecKey : AVVideoCodecH264,
                                    AVVideoWidthKey : [NSNumber numberWithInt:640],
									AVVideoHeightKey : [NSNumber numberWithInt:480]};
    
    self.videoWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo
                                                               outputSettings:videoSettings];

    NSParameterAssert(self.videoWriterInput);
    NSParameterAssert([self.videoWriter canAddInput:self.videoWriterInput]);
    
    self.videoWriterInput.expectsMediaDataInRealTime = YES;
    [self.videoWriter addInput:self.videoWriterInput];
}

- (void)startVideoWriteSessionWithSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    if (self.videoWriter.status != AVAssetWriterStatusWriting) {
        [self.videoWriter startWriting];
        [self.videoWriter startSessionAtSourceTime:CMSampleBufferGetPresentationTimeStamp(sampleBuffer)];
        
        if (!self.recorder->IsRunning()) {
            self.recorder->StartRecord((__bridge_retained CFStringRef)[self temporaryAudioFileName]);
        }
    }
    
    if (self.videoWriter.status == AVAssetWriterStatusFailed) {
        NSAssert(NO,[self.videoWriter.error description]);
    }
}

- (void)appendBufferToInput:(CMSampleBufferRef)sampleBuffer {
    if (self.videoWriterInput.readyForMoreMediaData && self.videoWriter.status == AVAssetWriterStatusWriting && self.videoWriterInput != nil) {
        if (![self.videoWriterInput appendSampleBuffer:sampleBuffer])	{
            NSAssert(NO, [self.videoWriter.error description]);
        }
    }
}

- (void)finishWritingVideoAndAudio
{
	@synchronized(self.videoWriter) {
		if (self.videoWriter.status == AVAssetWriterStatusWriting) {
			__block UIBackgroundTaskIdentifier identifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
				[[UIApplication sharedApplication] endBackgroundTask:identifier];
			}];

            NSString* audioFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:(__bridge NSString *)self.recorder->GetFileName()];
			NSURL* outputAudioFileURL = [NSURL fileURLWithPath:audioFilePath];
            self.recorder->StopRecord();
			
            __weak __typeof(self)weakSelf = self;
            
            [self.videoWriterInput markAsFinished];
			[self.videoWriter finishWritingWithCompletionHandler:^{
                
				if (self.videoWriter.status == AVAssetWriterStatusCompleted)
				{
					NSURL* outputVideoFileURL = [weakSelf.videoWriter outputURL];
					// prepare for merging with audio and sending to QB
					[weakSelf finishedRecordingVideoAtURL:outputVideoFileURL
                                        andAudioAtURL:outputAudioFileURL
                                      andBackgroundId:identifier];
				}
				
				if (weakSelf.videoWriter.status == AVAssetWriterStatusFailed) {
					NSAssert(NO, [weakSelf.videoWriter.error description]);
				}
                [weakSelf setupAssetWriter];
			}];
		}
	}
}

- (void)finishWritingVideoAndAudioAtBackground {
    
	@synchronized(self.videoWriter) {
	__weak __typeof(self)weakSelf = self;
        if (self.videoWriter.status == AVAssetWriterStatusWriting) {
			__block UIBackgroundTaskIdentifier identifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
				[[UIApplication sharedApplication] endBackgroundTask:identifier];
			}];
			
            NSString* audioFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:(__bridge NSString *)self.recorder->GetFileName()];
			NSURL* outputAudioFileURL = [NSURL fileURLWithPath:audioFilePath];
            self.recorder->StopRecord();
			
            [self.videoWriterInput markAsFinished];
			[self.videoWriter finishWritingWithCompletionHandler:^{
            
				if (weakSelf.videoWriter.status == AVAssetWriterStatusCompleted)
				{
					NSURL *outputVideoFileURL = [weakSelf.videoWriter outputURL];
					[weakSelf finishedRecordingVideoAtURL:outputVideoFileURL
                                        andAudioAtURL:outputAudioFileURL];
				}
			}];
		}
	}
}

- (NSString *)uniqueFileNameWithExtension:(NSString *)extension
{
    return [NSString stringWithFormat:@"%@.%@", [[NSDate date] description], extension];
}

- (NSURL *)temporaryFileUrl
{
    return [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), [self uniqueFileNameWithExtension:@"mov"]]];
}

- (NSString *)temporaryAudioFileName
{
    return [self uniqueFileNameWithExtension:@"caf"];
}

- (void)finishedRecordingVideoAtURL:(NSURL *)outputVideoFileURL
                      andAudioAtURL:(NSURL *)outputAudioFileURL
                    andBackgroundId:(UIBackgroundTaskIdentifier) identifier
{
    [self.mediaFileMerger mergeVideoFile:outputVideoFileURL
                           withAudioFile:outputAudioFileURL
                           andCompletion:^(BOOL success, NSString *outputFilePath) {
                               
                               __weak __typeof(self)weakSelf = self;
                               NSAssert([[NSFileManager defaultManager] fileExistsAtPath:outputFilePath], @"Output file was not created!");
                               
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   if(weakSelf.recordVideoResultBlock != nil){
                                       weakSelf.recordVideoResultBlock(outputFilePath);
                                   }
                               });
                           }];
}

- (void)finishedRecordingVideoAtURL:(NSURL *)outputVideoFileURL
                      andAudioAtURL:(NSURL *)outputAudioFileURL
{
    [self.mediaFileMerger saveVideoFile:outputVideoFileURL audioFile:outputAudioFileURL andCompletion:^(BOOL success, NSString *outputFilePath) {
        
    }];
}

@end
