//
//  QBMApplePushEvent.h
//  MessagesService
//

//  Copyright 2011 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBMEvent.h"

@class QBMPushMessage;
@class QBMApplePushEvent;

/** QBMApplePushEvent class declaration. */
/** Overview */
/** Push event representation */

@interface QBMApplePushEvent : QBMEvent <NSCoding, NSCopying>{
	QBMPushMessage *pushMessage;
}

/** Apple push message to send to subscribers */
@property (nonatomic,retain) QBMPushMessage *pushMessage;

/** Create new push event
 @return New instance of QBMApplePushEvent
 */
+ (QBMApplePushEvent *)pushEvent;

@end
