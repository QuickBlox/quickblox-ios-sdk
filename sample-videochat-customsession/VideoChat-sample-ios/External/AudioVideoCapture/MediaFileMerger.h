//
//  MediaFileMerger.h
//  CallCenter
//
//  Created by Andrey Moskvin on 22.10.13.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MediaFileMerger : NSObject

- (void)mergeVideoFile:(NSURL *)videoFileURL
         withAudioFile:(NSURL *)audioFileURL
         andCompletion:(void(^)(BOOL success, NSString* outputFilePath))completionBlock;

- (void)saveVideoFile:(NSURL *)videoFileURL
			audioFile:(NSURL *)audioFileURL
		andCompletion:(void(^)(BOOL success, NSString* outputFilePath))completionBlock;

@end
