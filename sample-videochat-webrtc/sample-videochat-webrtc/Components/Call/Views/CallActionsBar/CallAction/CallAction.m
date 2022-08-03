//
//  CallAction.m
//  sample-videochat-webrtc
//
//  Created by Injoit on 15.08.2021.
//  Copyright © 2021 QuickBlox Team. All rights reserved.
//

#import "CallAction.h"

@interface CallAction()
//MARK: - Properties
@property (assign, nonatomic) CallActionType typeAction;
@end



@implementation CallAction
//MARK: - Life Cycle
- (instancetype)initWithType:(CallActionType)typeAction action:(CallActionHandler)action {
    self = [super init];
    if (self) {
        _action = action;
        _typeAction = typeAction;
    }
    return self;
}

@end
