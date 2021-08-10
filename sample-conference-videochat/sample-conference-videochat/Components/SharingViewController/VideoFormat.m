//
//  VideoFormat.m
//  sample-conference-videochat
//
//  Created by Injoit on 06.07.2021.
//  Copyright © 2021 Quickblox. All rights reserved.
//

#import "VideoFormat.h"

@implementation VideoFormat

- (instancetype)initWithWidth:(NSUInteger)width height:(NSUInteger)height fps:(NSUInteger)fps {
    
    self = [super init];
    if (self) {
        
        _width = width;
        _height = height;
        _fps = fps;
    }
    
    return self;
}

@end
