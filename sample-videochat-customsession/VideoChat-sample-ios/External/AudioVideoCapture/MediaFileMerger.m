//
//  MediaFileMerger.m
//  CallCenter
//
//  Created by Andrey Moskvin on 22.10.13.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import "MediaFileMerger.h"

@interface MediaFileMerger ()

@property(nonatomic, readonly) NSString* outputFilePath;

@end

@implementation MediaFileMerger

#pragma mark - Private

- (void)addVideoAssetForURL:(NSURL *)videoFileURL
              withStartTime:(CMTime)nextClipStartTime
          forMixComposition:(AVMutableComposition *)mixComposition;
{
    AVURLAsset* videoAsset = [[AVURLAsset alloc] initWithURL:videoFileURL
                                                     options:nil];
    
    CMTimeRange videoTimeRange = CMTimeRangeMake(kCMTimeZero,videoAsset.duration);
    AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                                   preferredTrackID:kCMPersistentTrackID_Invalid];
    [compositionVideoTrack insertTimeRange:videoTimeRange
                                   ofTrack:[videoAsset tracksWithMediaType:AVMediaTypeVideo][0]
                                    atTime:nextClipStartTime
                                     error:nil];
}

- (void)addAudioAssetForURL:(NSURL *)audioFileURL
           withStartTime:(CMTime)nextClipStartTime
       forMixComposition:(AVMutableComposition *)mixComposition;
{
    AVURLAsset* audioAsset = [[AVURLAsset alloc]initWithURL:audioFileURL
                                                    options:nil];
    CMTimeRange audionTimeRange = CMTimeRangeMake(kCMTimeZero, audioAsset.duration);
    
    AVMutableCompositionTrack *compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                                   preferredTrackID:kCMPersistentTrackID_Invalid];
    [compositionAudioTrack insertTimeRange:audionTimeRange
                                   ofTrack:[audioAsset tracksWithMediaType:AVMediaTypeAudio][0]
                                    atTime:nextClipStartTime
                                     error:nil];
}

#pragma mark - Public

- (void)mergeVideoFile:(NSURL *)videoFileURL withAudioFile:(NSURL *)audioFileURL
         andCompletion:(void (^)(BOOL,NSString*))completionBlock
{
	
	
    NSAssert([[NSFileManager defaultManager] fileExistsAtPath:videoFileURL.path], @"Video File do not exists!");
    NSAssert([[NSFileManager defaultManager] fileExistsAtPath:audioFileURL.path], @"Audio File do not exists!");

    [self deleteOutputFile];
    
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    
    CMTime nextClipStartTime = kCMTimeZero;
    
    [self addVideoAssetForURL:videoFileURL
                withStartTime:nextClipStartTime
            forMixComposition:mixComposition];
    
    [self addAudioAssetForURL:audioFileURL
                withStartTime:nextClipStartTime
            forMixComposition:mixComposition];
    
    AVAssetExportSession* assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition
                                                                         presetName:AVAssetExportPresetHighestQuality];
    assetExport.outputFileType = @"public.mpeg-4";
    assetExport.outputURL = [NSURL fileURLWithPath:self.outputFilePath];
    
    @weakify(self);
    [assetExport exportAsynchronouslyWithCompletionHandler:^(void ) {
        @strongify(self);
        NSAssert(assetExport.status != AVAssetExportSessionStatusFailed, @"Export failed!");
        NSAssert(assetExport.error == nil, @"Error occured during export!");
        completionBlock(YES, self.outputFilePath);
        [[NSFileManager defaultManager] removeItemAtURL:videoFileURL error:nil];
        [[NSFileManager defaultManager] removeItemAtURL:audioFileURL error:nil];
    }];
}

- (void)saveVideoFile:(NSURL *)videoFileURL
			audioFile:(NSURL *)audioFileURL
		andCompletion:(void(^)(BOOL success, NSString* outputFilePath))completionBlock {
	NSAssert([[NSFileManager defaultManager] fileExistsAtPath:videoFileURL.path], @"Video File do not exists!");
    NSAssert([[NSFileManager defaultManager] fileExistsAtPath:audioFileURL.path], @"Audio File do not exists!");

	NSURL *tempVideoFileUrl = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@background_video.mov", NSTemporaryDirectory()]];
	NSURL *tempAudioFileUrl = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@background_audio.caf", NSTemporaryDirectory()]];
	
	
	NSError *videoError;
	if ([[NSFileManager defaultManager] fileExistsAtPath:tempVideoFileUrl.path]) {
		[[NSFileManager defaultManager] removeItemAtPath:tempVideoFileUrl.path error:&videoError];
	}
	
	[[NSFileManager defaultManager] moveItemAtPath:videoFileURL.path toPath:tempVideoFileUrl.path error:&videoError];
   
	NSError *audioError;
	if ([[NSFileManager defaultManager] fileExistsAtPath:tempAudioFileUrl.path]) {
		[[NSFileManager defaultManager] removeItemAtPath:tempAudioFileUrl.path error:&audioError];
	}
	[[NSFileManager defaultManager] moveItemAtPath:audioFileURL.path toPath:tempAudioFileUrl.path error:&audioError];
}

-(void)deleteOutputFile
{
    [[NSFileManager defaultManager] removeItemAtPath:self.outputFilePath error:nil];
}

#pragma mark - Helper

- (NSString *)outputFilePath
{
    return [NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), @"finalOutput.mp4"];
}

@end
