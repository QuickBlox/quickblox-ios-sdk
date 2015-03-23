//
//  MessagesModuleViewController.m
//  QB_SDK_Samples
//
//  Created by Igor Khomenko on 6/14/12.
//  Copyright (c) 2012 Injoit. All rights reserved.
//

#import "MessagesModuleViewController.h"
#import "MessagesDataSource.h"

@interface MessagesModuleViewController ()
@property (nonatomic) MessagesDataSource *dataSource;
@end

@implementation MessagesModuleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Messages", @"Messages");
        self.tabBarItem.image = [UIImage imageNamed:@"circle"];
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.dataSource = [[MessagesDataSource alloc] init];
    tableView.dataSource = self.dataSource;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    switch (indexPath.section) {
        // Push Token
        case 0:
            switch (indexPath.row) {
                // Create Push Token
                case 0:{
					
                    QBMPushToken *pushToken = [QBMPushToken pushToken];
                    pushToken.isEnvironmentDevelopment = ![QBApplication sharedApplication].productionEnvironmentForPushesEnabled;
                    pushToken.clientIdentificationSequence = @"6862604cbf607dd18af35f1c87af838fbe384fea37b1e38662d8b666c0dbd743";
                    
					if (useNewAPI) {
						[QBRequest createPushToken:pushToken successBlock:^(QBResponse *response, QBMPushToken *token) {
							NSLog(@"Successfull response!");
						} errorBlock:^(QBResponse *response) {
							NSLog(@"Response error:%@", response.error);
						}];
					} else {
						if(withQBContext){
							[QBMessages createPushToken:pushToken delegate:self context:testContext];
						}else{
							[QBMessages createPushToken:pushToken delegate:self];
						}
					}
					
                }
                    break;
                    // Create Push Token with custom UDID
                case 1:{
                    
                    QBMPushToken *pushToken = [QBMPushToken pushTokenWithCustomUDID:@"2b6f0cc904d137be2e1730235f5664094b831186"];
                    pushToken.isEnvironmentDevelopment = ![QBApplication sharedApplication].productionEnvironmentForPushesEnabled;
                    pushToken.clientIdentificationSequence = @"6862604cbf607dd18af35f1c87af838fbe384fea37b1e38662d8b666c0dbd743";
                    
                    if (useNewAPI) {
                        [QBRequest createPushToken:pushToken successBlock:^(QBResponse *response, QBMPushToken *token) {
                            NSLog(@"Successfull response!");
                        } errorBlock:^(QBResponse *response) {
                            NSLog(@"Response error:%@", response.error);
                        }];
                    } else {
                        if(withQBContext){
                            [QBMessages createPushToken:pushToken delegate:self context:testContext];
                        }else{
                            [QBMessages createPushToken:pushToken delegate:self];
                        }
                    }
                    
                }
                    break;
                    
                // Delete Push Token
                case 2:{
					
					if (useNewAPI) {
						[QBRequest deletePushTokenWithID:1498447 successBlock:^(QBResponse *response) {
							NSLog(@"Successfull response!");
						} errorBlock:^(QBResponse *response) {
							NSLog(@"Response error:%@", response.error);
						}];
					} else {
						if(withQBContext){
							[QBMessages deletePushTokenWithID:1017427 delegate:self context:testContext];
						}else{
							[QBMessages deletePushTokenWithID:1017427 delegate:self];
						}
					}
                }
                    break;
            }
            break;
                               
        // Subscription    
        case 1:
            switch (indexPath.row) {
                // Create Subscription
                case 0:{
                    QBMSubscription *subscription = [QBMSubscription subscription];
                    subscription.notificationChannel = QBMNotificationChannelAPNS;
                    
					if (useNewAPI) {
						[QBRequest createSubscription:subscription successBlock:^(QBResponse *response, NSArray *objects) {
							NSLog(@"Successfull response!");
						} errorBlock:^(QBResponse *response) {
							NSLog(@"Response error:%@", response.error);
						}];
					} else {
						if(withQBContext){
							[QBMessages createSubscription:subscription delegate:self context:testContext];
						}else{
							[QBMessages createSubscription:subscription delegate:self];
						}
					}
					
                }
                    break;
                    
                // Get Subscriptions
                case 1:{
					if (useNewAPI) {
						[QBRequest subscriptionsWithSuccessBlock:^(QBResponse *response, NSArray *objects) {
							NSLog(@"Successfull response!");
						} errorBlock:^(QBResponse *response) {
							NSLog(@"Response error:%@", response.error);
						}];
					} else {
						if(withQBContext){
							[QBMessages subscriptionsWithDelegate:self context:testContext];
						}else{
							[QBMessages subscriptionsWithDelegate:self];
						}
					}
                }
                    break;
                    
                // Delete Subscription
                case 2:{
					if (useNewAPI) {
						[QBRequest deleteSubscriptionWithID:1582581
											   successBlock:^(QBResponse *response) {
												   NSLog(@"Successfull response!");
											   } errorBlock:^(QBResponse *response) {
												   NSLog(@"Response error:%@", response.error);
											   }];
					} else {
						if(withQBContext){
							[QBMessages deleteSubscriptionWithID:3352 delegate:self context:testContext]; 
						}else{
							[QBMessages deleteSubscriptionWithID:3352 delegate:self];
						}
					}
                }
                    break;
                    
            }
            
            break;
        
        // Event    
        case 2:
            switch (indexPath.row) {
                // Create Event - notification will be delivered to all possible devices for specified users.
                case 0:{
//                    QBMEvent *event = [QBMEvent event];
//                    event.notificationType = QBMNotificationTypePush;
////                    event.usersIDs = [@(UserID1) description];
////                    event.usersExternalIDs = @"123, 456";
////                    event.usersTagsAll = @"man";
//                    event.usersTagsAny = @"people, people, people2, man";
////                    event.usersTagsExclude = @"alien";
//                    event.isDevelopmentEnvironment = ![QBApplication sharedApplication].productionEnvironmentForPushesEnabled;
//                    event.type = QBMEventTypeOneShot; 
//                    //
//                    NSMutableDictionary  *dictPush=[NSMutableDictionary  dictionaryWithObjectsAndKeys:@"Message received 😃 from Bob", @"message", nil];
//                    [dictPush setObject:@"44" forKey:@"ios_badge"];
//                    [dictPush setObject:@"mysound.wav" forKey:@"ios_sound"];
//                    [dictPush setObject:@"234" forKey:@"user_id"];
//                    //
//                    NSError *error = nil;
//                    NSData *sendData = [NSJSONSerialization dataWithJSONObject:dictPush options:NSJSONWritingPrettyPrinted error:&error];
//                    NSString *json = [[NSString alloc] initWithData:sendData encoding:NSUTF8StringEncoding];
//                    //
//                    event.message = json;
//                    
//					if (useNewAPI) {
//						[QBRequest createEvent:event successBlock:^(QBResponse *response, NSArray *events) {
//							NSLog(@"Successfull response!");
//						} errorBlock:^(QBResponse *response) {
//							NSLog(@"Response error:%@", response.error);
//						}];
//					} else {
//						if(withQBContext){
//							[QBMessages createEvent:event delegate:self context:testContext];
//						}else{
//							[QBMessages createEvent:event delegate:self];
//						}
//					}
                    
                    QBMEvent *event2 = [QBMEvent event];
                    event2.message = @"hello";
                    event2.notificationType = QBMNotificationTypeEmail;
                    event2.type = QBMEventTypeOneShot;
                    event2.usersIDs = [@([[ConfigManager sharedManager] testUserId1]) description];
                    [QBRequest createEvent:event2 successBlock:^(QBResponse *response, NSArray *events) {
                        NSLog(@"Successfull response!");
                    } errorBlock:^(QBResponse *response) {
                        NSLog(@"Response error:%@", response.error);
                    }];
					
                }
                    break;
                    
                // Get Event with ID
                case 1:{
					
					if (useNewAPI) {
						[QBRequest eventWithID:1462267 successBlock:^(QBResponse *response, QBMEvent *event) {
							NSLog(@"Successfull response!");
						} errorBlock:^(QBResponse *response) {
							NSLog(@"Response error:%@", response.error);
						}];
					}  else {
						if(withQBContext){
							[QBMessages eventWithID:460 delegate:self context:testContext];
						}else{
							[QBMessages eventWithID:460 delegate:self];
						}
					}
					
                }
                    break;
                    
                // Get Events
                case 2:{
					if (useNewAPI) {
						[QBRequest eventsForPage:[QBGeneralResponsePage responsePageWithCurrentPage:1 perPage:10]
									successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *events) {
										NSLog(@"Successfull response!");
									} errorBlock:^(QBResponse *response) {
										NSLog(@"Response error:%@", response.error);
									}];
					} else {
						if(withAdditionalRequest){
							PagedRequest *pagedRequest = [[PagedRequest alloc] init];
							pagedRequest.perPage = 3;
							pagedRequest.page = 2;
							
							if(withQBContext){
								[QBMessages eventsWithPagedRequest:pagedRequest delegate:self context:testContext];
							}else{
								[QBMessages eventsWithPagedRequest:pagedRequest delegate:self];
							}
						}else{
							if(withQBContext){
								[QBMessages eventsWithDelegate:self context:testContext];
							}else{
								[QBMessages eventsWithDelegate:self];
							}
						}
					}
				}
                    break;
                    
                // Update Event
                case 3:{
                    QBMEvent *event = [QBMEvent event];
                    event.ID = 1407007;
//                    event.name = @"News notification";
                    event.active = YES;
					
					if (useNewAPI) {
						[QBRequest updateEvent:event successBlock:^(QBResponse *response, QBMEvent *event) {
							NSLog(@"Successfull response!");
						} errorBlock:^(QBResponse *response) {
							NSLog(@"Response error:%@", response.error);
						}];
					} else {
						if(withQBContext) {
							[QBMessages updateEvent:event delegate:self context:testContext];
						} else {
							[QBMessages updateEvent:event delegate:self];
						}
					}
                    
                }
                    break;
                    
                // Delete Event
                case 4:{
					if (useNewAPI) {
						[QBRequest deleteEventWithID:1462267 successBlock:^(QBResponse *response) {
							NSLog(@"Successfull response!");
						} errorBlock:^(QBResponse *response) {
							NSLog(@"Response error:%@", response.error);
						}];
					} else {
						if(withQBContext){
							[QBMessages deleteEventWithID:1206039 delegate:self context:testContext];
						}else{
							[QBMessages deleteEventWithID:1206039 delegate:self];
						}
					}
                }
                    break;
            }
            
            break;
            
        // Tasks
        case 3:
            switch (indexPath.row) {
                // TRegisterSubscription
                case 0:{
					if (useNewAPI) {
                        
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
                        if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
                            
                            [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
                            [[UIApplication sharedApplication] registerForRemoteNotifications];
                        }
                        else{
                            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
                        }
#else
                        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
#endif
                        
                        
					} else {
						if(withQBContext){
							[QBMessages TRegisterSubscriptionWithDelegate:self context:testContext];
						}else{
							[QBMessages TRegisterSubscriptionWithDelegate:self];
						}
					}
					
                }
                    break;
                    
                // TUnregisterSubscription
                case 1:{
					if (useNewAPI) {
						[QBRequest unregisterSubscriptionWithSuccessBlock:^(QBResponse *response) {
							NSLog(@"Successfull response!");
						} errorBlock:^(QBError *error) {
							NSLog(@"Response error:%@", error);
						}];
					}
                    if(withQBContext){
                        [QBMessages TUnregisterSubscriptionWithDelegate:self context:testContext];
                    }else{
                        [QBMessages TUnregisterSubscriptionWithDelegate:self];
                    }
                }
                    break;
                    
                // TSendPush to users' ids
                case 2:{
                    NSMutableDictionary *payload = [NSMutableDictionary dictionary];
                    NSMutableDictionary *aps = [NSMutableDictionary dictionary];
                    [aps setObject:@"default" forKey:QBMPushMessageSoundKey];
                    [aps setObject:@"Hello World ?? amigo \"{}}}}} some//''\\\"" forKey:QBMPushMessageAlertKey];
                    [aps setObject:@"5" forKey:QBMPushMessageBadgeKey];
                    [aps setObject:@"PLAY" forKey:@"aps_key2"];
                    [payload setObject:aps forKey:QBMPushMessageApsKey];
                    
                    QBMPushMessage *message = [[QBMPushMessage alloc] initWithPayload:payload];
                    
					if (useNewAPI) {
						[QBRequest sendPush:message toUsers:[@([[ConfigManager sharedManager] testUserId1]) description] successBlock:^(QBResponse *response, QBMEvent *event) {
							NSLog(@"Successfull response!");
						} errorBlock:^(QBError *error) {
							NSLog(@"Response error:%@", error);
						}];
					} else {
						// Send push
						if(withQBContext){
							[QBMessages TSendPush:message toUsers:[@([[ConfigManager sharedManager] testUserId1]) description] delegate:self context:testContext];
						}else{
							[QBMessages TSendPush:message toUsers:[@([[ConfigManager sharedManager] testUserId1]) description] delegate:self];
						}
					}
                    
                }
                    break;
                    
                // TSendPushWithText to users' ids
                case 3:{
					if (useNewAPI) {
						[QBRequest sendPushWithText:@"Hello World <>😄 amigo" toUsers:[@([[ConfigManager sharedManager] testUserId1]) description] successBlock:^(QBResponse *response, NSArray *events) {
							NSLog(@"Successfull response!");
						} errorBlock:^(QBError *error) {
							NSLog(@"Response error:%@", error);
						}];
					} else {
						if(withQBContext){
							[QBMessages TSendPushWithText:@"Hello World" toUsers:[@([[ConfigManager sharedManager] testUserId1]) description] delegate:self context:testContext];
						}else{
							[QBMessages TSendPushWithText:@"Hello World" toUsers:[@([[ConfigManager sharedManager] testUserId1]) description] delegate:self];
						}
					}

                }
                    break;
                    
                // TSendPush to users' tags
                case 4:{
                    NSString *mesage = @"Hello man!";
                    
                    NSMutableDictionary *payload = [NSMutableDictionary dictionary];
                    NSMutableDictionary *aps = [NSMutableDictionary dictionary];
                    [aps setObject:@"default" forKey:QBMPushMessageSoundKey];
                    [aps setObject:mesage forKey:QBMPushMessageAlertKey];
                    [payload setObject:aps forKey:QBMPushMessageApsKey];
                    
                    QBMPushMessage *message = [[QBMPushMessage alloc] initWithPayload:payload];
                    
					if (useNewAPI) {
						[QBRequest sendPush:message toUsersWithAnyOfTheseTags:@"man" successBlock:^(QBResponse *response, QBMEvent *event) {
							NSLog(@"Successfull response!");
						} errorBlock:^(QBError *error) {
							NSLog(@"Response error:%@", error);
						}];
					} else {
						// Send push
						if(withQBContext){
							[QBMessages TSendPush:message toUsersWithAnyOfTheseTags:@"devdevdev2" delegate:self context:testContext];
						}else{
							[QBMessages TSendPush:message toUsersWithAnyOfTheseTags:@"devdevdev2" delegate:self];
						}
					}
                    
                }
                    break;
                    
                // TSendPushWithText to users' tags
                case 5:{
					if (useNewAPI) {
						[QBRequest sendPushWithText:@"Hello World" toUsersWithAnyOfTheseTags:@"man" successBlock:^(QBResponse *response, NSArray *event) {
							NSLog(@"Successfull response!");
						} errorBlock:^(QBError *error) {
							NSLog(@"Response error:%@", error);
						}];

					} else {
						if(withQBContext){
							[QBMessages TSendPushWithText:@"Hello World" toUsersWithAnyOfTheseTags:@"devdevdev2" delegate:self context:testContext];
						}else{
							[QBMessages TSendPushWithText:@"Hello World" toUsersWithAnyOfTheseTags:@"devdevdev2" delegate:self];
						}
					}
                }
                    break;
                    
            }
            break;
            
            
        default:
            break;
    }
}


