//
//  OpponentVideoWriter.h
//  VideoChat
//
//  Created by Igor Khomenko on 9/24/14.
//  Copyright (c) 2014 Ruslan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^OpponentVideoWriterCompletionBlock)(NSURL *videoFileUrl);

@interface OpponentVideoWriter : NSObject

- (void) writeVideoData:(CGImageRef)data;
- (void)finishWithCompletionBlock:(OpponentVideoWriterCompletionBlock)completionBlock;

@end
