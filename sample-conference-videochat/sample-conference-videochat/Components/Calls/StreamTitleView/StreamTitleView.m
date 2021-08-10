//
//  StreamTitleView.m
//  sample-conference-videochat
//
//  Created by Injoit on 15.06.2020.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import "StreamTitleView.h"

@implementation StreamTitleView

- (void)setupStreamTitleViewOnLive:(BOOL)onLive {
    self.frame = CGRectMake(0, 0, 72.0f, 20.0f);
    self.image = onLive == YES ? [UIImage imageNamed:@"live_streaming"] : [UIImage imageNamed:@"end_stream"];
}

@end
