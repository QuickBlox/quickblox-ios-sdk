//
//  QBMPushTokenAnswer.h
//  MessagesService
//

//  Copyright 2010 QuickBlox team. All rights reserved.
//

#import "EntityAnswer.h"

@class QBMPushToken;

@interface QBMPushTokenAnswer : EntityAnswer {

}
@property (nonatomic,readonly) QBMPushToken *pushToken;

@end
