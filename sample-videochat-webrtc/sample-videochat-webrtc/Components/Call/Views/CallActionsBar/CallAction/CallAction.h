//
//  CallAction.h
//  sample-videochat-webrtc
//
//  Created by Injoit on 15.08.2021.
//  Copyright © 2021 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CallActionsBar.h"

NS_ASSUME_NONNULL_BEGIN

@class ActionButton;

typedef void(^CallActionHandler)(ActionButton *sender);

@interface CallAction : NSObject
//MARK: - Properties
@property (assign, nonatomic) ActionButton *button;
@property (assign, nonatomic, readonly) CallActionType typeAction;
@property (strong, nonatomic) CallActionHandler action;

- (instancetype)initWithType:(CallActionType)typeAction action:(CallActionHandler)action;

@end

NS_ASSUME_NONNULL_END
