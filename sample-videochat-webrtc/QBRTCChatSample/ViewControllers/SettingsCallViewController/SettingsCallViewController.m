//
//  SettingsCallViewController.m
//  QBRTCChatSemple
//
//  Created by Andrey Ivanov on 11.12.14.
//  Copyright (c) 2014 QuickBlox Team. All rights reserved.
//

#import "SettingsCallViewController.h"
#import "CheckUserTableViewCell.h"
#import "ConnectionManager.h"
#import "CallManager.h"
#import "SVProgressHUD.h"

NSString *const kCheckUserTableViewCellIdentifier = @"CheckUserTableViewCellIdentifier";
NSString *const kStunViewControllerIdentifier = @"StunViewController";

const CGFloat kSettingsInfoHeaderHeight = 25;

@interface SettingsCallViewController ()

<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *selectedUsers;

@end

@implementation SettingsCallViewController

- (void)dealloc {
    NSLog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [QBRTCClient.instance addDelegate:CallManager.instance];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.rowHeight = 44;
    self.selectedUsers = [NSMutableArray array];
    self.users = ConnectionManager.instance.usersWithoutMe;
    
    __weak __typeof(self)weakSelf = self;
    [self setDefaultBackBarButtonItem:^{
        
        [ConnectionManager.instance logOut];
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
    
    self.title = [NSString stringWithFormat:@"Logged in as %@", ConnectionManager.instance.me.fullName];
   
    UIBarButtonItem *anotherButton =
    [[UIBarButtonItem alloc] initWithTitle:@"STUN"
                                     style:UIBarButtonItemStylePlain
                                    target:self action:@selector(pressSelectStun:)];
    
    self.navigationItem.rightBarButtonItem = anotherButton;
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
    
    [cell setColorMarkerText:text
                    andColor:user.color];
    
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
    
    [tableView reloadRowsAtIndexPaths:@[indexPath]
                     withRowAnimation:UITableViewRowAnimationNone];
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

- (void)pressSelectStun:(id)sender {
    
    UINavigationController *navVC = [self.storyboard instantiateViewControllerWithIdentifier:kStunViewControllerIdentifier];
    [self presentViewController:navVC animated:YES completion:^{
        
    }];
}

- (IBAction)pressAudioCallBtn:(id)sender {
    
    [self callWithConferenceType:QBConferenceTypeAudio];
}

- (IBAction)pressVideoCallBtn:(id)sender {
    
    [self callWithConferenceType:QBConferenceTypeVideo];
}

- (void)callWithConferenceType:(QBConferenceType)conferenceType {
    
    if ([self usersToCall]) {
        
        [CallManager.instance callToUsers:self.selectedUsers
                       withConferenceType:conferenceType];
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

@end