// QuickBlox queries delegate
- (void)completedWithResult:(QBResult *)result{
    
    // success result
    if(result.success){
        
        // Create/Delete push token result
        if([result isKindOfClass:QBMPushTokenResult.class]){
            QBMPushTokenResult *res = (QBMPushTokenResult *)result;
            NSLog(@"QBMPushTokenResult, pushToken=%@", res.pushToken);

        // Create/Get/Delete subscriptionresult
        }else if([result isKindOfClass:QBMSubscriptionResult.class]){
            QBMSubscriptionResult *res = (QBMSubscriptionResult *)result;
            NSLog(@"QBMSubscriptionResult, subscriptions=%@", res.subscriptions);
        
        // Create/Get/Delete event
        }else if([result isKindOfClass:QBMEventResult.class]){
            QBMEventResult *res = (QBMEventResult *)result;
            NSLog(@"QBMEventResult, event=%@", res.event);
        
        // Get events
        }else if([result isKindOfClass:QBMEventPagedResult.class]){
            QBMEventPagedResult *res = (QBMEventPagedResult *)result;
            NSLog(@"QBMEventPagedResult, events=%@", res.events);
        
        // Register subscription Task result
        }else if([result isKindOfClass:QBMRegisterSubscriptionTaskResult.class]){
            QBMRegisterSubscriptionTaskResult *res = (QBMRegisterSubscriptionTaskResult *)result;
            NSLog(@"QBMRegisterSubscriptionTaskResult, subscriptions=%@", res.subscriptions);
        
        // Send push Task result
        }else if([result isKindOfClass:QBMSendPushTaskResult.class]){
            QBMSendPushTaskResult *res = (QBMSendPushTaskResult *)result;
            NSLog(@"QBMSendPushTaskResult %@",res);
            
        // Unregister subscription Task result
        } else if([result isKindOfClass:QBMUnregisterSubscriptionTaskResult.class]){
            QBMUnregisterSubscriptionTaskResult *res = (QBMUnregisterSubscriptionTaskResult *)result;
            NSLog(@"QBMUnregisterSubscriptionTaskResult, res=%@", res);
        }
        
    }else{
        NSLog(@"Errors=%@, Class=%@", result.errors, [result class]); 
    }
}

// QuickBlox queries delegate (with context)
- (void)completedWithResult:(QBResult *)result context:(void *)contextInfo{
    NSLog(@"completedWithResult, context=%@", contextInfo);
    
    [self completedWithResult:result];
}

-(void)setProgress:(float)progress{
    NSLog(@"setProgress %f", progress);
}


@end
