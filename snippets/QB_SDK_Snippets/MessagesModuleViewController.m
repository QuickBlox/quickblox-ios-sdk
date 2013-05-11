//
//  MessagesModuleViewController.m
//  QB_SDK_Samples
//
//  Created by Igor Khomenko on 6/14/12.
//  Copyright (c) 2012 Injoit. All rights reserved.
//

#import "MessagesModuleViewController.h"

@interface MessagesModuleViewController ()

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return 2;
        case 1:
            return 3;
        case 2:
            return 6;
        case 3:
            return 6;
            
        default:
            break;
    }
    
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return @"PushToken";
        case 1:
            return @"Subscription";
        case 2:
            return @"Event";;
            break;
        case 3:
            return @"Tasks";
            break;
            
        default:
            break;
    }

    
    return @"";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    switch (indexPath.section) {
        // Push Token
        case 0:
            switch (indexPath.row) {
                // Create Push Token
                case 0:{
                    QBMPushToken *pushToken = [QBMPushToken pushToken];
                    pushToken.isEnvironmentDevelopment = YES;
                    pushToken.clientIdentificationSequence = @"aa557232bc237245ba67686484efab";
                    
                    if(withContext){
                        [QBMessages createPushToken:pushToken delegate:self context:testContext]; 
                    }else{
                        [QBMessages createPushToken:pushToken delegate:self];
                    }
                }
                    break;
                    
                // Delete Push Token
                case 1:{
                    if(withContext){
                        [QBMessages deletePushTokenWithID:3351 delegate:self context:testContext]; 
                    }else{
                        [QBMessages deletePushTokenWithID:3351 delegate:self];
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
                    subscription.notificationChannel = QBMNotificatioChannelAPNS;
                    
                    if(withContext){
                        [QBMessages createSubscription:subscription delegate:self context:testContext]; 
                    }else{
                        [QBMessages createSubscription:subscription delegate:self];
                    }
                }
                    break;
                    
                // Get Subscriptions
                case 1:{
                    if(withContext){
                        [QBMessages subscriptionsWithDelegate:self context:testContext]; 
                    }else{
                        [QBMessages subscriptionsWithDelegate:self];
                    }
             
                }
                    break;
                    
                // Delete Subscription
                case 2:{
                    if(withContext){
                        [QBMessages deleteSubscriptionWithID:3352 delegate:self context:testContext]; 
                    }else{
                        [QBMessages deleteSubscriptionWithID:3352 delegate:self];
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
                    QBMEvent *event = [QBMEvent event];
                    event.notificationType = QBMNotificationTypePush;
                    event.usersIDs = @"14605,300";
                    event.isDevelopmentEnvironment = YES;
                    event.type = QBMEventTypeOneShot; 
                    //
                    event.message = @"New message is available for you";
                    
                    if(withContext){
                        [QBMessages createEvent:event delegate:self context:testContext]; 
                    }else{
                        [QBMessages createEvent:event delegate:self];
                    }
                }
                    break;
                    
                // Get Event with ID
                case 1:{
                    if(withContext){
                        [QBMessages eventWithID:460 delegate:self context:testContext]; 
                    }else{
                        [QBMessages eventWithID:460 delegate:self];
                    }
                }
                    break;
                    
                // Get Events
                case 2:{
                    if(withAdditionalRequest){
                        PagedRequest *pagedRequest = [[PagedRequest alloc] init];
                        pagedRequest.perPage = 3;
                        pagedRequest.page = 2;
                        
                        if(withContext){
                            [QBMessages eventsWithPagedRequest:pagedRequest delegate:self context:testContext];
                        }else{
                            [QBMessages eventsWithPagedRequest:pagedRequest delegate:self];
                        }
                        
                        [pagedRequest release];
                        
                    }else{
                        if(withContext){
                            [QBMessages eventsWithDelegate:self context:testContext];
                        }else{
                            [QBMessages eventsWithDelegate:self];
                        }
                    } 

                }
                    break;
                
                // Get Pull Events
                case 3:{
                    if(withContext){
                        [QBMessages pullEventsWithDelegate:self context:testContext];
                    }else{
                        [QBMessages pullEventsWithDelegate:self];
                    }
                }
                    break;
                    
                // Update Event
                case 4:{
                    QBMEvent *event = [QBMEvent event];
                    event.ID = 460;
                    event.name = @"News notification";
                    event.active = YES;
                    
                    if(withContext){
                        [QBMessages updateEvent:event delegate:self context:testContext]; 
                    }else{
                        [QBMessages updateEvent:event delegate:self];
                    }
                }
                    break;
                    
                // Delete Event
                case 5:{
                    if(withContext){
                        [QBMessages deleteEventWithID:275 delegate:self context:testContext]; 
                    }else{
                        [QBMessages deleteEventWithID:275 delegate:self];
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
                    if(withContext){
                        [QBMessages TRegisterSubscriptionWithDelegate:self context:testContext]; 
                    }else{
                        [QBMessages TRegisterSubscriptionWithDelegate:self];
                    }
                }
                    break;
                    
                // TUnregisterSubscription
                case 1:{
                    if(withContext){
                        [QBMessages TUnregisterSubscriptionWithDelegate:self context:testContext];
                    }else{
                        [QBMessages TUnregisterSubscriptionWithDelegate:self];
                    }
                }
                    break;
                    
                // TSendPush to users' ids
                case 2:{
                    NSString *mesage = @"Hello man!";
                    
                    NSMutableDictionary *payload = [NSMutableDictionary dictionary];
                    NSMutableDictionary *aps = [NSMutableDictionary dictionary];
                    [aps setObject:@"default" forKey:QBMPushMessageSoundKey];
                    [aps setObject:mesage forKey:QBMPushMessageAlertKey];
                    [payload setObject:aps forKey:QBMPushMessageApsKey];
                    
                    QBMPushMessage *message = [[QBMPushMessage alloc] initWithPayload:payload];
                    
                    // Send push
                    if(withContext){
                        [QBMessages TSendPush:message toUsers:@"300" delegate:self context:testContext];
                    }else{
                        [QBMessages TSendPush:message toUsers:@"300" delegate:self];
                    }
                    
                    [message release];
                }
                    break;
                    
                // TSendPushWithText to users' ids
                case 3:{
                    if(withContext){
                        [QBMessages TSendPushWithText:@"Hello World" toUsers:@"45288" delegate:self context:testContext];
                    }else{
                        [QBMessages TSendPushWithText:@"Hello World" toUsers:@"45288" delegate:self];
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
                    
                    // Send push
                    if(withContext){
                        [QBMessages TSendPush:message toUsersWithAnyOfTheseTags:@"man,car" delegate:self context:testContext];
                    }else{
                        [QBMessages TSendPush:message toUsersWithAnyOfTheseTags:@"man,car" delegate:self];
                    }
                    
                    [message release];
                }
                    break;
                    
                // TSendPushWithText to users' tags
                case 5:{
                    if(withContext){
                        [QBMessages TSendPushWithText:@"Hello World" toUsersWithAnyOfTheseTags:@"man,car" delegate:self context:testContext];
                    }else{
                        [QBMessages TSendPushWithText:@"Hello World" toUsersWithAnyOfTheseTags:@"man,car" delegate:self];
                    }
                }
                    break;
                    
            }
            break;
            
            
        default:
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *reuseIdentifier = [NSString stringWithFormat:@"%d", indexPath.row];
    
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if(cell == nil){
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    switch (indexPath.section) {
        // Push Token
        case 0:
            switch (indexPath.row) {
                case 0:{
                    cell.textLabel.text = @"Create Push Token";
                }
                    break;

                case 1:{
                    cell.textLabel.text = @"Delete Push Token";
                }
                    break;
            }
            break;
            
        // Subscription    
        case 1:
            switch (indexPath.row) {
                case 0:{
                    cell.textLabel.text = @"Create Subscription";
                }
                    break;
                    
                case 1:{
                    cell.textLabel.text = @"Get Subscriptions";
                }
                    break;
                    
                case 2:{
                    cell.textLabel.text = @"Delete Subscription";
                }
                    break;
            }
            
            break;
            
        // Event    
        case 2:
            switch (indexPath.row) {
                case 0:{
                    cell.textLabel.text = @"Create Event";
                }
                    break;
                    
                case 1:{
                    cell.textLabel.text = @"Get Event with ID";
                }
                    break;
                    
                case 2:{
                   cell.textLabel.text = @"Get Events"; 
                }
                    break;
                    
                case 3:{
                    cell.textLabel.text = @"Get Pull Events";
                }
                    break;
                    
                case 4:{
                    cell.textLabel.text = @"Update Event";
                }
                    break;
                    
                case 5:{
                   cell.textLabel.text = @"Delete Event"; 
                }
                    break;
            }
            
            break;
            
        // Tasks
        case 3:
            switch (indexPath.row) {
                case 0:{
                   cell.textLabel.text = @"TRegisterSubscription"; 
                }
                    break;
                    
                case 1:{ 
                    cell.textLabel.text = @"TUnregisterSubscription";
                }
                    break;
                
                case 2:{
                    cell.textLabel.text = @"TSendPush to users' ids";
                }
                    break;
                    
                case 3:{
                    cell.textLabel.text = @"TSendPushWithText to users' ids";
                }
                    break;
                    
                case 4:{
                    cell.textLabel.text = @"TSendPush to users' tags";
                }
                    break;
                case 5:{
                    cell.textLabel.text = @"TSendPushWithText to users' tags";
                }
                    break;
            }
            
        default:
            break;
    }    
    return cell;
}

// QuickBlox queries delegate
- (void)completedWithResult:(Result *)result{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
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
- (void)completedWithResult:(Result *)result context:(void *)contextInfo{
    NSLog(@"completedWithResult, context=%@", contextInfo);
    
    [self completedWithResult:result];
}


@end
