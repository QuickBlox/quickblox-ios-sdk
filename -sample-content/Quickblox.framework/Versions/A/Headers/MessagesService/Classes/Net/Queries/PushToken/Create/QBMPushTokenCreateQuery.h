//
//  QBMPushTokenCreateQuery.h
//  MessagesService
//

//  Copyright 2010 QuickBlox team. All rights reserved.
//

@interface QBMPushTokenCreateQuery : QBMPushTokenQuery {
	QBMPushToken *pushToken;
}
@property (nonatomic, retain) QBMPushToken *pushToken;

- (id)initWithPushToken:(QBMPushToken *)token;

@end
