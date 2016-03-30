//
//  SettingsCallViewController.m
//  QBRTCChatSemple
//
//  Created by Andrey Ivanov on 11.12.14.
//  Copyright (c) 2014 QuickBlox Team. All rights reserved.
//

#import "OutgoingCallViewController.h"

#import "CallViewController.h"
#import "CheckUserTableViewCell.h"
#import "IncomingCallViewController.h"
#import "QMSoundManager.h"
#import "SVProgressHUD.h"
#import "SVProgressHUD.h"
#import "Settings.h"
#import "SampleCore.h"
#import "SampleCoreManager.h"
#import "UsersDataSourceProtocol.h"
#import "SessionSettingsViewController.h"

#import "OutgoingCallViewControllerNavTitleView.h"

NSString *const kCheckUserTableViewCellIdentifier = @"CheckUserTableViewCellIdentifier";
const NSUInteger kTableRowHeight = 44;

@interface OutgoingCallViewController ()

<UITableViewDataSource, UITableViewDelegate, QBRTCClientDelegate, IncomingCallViewControllerDelegate>

@property (strong, nonatomic) NSMutableArray *selectedUsers;
@property (strong, nonatomic) UINavigationController *nav;
@property (weak, nonatomic) QBRTCSession *currentSession;

@end

@implementation OutgoingCallViewController

- (void)dealloc {
    NSLog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[QBRTCClient instance] addDelegate:self];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.rowHeight = kTableRowHeight;
    self.selectedUsers = [NSMutableArray array];

	
	CGRect frame = self.navigationController.navigationBar.bounds;
	
	NSString *tag = [[[[SampleCore usersDataSource] currentUser] tags] firstObject];
	NSString *loggedIn = [NSString stringWithFormat:@"Logged in as %@", [SampleCore usersDataSource].currentUser.fullName];
	
	
	OutgoingCallViewControllerNavTitleView *navTitle = [[OutgoingCallViewControllerNavTitleView alloc]
														initWithTopTitle:tag
														middleTitle:loggedIn
														frame:frame];
	self.navigationItem.prompt = nil;
	self.navigationItem.titleView = navTitle;
}

- (void)accountLogout {
	[[QBRTCClient instance] removeDelegate:self];
	
	UIColor *currentUserColor = [[SampleCore usersDataSource] colorAtCurrentUser];
	[SVProgressHUD setBackgroundColor:currentUserColor];
	
	__weak __typeof(self)weakSelf = self;
	
	void (^logoutCompletion)() = ^void() {
		[SVProgressHUD dismiss];
		
		[weakSelf.navigationController popViewControllerAnimated:YES];
	};
	
	[SVProgressHUD showWithStatus:@"Deleting user from QB"];
	[[SampleCoreManager instance] accountLogoutWithUnsubscribingBlock:^{
		[SVProgressHUD showWithStatus:@"Unsubscribing from push notifications" ];
	} successBlock:^{
		logoutCompletion();
	} errorBlock:^{
		logoutCompletion();
	}];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [[SampleCore usersDataSource] usersWithoutMe].count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return 0.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CheckUserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCheckUserTableViewCellIdentifier];
	

    QBUUser *user = [[SampleCore usersDataSource] usersWithoutMe][indexPath.row];
	NSUInteger userIndex = [[SampleCore usersDataSource] indexOfUser:user];
    NSString *text = [NSString stringWithFormat:@"%tu", userIndex + 1];
	
	UIColor *userColor = [[SampleCore usersDataSource] colorAtUser:user];

    [cell setMarkerColor:userColor];
	[cell setMarkerText:[user.fullName substringToIndex:1]];
    cell.userDescription = [NSString stringWithFormat:@"%@", user.fullName];
    
    BOOL checkMark = [self.selectedUsers containsObject:user];
    [cell setCheckmark:checkMark];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    QBUUser *user = [[SampleCore usersDataSource] usersWithoutMe][indexPath.row];
    [self procUser:user];
    
    CheckUserTableViewCell *cell = (id)[tableView cellForRowAtIndexPath:indexPath];
    BOOL checkMark = [self.selectedUsers containsObject:user];
    [cell setCheckmark:checkMark];
}

