//
//  QBWebRTCChat.h
//  QuickbloxWebRTC
//
//  Created by Andrey Ivanov on 01.12.14.
//  Copyright (c) 2014 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBRTCTypes.h"

@class QBRTCSession;
@protocol QBRTCChatDelegate;

@interface QBRTCChat : NSObject

+ (instancetype)instance;

/** Adds the given delegate implementation to the list of observers*/
- (void)addDelegate:(id <QBRTCChatDelegate>)delegate;

/** Removes the given delegate implementation from the list of observers*/
- (void)removeDelegate:(id <QBRTCChatDelegate>)delegate;

/**
 *  Call to users.
 *
 *  @param users          IDS of opponents
 *  @param conferenceType  Type of conference. 'QBConferenceTypeAudio' and 'QBConferenceTypeVideo' values are available
 *
 *  @return New QBWebRTCSession instance
 */
- (QBRTCSession *)createNewSessionWithOpponents:(NSArray *)opponents
                             withConferenceType:(QBConferenceType)conferenceType;
@end
