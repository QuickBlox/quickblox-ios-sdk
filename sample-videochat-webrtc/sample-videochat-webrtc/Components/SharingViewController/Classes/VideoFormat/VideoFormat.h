//
//  VideoFormat.h
//  sample-videochat-webrtc
//
//  Created by Injoit on 06.07.2021.
//  Copyright © 2021 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VideoFormat : NSObject

@property(assign, nonatomic) NSUInteger width;
@property(assign, nonatomic) NSUInteger height;
@property(assign, nonatomic) NSUInteger fps;

- (instancetype)initWithWidth:(NSUInteger)width height:(NSUInteger)height fps:(NSUInteger)fps;

@end

NS_ASSUME_NONNULL_END
