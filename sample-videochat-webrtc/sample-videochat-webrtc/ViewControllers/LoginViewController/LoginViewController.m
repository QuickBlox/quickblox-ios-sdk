//
//  LoginViewController.m
//  QBRTCChatSemple
//
//  Created by Andrey Ivanov on 04.12.14.
//  Copyright (c) 2014 QuickBlox Team. All rights reserved.
//

#import "LoginViewController.h"
#import "SettingsCallViewController.h"
#import "UserTableViewCell.h"
#import "SVProgressHUD.h"
#import "ConnectionManager.h"
#import "CallManager.h"

NSString *const kSettingsCallSegueIdentifier = @"SettingsCallSegue";
NSString *const kUserTableViewCellIdentifier =  @"UserTableViewCellIdentifier";

const CGFloat kInfoHeaderHeight = 44;

@interface LoginViewController()

<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *buildVersionLabel;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.rowHeight = 44;
    self.buildVersionLabel.text = [self version];
}

#pragma mark - Verison

- (NSString *)version {
    
    NSString *appVersion = NSBundle.mainBundle.infoDictionary[@"CFBundleShortVersionString"];
    NSString *appBuild = NSBundle.mainBundle.infoDictionary[@"CFBundleVersion"];
    NSString *version = [NSString stringWithFormat:@"v:%@ %@\nbuild %@\nQBv%@:r%@",
                         appVersion, QB_VERSION_STR, appBuild, QuickbloxWebRTCFrameworkVersion, QuickbloxWebRTCRevision];
    
    return version;
}

#pragma makr - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return ConnectionManager.instance.users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kUserTableViewCellIdentifier];
    
    QBUUser *user = ConnectionManager.instance.users[indexPath.row];
    
    [cell setColorMarkerText:[NSString stringWithFormat:@"%ld", (long)indexPath.row + 1]
                    andColor:user.color];
    
    cell.userDescription = [NSString stringWithFormat:@"Login as %@", user.fullName];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    
    if([view isKindOfClass:[UITableViewHeaderFooterView class]]){
        
        UITableViewHeaderFooterView *tableViewHeaderFooterView = (UITableViewHeaderFooterView *) view;
        tableViewHeaderFooterView.textLabel.text = NSLocalizedString(@"Login as any user on this device and another(s) users on another device", nil);
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return @"header";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return kInfoHeaderHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return 0.0f;
}

#pragma makr - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
    
    QBUUser *user = ConnectionManager.instance.users[indexPath.row];
    [self logInChatWithUser:user];
}

#pragma Login in chat

- (void)logInChatWithUser:(QBUUser *)user {
    
    [SVProgressHUD setBackgroundColor:user.color];
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Login chat", nil)];
    
    __weak __typeof(self)weakSelf = self;
    [[ConnectionManager instance] logInWithUser:user
                                     completion:^(BOOL error)
     {
         if (!error) {
             
             [SVProgressHUD dismiss];
             [weakSelf performSegueWithIdentifier:kSettingsCallSegueIdentifier
                                           sender:nil];
         }
         else {
             
             [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Login chat error!", nil)];
         }
     }];
}

@end
