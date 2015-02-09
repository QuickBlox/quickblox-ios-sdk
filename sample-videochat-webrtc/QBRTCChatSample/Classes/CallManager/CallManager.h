//
//  CallManager.h
//  QBRTCChatSemple
//
//  Created by Andrey Ivanov on 17.12.14.
//  Copyright (c) 2014 QuickBlox Team. All rights reserved.
//

#import "BaseViewController.h"

@interface CallManager : NSObject

<QBRTCClientDelegate>

+ (instancetype)instance;

- (void)callToUsers:(NSArray *)users withConferenceType:(QBConferenceType)conferenceType;

@end