#pragma mark Actions

- (IBAction)pressAudioCallBtn:(id)sender {
    
    [self callWithConferenceType:QBRTCConferenceTypeAudio];
}

- (IBAction)pressVideoCallBtn:(id)sender {
    
    [self callWithConferenceType:QBRTCConferenceTypeVideo];
}

- (void)callWithConferenceType:(QBRTCConferenceType)conferenceType {
    
    if (![self usersToCall]) {
		return;
	}
	NSParameterAssert(!self.currentSession);
	NSParameterAssert(!self.nav);
	
	NSArray *opponentsIDs = [[SampleCore usersDataSource] idsWithUsers:[self.selectedUsers copy]];
	//Create new session
	QBRTCSession *session = [[QBRTCClient instance] createNewSessionWithOpponents:opponentsIDs withConferenceType:conferenceType];
	
	if (!session) {
		[SVProgressHUD showErrorWithStatus:@"You should login to use chat API. Session hasn’t been created. Please try to relogin the chat."];
		return;
	}
	
	self.currentSession = session;
	CallViewController *callViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CallViewController"];
	callViewController.session = self.currentSession;
	
	self.nav = [[UINavigationController alloc] initWithRootViewController:callViewController];
	self.nav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	
	[self presentViewController:self.nav animated:NO completion:nil];
	
}

#pragma mark - QBWebRTCChatDelegate

- (void)didReceiveNewSession:(QBRTCSession *)session userInfo:(NSDictionary *)userInfo {
	__weak __typeof(self)weakSelf = self;
	
	[SampleCoreManager downloadAndCacheUserIfNeeded:session.initiatorID successBlock:^(QBUUser *user) {
		[weakSelf.tableView reloadData];
	} errorBlock:nil];
	 
    if (self.currentSession) {
        
        [session rejectCall:@{@"reject" : @"busy"}];
        return;
    }
	
	
    self.currentSession = session;
	
    NSParameterAssert(!self.nav);
    
    IncomingCallViewController *incomingViewController =
	[self.storyboard instantiateViewControllerWithIdentifier:@"IncomingCallViewController"];
	incomingViewController.delegate = self;
	
	self.nav = [[UINavigationController alloc] initWithRootViewController:incomingViewController];
	
	incomingViewController.session = session;
	
	[self presentViewController:self.nav animated:NO completion:nil];
}

- (void)sessionDidClose:(QBRTCSession *)session {
    
    if (session == self.currentSession ) {
		[SampleCoreManager instance].hasActiveCall = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            self.nav.view.userInteractionEnabled = NO;
            [self.nav dismissViewControllerAnimated:NO completion:nil];
            self.currentSession = nil;
            self.nav = nil;
        });
    }
}

#pragma mark - Selected users

- (BOOL)usersToCall {
    
    BOOL selectedUsersToCall = (self.selectedUsers.count > 0);
    
    if (!selectedUsersToCall) {
        
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Please select one or more users", nil)];
    }
    
    return selectedUsersToCall;
}

- (void)procUser:(QBUUser *)user {
    
    if (![self.selectedUsers containsObject:user]) {
        
        [self.selectedUsers addObject:user];
    }
    else {
        
        [self.selectedUsers removeObject:user];
    }
}

- (void)incomingCallViewController:(IncomingCallViewController *)vc didAcceptSession:(QBRTCSession *)session {
    [SampleCoreManager instance].hasActiveCall = YES;
	
    CallViewController *callViewController =
    [self.storyboard instantiateViewControllerWithIdentifier:@"CallViewController"];
    
    callViewController.session = session;
    self.nav.viewControllers = @[callViewController];
}

- (void)incomingCallViewController:(IncomingCallViewController *)vc didRejectSession:(QBRTCSession *)session {
    
    [session rejectCall:nil];
    [self.nav dismissViewControllerAnimated:NO completion:nil];
    self.nav = nil;
}

@end
