//
//  QBMSendPushTask.h
//  MessagesService
//

//  Copyright 2011 QuickBlox team. All rights reserved.
//

#import "Task.h"

@class QBMPushMessage;

@interface QBMSendPushTask : Task {
	NSString *usersIDs;
    NSString *usersTagsAny;
	
    QBMPushMessage *pushMessage;
    NSString *simplePushText;
    
    BOOL isEnvironmentDevelopment;
}
@property (nonatomic, retain) NSString *usersIDs;
@property (nonatomic, retain) NSString *usersTagsAny;
@property (nonatomic, retain) QBMPushMessage *pushMessage;
@property (nonatomic, retain) NSString *simplePushText;
@property (nonatomic) BOOL isDevelopmentEnvironment;


@end
