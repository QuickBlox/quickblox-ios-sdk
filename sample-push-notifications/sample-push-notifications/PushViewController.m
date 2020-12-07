//
//  ViewController.m
//  sample-push-notifications
//
//  Created by Injoit on 6/11/15.
//  Copyright (c) 2015 QuickBlox. All rights reserved.
//

#import "PushViewController.h"
#import <Quickblox/Quickblox.h>
#import <SVProgressHUD.h>
#import "SAMTextView.h"
#import "UIViewController+InfoScreen.h"
#import "Profile.h"
#import "NotificationsProvider.h"
#import "AppDelegate.h"
#import "RootParentVC.h"

@interface PushViewController () <UITableViewDataSource, UITableViewDelegate, NotificationsProviderDelegate>

#pragma mark - Properties
@property (weak, nonatomic) IBOutlet SAMTextView *pushMessageTextView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sendPushButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@property (assign, nonatomic) PushType currentPushType;
@property (nonatomic, strong) NSMutableArray *pushMessages;
@property (nonatomic, strong) NotificationsProvider *notificationsProvider;

@end

@implementation PushViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.notificationsProvider = [[NotificationsProvider alloc] init];
    self.notificationsProvider.delegate = self;
    self.pushMessages = [NSMutableArray array];
    self.currentPushType = PushTypeAPNS;
    
    NSDictionary* attributes = @{NSFontAttributeName : [UIFont systemFontOfSize:17.0f],
                                 NSForegroundColorAttributeName : [UIColor colorWithWhite:0.0f alpha:0.3f]};
    self.pushMessageTextView.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Enter push message here" attributes:attributes];
    self.pushMessageTextView.textContainerInset = (UIEdgeInsets){10.0f, 10.0f, 0.0f, 0.0f};
    
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, self.pushMessageTextView.frame.size.height - 1.0f, self.pushMessageTextView.frame.size.width, 1.0f);
    bottomBorder.backgroundColor = [UIColor colorWithRed:200.0f/255.0f
                                                   green:199.0f/255.0f
                                                    blue:204.0f/255.0f
                                                   alpha:1.0f].CGColor;
    [self.pushMessageTextView.layer addSublayer:bottomBorder];
    
    self.sendPushButton.enabled = NO;
    
    Profile *profile = [[Profile alloc] init];
    if (profile.isFull) {
        self.title = profile.fullName;
        self.sendPushButton.enabled = YES;
    } else {
        [SVProgressHUD showErrorWithStatus:@"You are not authorized."];
    }
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(logoutButtonPressed:)];
    [self addInfoButton];
}

#pragma mark - Actions
- (IBAction)pushTypeDidChanged:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        self.currentPushType = PushTypeAPNS;
    } else if (sender.selectedSegmentIndex == 1) {
        self.currentPushType = PushTypeAPNSVOIP;
    }
}

- (void)sendPushWithMessage:(NSString *)message {
    
    Profile *profile = [[Profile alloc] init];
    if (!profile.isFull) {
        return;
    }
    
    NSString *currentUserId = [NSString stringWithFormat:@"%@", @(profile.ID)];
    
    if (self.currentPushType == PushTypeAPNS) {
        [SVProgressHUD showWithStatus:@"Sending a APNS Push"];
        
        [QBRequest sendPushWithText:message toUsers:currentUserId successBlock:^(QBResponse *response, NSArray *events) {
            [SVProgressHUD showSuccessWithStatus:@"Your message successfully sent"];
        } errorBlock:^(QBError *error) {
            [SVProgressHUD showErrorWithStatus:error.description];
        }];
        
    } else if (self.currentPushType == PushTypeAPNSVOIP) {
        [SVProgressHUD showWithStatus:@"Sending a VOIP Push"];
        NSDictionary *payload = @{
            @"message"  : message,
            @"ios_voip" : @"1",
            @"VOIPCall"  : @"1",
            @"alertMessage": message
        };
        NSData *data =
        [NSJSONSerialization dataWithJSONObject:payload
                                        options:NSJSONWritingPrettyPrinted
                                          error:nil];
        NSString *eventMessage =
        [[NSString alloc] initWithData:data
                              encoding:NSUTF8StringEncoding];
        
        QBMEvent *event = [QBMEvent event];
        event.notificationType = QBMNotificationTypePush;
        event.usersIDs = currentUserId;
        event.type = QBMEventTypeOneShot;
        event.message = eventMessage;
        
        [QBRequest createEvent:event
                  successBlock:^(QBResponse *response, NSArray<QBMEvent *> *events) {
            [SVProgressHUD showSuccessWithStatus:@"Your message successfully sent"];
        } errorBlock:^(QBResponse * _Nonnull response) {
            [SVProgressHUD showErrorWithStatus:response.description];
        }];
    }
}

