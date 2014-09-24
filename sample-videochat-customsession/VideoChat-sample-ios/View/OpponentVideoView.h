//
//  OpponentVideoView.h
//  VideoChat
//
//  Created by Igor Khomenko on 9/24/14.
//  Copyright (c) 2014 Ruslan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^OpponentVideoViewCallbackBlock)(id data);

@interface OpponentVideoView : UIImageView

@property (nonatomic, copy) OpponentVideoViewCallbackBlock opponentVideoViewCallbackBlock;

@end

@interface OpponentVideoViewLayer : CALayer

@end