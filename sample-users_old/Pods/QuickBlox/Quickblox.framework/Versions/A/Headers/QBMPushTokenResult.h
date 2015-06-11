//
//  QBMPushTokenResult.h
//  MessagesService
//

//  Copyright 2010 QuickBlox team. All rights reserved.
//
#import "Result.h"

@class QBMPushToken;

/** QBMPushTokenResult class declaration. */
/** Overview */
/** This class is an instance, which will be returned to user after he made ​​the request for create push token. */

@interface QBMPushTokenResult : Result {

}

/** Push token */
@property (nonatomic,readonly) QBMPushToken *pushToken;

@end
