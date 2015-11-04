//
//  SettingsCallViewController.m
//  QBRTCChatSemple
//
//  Created by Andrey Ivanov on 11.12.14.
//  Copyright (c) 2014 QuickBlox Team. All rights reserved.
//

#import "OutgoingCallViewController.h"

#import "CallViewController.h"
#import "ChatManager.h"
#import "CheckUserTableViewCell.h"
#import "IncomingCallViewController.h"
#import "QMSoundManager.h"
#import "SVProgressHUD.h"
#import "UsersDataSource.h"

NSString *const kCheckUserTableViewCellIdentifier = @"CheckUserTableViewCellIdentifier";
const NSUInteger kSettingsInfoHeaderHeight = 25;
const NSUInteger kTableRowHeight = 44;

@interface OutgoingCallViewController ()

<UITableViewDataSource, UITableViewDelegate, QBRTCClientDelegate, IncomingCallViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

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
    
    [QBRTCClient.instance addDelegate:self];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.rowHeight = kTableRowHeight;
    self.selectedUsers = [NSMutableArray array];
    self.users = UsersDataSource.instance.usersWithoutMe;
    
    __weak __typeof(self)weakSelf = self;
    [self setDefaultBackBarButtonItem:^{
        
        [ChatManager.instance logOut];
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
    
    self.title = [NSString stringWithFormat:@"Logged in as %@", UsersDataSource.instance.currentUser.fullName];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.users.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return 0.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CheckUserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCheckUserTableViewCellIdentifier];
    
    QBUUser *user = self.users[indexPath.row];
    NSString *text = [NSString stringWithFormat:@"%lu", (unsigned long)user.index + 1];
    
    [cell setColorMarkerText:text andColor:user.color];
    cell.userDescription = [NSString stringWithFormat:@"%@", user.fullName];
    
    BOOL checkMark = [self.selectedUsers containsObject:user];
    [cell setCheckmark:checkMark];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    QBUUser *user = self.users[indexPath.row];
    [self procUser:user];
    
    CheckUserTableViewCell *cell = (id)[tableView cellForRowAtIndexPath:indexPath];
    BOOL checkMark = [self.selectedUsers containsObject:user];
    [cell setCheckmark:checkMark];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    
    if([view isKindOfClass:[UITableViewHeaderFooterView class]]){
        
        UITableViewHeaderFooterView *tableViewHeaderFooterView = (UITableViewHeaderFooterView *) view;
        tableViewHeaderFooterView.textLabel.text = NSLocalizedString(@"Select users you want to call", nil);
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return @"header";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return kSettingsInfoHeaderHeight;
}

#pragma mark Actions

- (IBAction)pressAudioCallBtn:(id)sender {
    
    [self callWithConferenceType:QBRTCConferenceTypeAudio];
}

- (IBAction)pressVideoCallBtn:(id)sender {
    
    [self callWithConferenceType:QBRTCConferenceTypeVideo];
}

- (void)callWithConferenceType:(QBRTCConferenceType)conferenceType {
    
    if ([self usersToCall]) {
        
        NSParameterAssert(!self.currentSession);
        NSParameterAssert(!self.nav);
        
        NSArray *opponentsIDs = [UsersDataSource.instance idsWithUsers:self.selectedUsers];
        //Create new session
        QBRTCSession *session = [QBRTCClient.instance createNewSessionWithOpponents:opponentsIDs withConferenceType:conferenceType];
        
        if (session) {
			
            self.currentSession = session;
            CallViewController *callViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CallViewController"];
            callViewController.session = self.currentSession;
            
            self.nav = [[UINavigationController alloc] initWithRootViewController:callViewController];
            self.nav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            
            [self presentViewController:self.nav animated:NO completion:nil];
        }
        else {
            
            [SVProgressHUD showErrorWithStatus:@"You should login to use chat API. Session hasn’t been created. Please try to relogin the chat."];
        }
    }
}

#pragma mark - QBWebRTCChatDelegate

- (void)didReceiveNewSession:(QBRTCSession *)session userInfo:(NSDictionary *)userInfo {
    
    if (self.currentSession) {
        
        [session rejectCall:@{@"reject" : @"busy"}];
        return;
    }
    
    self.currentSession = session;
	
	[QBRTCSoundRouter.instance initialize];
	
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
    
    BOOL isOK = (self.selectedUsers.count > 0);
    
    if (!isOK) {
        
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Please select one or more users", nil)];
    }
    
    return isOK;
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
