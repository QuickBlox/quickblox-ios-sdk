//
//  QBMSendPushTask.h
//  MessagesService
//

//  Copyright 2011 QuickBlox team. All rights reserved.
//

@interface QBMSendPushTask : Task {
	NSString *usersIDs;
    NSString *usersTagsAny;
	QBMPushMessage *pushMessage;
    BOOL isEnvironmentDevelopment;
}
@property (nonatomic, retain) NSString *usersIDs;
@property (nonatomic, retain) NSString *usersTagsAny;
@property (nonatomic, retain) QBMPushMessage *pushMessage;
@property (nonatomic) BOOL isDevelopmentEnvironment;


@end
