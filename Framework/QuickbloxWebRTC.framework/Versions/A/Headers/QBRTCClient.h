//
//  QBRTCClient.h
//  QuickbloxWebRTC
//
//  Created by Andrey Ivanov on 01.12.14.
//  Copyright (c) 2014 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBRTCTypes.h"

@class QBRTCSession;
@protocol QBRTCClientDelegate;

@interface QBRTCClient : NSObject

- (id)init __attribute__((unavailable("init is not a supported initializer for this class.")));

+ (instancetype)instance;

/** Adds the given delegate implementation to the list of observers*/
- (void)addDelegate:(id <QBRTCClientDelegate>)delegate;

/** Removes the given delegate implementation from the list of observers*/
- (void)removeDelegate:(id <QBRTCClientDelegate>)delegate;

/**
 *  Create new session
 *
 *  @param opponents        IDS of opponents
 *  @param conferenceType   Type of conference. 'QBConferenceTypeAudio' and 'QBConferenceTypeVideo' values are available
 *
 *  @return New QBRTCSession instance
 */
- (QBRTCSession *)createNewSessionWithOpponents:(NSArray *)opponents
                             withConferenceType:(QBConferenceType)conferenceType;
@end
