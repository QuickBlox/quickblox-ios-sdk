//
//  LoginViewController.m
//  QBRTCChatSemple
//
//  Created by Andrey Ivanov on 04.12.14.
//  Copyright (c) 2014 QuickBlox Team. All rights reserved.
//

#import "LoginViewController.h"
#import "ChatManager.h"
#import "OutgoingCallViewController.h"
#import "QBUUser+IndexAndColor.h"
#import "Settings.h"
#import "SVProgressHUD.h"
#import "UsersDataSource.h"
#import "UserTableViewCell.h"

NSString *const kSettingsCallSegueIdentifier = @"SettingsCallSegue";
NSString *const kUserTableViewCellIdentifier =  @"UserTableViewCellIdentifier";

const CGFloat kInfoHeaderHeight = 44;

@interface LoginViewController()

<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *buildVersionLabel;
@property (strong, nonatomic) Settings *settings;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.rowHeight = 44;
    self.buildVersionLabel.text = [self version];
    self.settings = Settings.instance;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [UsersDataSource.instance loadUsersWithList:self.settings.listType];
    [self.tableView reloadData];
}

#pragma mark - Verison

- (NSString *)version {
    
    NSString *appVersion = NSBundle.mainBundle.infoDictionary[@"CFBundleShortVersionString"];
    NSString *appBuild = NSBundle.mainBundle.infoDictionary[@"CFBundleVersion"];
    NSString *version = [NSString stringWithFormat:@"App: %@(build %@)\nQuickbloxRTC: %@\nWebRTC revision:%@",
                         appVersion, appBuild, QuickbloxWebRTCFrameworkVersion, QuickbloxWebRTCRevision];
    return version;
}

#pragma makr - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return UsersDataSource.instance.users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kUserTableViewCellIdentifier];
    
    QBUUser *user = UsersDataSource.instance.users[indexPath.row];
    [cell setColorMarkerText:[NSString stringWithFormat:@"%ld", (long)indexPath.row + 1] andColor:user.color];
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
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    QBUUser *user = UsersDataSource.instance.users[indexPath.row];
    [self logInChatWithUser:user];
}

#pragma Login in chat

#define DEBUG_GUI 0

- (void)logInChatWithUser:(QBUUser *)user {
    
#if DEBUG_GUI
    [SVProgressHUD setBackgroundColor:[UIColor blackColor]];
    [self performSegueWithIdentifier:kSettingsCallSegueIdentifier sender:nil];
    
#else
    
    [SVProgressHUD setBackgroundColor:user.color];
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Login chat", nil)];
    
    __weak __typeof(self)weakSelf = self;
    [[ChatManager instance] logInWithUser:user completion:^(BOOL error) {
        
		if (!error) {
			
			[SVProgressHUD dismiss];
			[weakSelf applyConfiguration];
			[weakSelf performSegueWithIdentifier:kSettingsCallSegueIdentifier sender:nil];
		}
		else {
			
			[SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Login chat error!", nil)];
		}
	} disconnectedBlock:^{
        
		[SVProgressHUD showWithStatus:NSLocalizedString(@"Chat disconnected. Attempting to reconnect", nil)];
        
	} reconnectedBlock:^{
        
		[SVProgressHUD showSuccessWithStatus:@"Chat reconnected"];
	}];
	
#endif
}

- (void)applyConfiguration {
	
    NSMutableArray *iceServers = [NSMutableArray array];
    
    for (NSString *url in self.settings.stunServers) {
        
        QBRTCICEServer *server = [QBRTCICEServer serverWithURL:url username:@"" password:@""];
        [iceServers addObject:server];
    }
    
    [iceServers addObjectsFromArray:[self quickbloxICE]];
    
    [QBRTCConfig setICEServers:iceServers];
    [QBRTCConfig setMediaStreamConfiguration:self.settings.mediaConfiguration];
    [QBRTCConfig setStatsReportTimeInterval:1.f];
}

- (NSArray *)quickbloxICE {
    
    NSString *password = @"baccb97ba2d92d71e26eb9886da5f1e0";
    NSString *userName = @"quickblox";
    
    QBRTCICEServer * stunServer = [QBRTCICEServer serverWithURL:@"stun:turn.quickblox.com"
            username:@""
            password:@""];
    
    QBRTCICEServer * turnUDPServer = [QBRTCICEServer serverWithURL:@"turn:turn.quickblox.com:3478?transport=udp"
            username:userName
            password:password];
    
    QBRTCICEServer * turnTCPServer = [QBRTCICEServer serverWithURL:@"turn:turn.quickblox.com:3478?transport=tcp"
            username:userName
            password:password];
    
    
    return@[stunServer, turnTCPServer, turnUDPServer];
}

@end
