// Copyright (c) 2012 Alex Wiltschko
// 
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following
// conditions:
// 
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.

#import <CoreFoundation/CoreFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <Accelerate/Accelerate.h>
#include <Block.h>

#ifdef __cplusplus
extern "C" {
#endif
	
static void QBCheckError(OSStatus error, const char *operation);


OSStatus qbInputCallback (void						*inRefCon,
						AudioUnitRenderActionFlags	* ioActionFlags,
						const AudioTimeStamp 		* inTimeStamp,
						UInt32						inOutputBusNumber,
						UInt32						inNumberFrames,
						AudioBufferList				* ioData);

OSStatus qbRenderCallback (void						*inRefCon,
                         AudioUnitRenderActionFlags	* ioActionFlags,
                         const AudioTimeStamp 		* inTimeStamp,
                         UInt32						inOutputBusNumber,
                         UInt32						inNumberFrames,
                         AudioBufferList				* ioData);

void qbSessionPropertyListener(void *                  inClientData,
							 AudioSessionPropertyID  inID,
							 UInt32                  inDataSize,
							 const void *            inData);

void qbSessionInterruptionListener(void *inClientData, UInt32 inInterruption);

#ifdef __cplusplus
}
#endif

typedef void (^QBOutputBlock)(float *data, UInt32 numFrames, UInt32 numChannels);
typedef void (^QBInputBlock)(float *data, UInt32 numFrames, UInt32 numChannels);

@interface QBNovocaine : NSObject <UIAlertViewDelegate>{
    
	// Audio Handling
	AudioUnit inputUnit;
    AudioUnit outputUnit;
    AudioBufferList *inputBuffer;
    
	// Session Properties
	BOOL inputAvailable;
	NSString *inputRoute;
	UInt32 numInputChannels;
	UInt32 numOutputChannels;
    Float64 samplingRate;
    BOOL isInterleaved;
    UInt32 numBytesPerSample;
    AudioStreamBasicDescription inputFormat;
    AudioStreamBasicDescription outputFormat;
	
	// Audio Processing
    QBOutputBlock outputBlock;
    QBInputBlock inputBlock;
    
	float *inData;
    float *outData;
	
	BOOL playing;
}

@property AudioUnit inputUnit;
@property AudioUnit outputUnit;
@property AudioBufferList *inputBuffer;
@property (nonatomic, copy) QBOutputBlock outputBlock;
@property (nonatomic, copy) QBInputBlock inputBlock;
@property BOOL inputAvailable;
@property (nonatomic, retain) NSString *inputRoute;
@property UInt32 numInputChannels;
@property UInt32 numOutputChannels;
@property Float64 samplingRate;
@property BOOL isInterleaved;
@property UInt32 numBytesPerSample;
@property AudioStreamBasicDescription inputFormat;
@property AudioStreamBasicDescription outputFormat;

// @property BOOL playThroughEnabled;
@property BOOL playing;
@property float *inData;
@property float *outData;

@property BOOL managingFromApplication;

// Singleton methods
+ (QBNovocaine *) audioManager;


// Audio Unit methods
- (void)play;
- (void)pause;
- (void)setupAudio;
- (void)initializeInputUnit;
- (void)releaseInputUnit;
- (void)ifAudioInputIsAvailableThenSetupAudioSession;
- (void)checkSessionProperties;
- (void)checkAudioSource;
- (void)routeToSpeaker;
- (void)routeToHeadphone;

@end
