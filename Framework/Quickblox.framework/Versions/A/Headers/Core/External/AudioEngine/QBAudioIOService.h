//
//  QBAudioManager.h
//  AudioUnit PCM to iLBC converter
//
//  Created by Igor Khomenko on 11/7/13.
//  Copyright (c) 2013 Igor Khomenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreAudio/CoreAudioTypes.h>

#define qbiLBCBufferFrameSize 480
#define qbiLBCOutputBufferSize 512
#define qbBufferFrameSize 128
#define qbIOBufferDuration qbBufferFrameSize / qbSampleRateT  // There’s one other hardware characteristic you may want to configure: audio hardware I/O buffer duration. The default duration is about 23 ms at a 44.1 kHz sample rate, equivalent to a slice size of 1,024 samples. If I/O latency is critical in your app, you can request a smaller duration, down to about 0.005 ms (equivalent to 256 samples),
#define qbSampleRateT  8000.0

@interface QBAudioIOService : NSObject

typedef void (^QBOutputBlock)(AudioBuffer buffer);
typedef void (^QBInputBlock)(AudioBuffer buffer);

@property (nonatomic, copy) QBInputBlock inputBlock;
@property (nonatomic, copy) QBOutputBlock outputBlock;
@property (nonatomic, readonly) BOOL inputAvailable;
@property (nonatomic, readonly) BOOL running;
@property (nonatomic, readonly) UInt32 numInputChannels;
@property (nonatomic, readonly) UInt32 numOutputChannels;
//
@property (nonatomic, assign) BOOL managingFromApplication;

+ (instancetype)shared;
- (void)start;
- (void)stop;

- (void)setupAudioSession;

- (void)routeToSpeaker;
- (void)routeToHeadphone;

// iLBC encode/decode
- (AudioBuffer)encodePCMtoiLBC:(AudioBuffer)pcmData;
- (AudioBuffer)decodeiLBCtoPCM:(AudioBuffer)iLBCData;
//
- (void)encodeAsyncPCMtoiLBC:(AudioBuffer)pcmData outputBlock:(QBOutputBlock)outputBlock;
- (void)decodeAsynciLBCtoPCM:(AudioBuffer)iLBCData outputBlock:(QBOutputBlock)outputBlock;

@end
