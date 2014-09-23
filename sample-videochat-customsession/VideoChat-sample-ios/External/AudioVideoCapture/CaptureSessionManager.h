//
//  CaptureSessionManager.h
//  CallCenter
//
//  Created by QuickBlox on 17.10.13.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^AudioOutputBlock)(AudioBuffer buffer);
typedef void (^VideoOutputBlock)(CMSampleBufferRef buffer);
typedef void (^RecordVideoResultBlock)(NSString *URL);


@interface CaptureSessionManager : NSObject

@property (strong) AVCaptureSession *captureSession;
@property (nonatomic, copy) AudioOutputBlock audioOutputBlock;
@property (nonatomic, copy) VideoOutputBlock videoOutputBlock;
@property (nonatomic, copy) RecordVideoResultBlock recordVideoResultBlock;

@property (nonatomic, assign) BOOL enabledRecording;

-(AVCaptureVideoPreviewLayer *) setupVideoCapture;
-(void) setupAudioCapture;

- (void)processAudioBuffer:(AudioBuffer)buffer;
- (void)changeVideoOutput:(BOOL)useBackCamera;

- (void)finishWritingVideoAndAudio;
- (void)finishWritingVideoAndAudioAtBackground;

@end