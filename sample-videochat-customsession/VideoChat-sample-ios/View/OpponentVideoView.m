//
//  OpponentVideoView.m
//  VideoChat
//
//  Created by Igor Khomenko on 9/24/14.
//  Copyright (c) 2014 Ruslan. All rights reserved.
//

#import "OpponentVideoView.h"

@implementation OpponentVideoView

+ (Class) layerClass
{
    return [OpponentVideoViewLayer class];
}

@end

@implementation OpponentVideoViewLayer

- (void)setContents:(id)newContents{
    [super setContents:newContents];
    
    OpponentVideoView *view = self.delegate;
    if(view.opponentVideoViewCallbackBlock != nil){
        view.opponentVideoViewCallbackBlock(newContents);
    }
    
}

@end