#pragma mark Logout
- (void)logoutButtonPressed:(UIButton *)sender {
    [SVProgressHUD showWithStatus:@"Logout..."];
    
#if TARGET_OS_SIMULATOR
    [self logOut];
#else
    NSString *deviceIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    __weak __typeof(self)weakSelf = self;
    [QBRequest subscriptionsWithSuccessBlock:^(QBResponse * _Nonnull response, NSArray<QBMSubscription *> * _Nullable objects) {
        __typeof(weakSelf)strongSelf = weakSelf;
        dispatch_group_t deleteSubscriptionsGroup = dispatch_group_create();
        for (QBMSubscription *subscription in objects) {
            if ([subscription.deviceUDID isEqualToString:deviceIdentifier]) {
                dispatch_group_enter(deleteSubscriptionsGroup);
                [QBRequest deleteSubscriptionWithID:subscription.ID successBlock:^(QBResponse * _Nonnull response) {
                    dispatch_group_leave(deleteSubscriptionsGroup);
                    NSLog(@"[%@] Unregister Subscription request - Success",  NSStringFromClass([NotificationsProvider class]));
                } errorBlock:^(QBResponse * _Nonnull response) {
                    dispatch_group_leave(deleteSubscriptionsGroup);
                    NSLog(@"[%@] Unregister Subscription request - Error",  NSStringFromClass([NotificationsProvider class]));
                }];
            }
        }
        dispatch_group_notify(deleteSubscriptionsGroup, dispatch_get_main_queue(), ^{
            [strongSelf logOut];
        });
        
    } errorBlock:^(QBResponse * _Nonnull response) {
        if (response.status == 404) {
            [self showLoginScreen];
        }
    }];
#endif
}

- (void)showLoginScreen {
    [Profile clear];
    [self.rootParentVC showLoginScreen];
    [SVProgressHUD showSuccessWithStatus:@"Completed"];
}

- (void)logOut {
    __weak __typeof(self)weakSelf = self;
    [QBRequest logOutWithSuccessBlock:^(QBResponse * _Nonnull response) {
        __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf showLoginScreen];
    } errorBlock:^(QBResponse * _Nonnull response) {
        if (response.error.error) {
            [SVProgressHUD showErrorWithStatus:response.error.error.localizedDescription];
            return;
        }
    }];
}

- (IBAction)sendPush:(id)sender {
    [self.view endEditing:YES];
    NSString *message = self.pushMessageTextView.text;
    // empty text
    if([message length] == 0) {
        [SVProgressHUD showInfoWithStatus:@"Please enter some text"];
        return;
    }
    [self sendPushWithMessage:message];
    [self.pushMessageTextView resignFirstResponder];
    self.pushMessageTextView.text = nil;
}

#pragma mark - Internal Methods
- (void)didReceivePush:(NSArray<NSString *> *)messages {
    for (NSString *message in messages) {
        [self.pushMessages insertObject:message atIndex:0];
    }
    [self.tableView reloadData];
}

#pragma mark TableViewDataSource & TableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.pushMessages count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PushMessageCellIdentifier"];
    cell.textLabel.text = self.pushMessages[indexPath.row];
    
    return cell;
}

#pragma mark NotificationsProviderDelegate
- (void)notificationsProvider:(NotificationsProvider *)notificationsProvider didReceiveMessages:(NSArray<NSString *> *)messages {
    [self didReceivePush:messages];
}

- (void)notificationsProvider:(NotificationsProvider *)notificationsProvider willPresentMessage:(NSString *)message {
    [self didReceivePush:@[message]];
}

- (void)notificationsProvider:(NotificationsProvider *)notificationsProvider didReceiveIncomingVOIPPushWithMessage:(NSString *)message {
    [self didReceivePush:@[message]];
}

#pragma mark - RootParentVC
- (RootParentVC*)rootParentVC {
    return (RootParentVC *)[[UIApplication sharedApplication] delegate].window.rootViewController;
}

@end
