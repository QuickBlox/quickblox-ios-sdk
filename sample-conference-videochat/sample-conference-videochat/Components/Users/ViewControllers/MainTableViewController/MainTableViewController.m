//
//  MainTableViewController.m
//  sample-multiconference-videochat
//
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import "MainTableViewController.h"
#import <Quickblox/Quickblox.h>
#import "QBCore.h"
#import "SessionSettingsViewController.h"
#import "SVProgressHUD.h"
#import "DialogsDataSource.h"
#import "UsersDataSource.h"
#import "QBDataFetcher.h"
#import "UsersViewController.h"
#import "CallViewController.h"
#import "QBAVCallPermissions.h"

typedef NS_ENUM(NSUInteger, CallSenderValue) {
    CallSenderValueDialogInstance,
    CallSenderValueConferenceType
};

static NSString * const kSettingsSegue = @"PresentSettingsViewController";
static NSString * const kUsersSegue = @"PresentUsersViewController";
static NSString * const kCallSegue = @"PresentCallViewController";
static NSString * const kSceneSegueAuth = @"SceneSegueAuth";

@interface MainTableViewController () <SettingsViewControllerDelegate, QBCoreDelegate, UsersViewControllerDelegate, DialogsDataSourceDelegate>

@property (strong, nonatomic) DialogsDataSource *dialogsDataSource;
@property (strong, nonatomic) UsersDataSource *usersDataSource;

@end

@implementation MainTableViewController

// MARK: Lifecycle

- (void)dealloc {
    
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [Core addDelegate:self];
    
    // Reachability
    __weak __typeof(self)weakSelf = self;
    Core.networkStatusBlock = ^(QBNetworkStatus status) {
        if (status != QBNetworkStatusNotReachable) {
            [weakSelf fetchData];
        }
    };
    
    [self configureNavigationBar];
    [self configureTableViewController];
    [self fetchData];
    
    // adding refresh control task
    if (self.refreshControl) {
        
        [self.refreshControl addTarget:self
                                action:@selector(fetchData)
                      forControlEvents:UIControlEventValueChanged];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.refreshControl.refreshing) {
        [self.tableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:NO];
    }
}

// MARK: UI Configuration

- (void)configureTableViewController {
    
    self.dialogsDataSource = [DialogsDataSource dialogsDataSource];
    self.dialogsDataSource.delegate = self;
    self.usersDataSource = [UsersDataSource usersDataSource];
    self.tableView.dataSource = self.dialogsDataSource;
    self.tableView.rowHeight = 76;
    [self.refreshControl beginRefreshing];
}

- (void)configureNavigationBar {
    
    UIBarButtonItem *settingsButtonItem =
    [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic-settings"]
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(didPressSettingsButton:)];
    
    self.navigationItem.leftBarButtonItem = settingsButtonItem;
    
    UIBarButtonItem *usersButtonItem =
    [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"new-message"]
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(didPressUsersButton:)];
    
    self.navigationItem.rightBarButtonItem = usersButtonItem;
    
    //Custom label
    NSString *roomName = [NSString stringWithFormat:@"%@", Core.currentUser.tags.firstObject];
    NSString *userName = [NSString stringWithFormat:@"Logged in as %@", Core.currentUser.fullName];
    NSString *titleString = [NSString stringWithFormat:@"%@\n%@", roomName, userName];
    
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:titleString];
    NSRange roomNameRange = [titleString rangeOfString:roomName];
    [attrString addAttribute:NSFontAttributeName
                       value:[UIFont boldSystemFontOfSize:16.0f]
                       range:roomNameRange];
    
    NSRange userNameRange = [titleString rangeOfString:userName];
    [attrString addAttribute:NSFontAttributeName
                       value:[UIFont systemFontOfSize:12.0f]
                       range:userNameRange];
    [attrString addAttribute:NSForegroundColorAttributeName
                       value:[UIColor grayColor]
                       range:userNameRange];
    
    UILabel *titleView = [[UILabel alloc] initWithFrame:CGRectZero];
    titleView.numberOfLines = 2;
    titleView.attributedText = attrString;
    titleView.textAlignment = NSTextAlignmentCenter;
    [titleView sizeToFit];
    
    self.navigationItem.titleView = titleView;
}

// MARK: Actions

- (BOOL)hasConnectivity {
    
    BOOL hasConnectivity = Core.networkStatus != QBNetworkStatusNotReachable;
    
    if (!hasConnectivity) {
        [self showAlertViewWithMessage:NSLocalizedString(@"Please check your Internet connection", nil)];
    }
    
    return hasConnectivity;
}

- (void)showAlertViewWithMessage:(NSString *)message {
    
    UIAlertController *alertController =
    [UIAlertController alertControllerWithTitle:nil
                                        message:message
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:nil]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)didPressSettingsButton:(UIBarButtonItem *)item {
    
    [self performSegueWithIdentifier:kSettingsSegue sender:item];
}

- (void)didPressUsersButton:(UIBarButtonItem *)item {
    
    [self performSegueWithIdentifier:kUsersSegue sender:item];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:kSettingsSegue]) {
        
        SessionSettingsViewController *settingsViewController =
        (id)((UINavigationController *)segue.destinationViewController).topViewController;
        settingsViewController.delegate = self;
    }
    else if ([segue.identifier isEqualToString:kUsersSegue]) {
        
        UsersViewController *usersViewController =
        (id)segue.destinationViewController;
        usersViewController.dataSource = self.usersDataSource;
        usersViewController.delegate = self;
    }
    else if ([segue.identifier isEqualToString:kCallSegue]) {
        
        CallViewController *callVC = (id)segue.destinationViewController;
        callVC.chatDialog = sender[CallSenderValueDialogInstance];
        callVC.conferenceType = [sender[CallSenderValueConferenceType] integerValue];
        callVC.usersDataSource = self.usersDataSource;
    }
}

// MARK: - DialogsDataSourceDelegate

- (void)dialogsDataSource:(DialogsDataSource *)dialogsDataSource dialogCellDidTapListener:(__kindof UITableViewCell *)dialogCell {
    
    [self joinDialogFromDialogCell:dialogCell conferenceType:0];
}

- (void)dialogsDataSource:(DialogsDataSource *)dialogsDataSource dialogCellDidTapAudio:(__kindof UITableViewCell *)dialogCell {
    
    [self joinDialogFromDialogCell:dialogCell conferenceType:QBRTCConferenceTypeAudio];
}

- (void)dialogsDataSource:(DialogsDataSource *)dialogsDataSource dialogCellDidTapVideo:(__kindof UITableViewCell *)dialogCell {
    
    [self joinDialogFromDialogCell:dialogCell conferenceType:QBRTCConferenceTypeVideo];
}

- (void)dialogsDataSource:(DialogsDataSource *)dialogsDataSource commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self hasConnectivity]
        && editingStyle == UITableViewCellEditingStyleDelete) {
        
        [SVProgressHUD show];
        QBChatDialog *chatDialog = self.dialogsDataSource.objects[indexPath.row];
        __weak __typeof(self)weakSelf = self;
        [QBRequest deleteDialogsWithIDs:[NSSet setWithObject:chatDialog.ID] forAllUsers:NO successBlock:^(QBResponse * _Nonnull response, NSArray<NSString *> * _Nullable deletedObjectsIDs, NSArray<NSString *> * _Nullable notFoundObjectsIDs, NSArray<NSString *> * _Nullable wrongPermissionsObjectsIDs) {
            
            __typeof(weakSelf)strongSelf = weakSelf;
            NSMutableArray *dialogs = [strongSelf.dialogsDataSource.objects mutableCopy];
            [dialogs removeObject:chatDialog];
            strongSelf.dialogsDataSource.objects = [dialogs copy];
            [self.tableView reloadData];
            [SVProgressHUD dismiss];
            
        } errorBlock:^(QBResponse * _Nonnull response) {
            
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@", response.error.reasons]];
        }];
    }
}

// MARK: UsersViewControllerDelegate

- (void)usersViewController:(UsersViewController *)usersViewController didCreateChatDialog:(QBChatDialog *)chatDialog {
    
    NSMutableArray *mutableObjecs = [self.dialogsDataSource.objects mutableCopy];
    [mutableObjecs addObject:chatDialog];
    [self.dialogsDataSource setObjects:[mutableObjecs copy]];
    [self.tableView reloadData];
}

// MARK: QBCoreDelegate

- (void)coreDidLogout:(QBCore *)core {
    
    [SVProgressHUD dismiss];
    //Dismiss Settings view controller
    [self dismissViewControllerAnimated:NO completion:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSegueWithIdentifier:kSceneSegueAuth sender:nil];
    });
}

- (void)core:(QBCore *)core error:(NSError *)error domain:(ErrorDomain)domain {
    
    if (domain == ErrorDomainLogOut) {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }
}

// MARK: SettingsViewControllerDelegate

- (void)settingsViewController:(SessionSettingsViewController *)vc didPressLogout:(id)sender {
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Logout...", nil)];
    [Core logout];
}

// MARK: Private

- (void)fetchData {
    
    __weak __typeof(self)weakSelf = self;
    dispatch_group_t dataGroup = dispatch_group_create();
    
    dispatch_group_enter(dataGroup);
    [QBDataFetcher fetchDialogs:^(NSArray *dialogs) {
        
        dispatch_group_leave(dataGroup);
        __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf.dialogsDataSource setObjects:dialogs];
        [strongSelf.tableView reloadData];
    }];
    
    dispatch_group_enter(dataGroup);
    [QBDataFetcher fetchUsers:^(NSArray *users) {
        
        dispatch_group_leave(dataGroup);
        __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf.usersDataSource setObjects:users];
    }];
    
    dispatch_group_notify(dataGroup, dispatch_get_main_queue(), ^{
        
        __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf.refreshControl endRefreshing];
    });
}

- (void)joinDialogFromDialogCell:(UITableViewCell *)cell conferenceType:(QBRTCConferenceType)conferenceType {
    if ([self hasConnectivity]) {
        
        if (conferenceType > 0) {
            [QBAVCallPermissions checkPermissionsWithConferenceType:conferenceType completion:^(BOOL granted) {
                
                if (granted) {
                    
                    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
                    QBChatDialog *chatDialog = self.dialogsDataSource.objects[indexPath.row];
                    [self performSegueWithIdentifier:kCallSegue sender:@[chatDialog, @(conferenceType)]];
                }
            }];
        }
        else {
            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
            QBChatDialog *chatDialog = self.dialogsDataSource.objects[indexPath.row];
            [self performSegueWithIdentifier:kCallSegue sender:@[chatDialog, @(conferenceType)]];
        }
    }
}

@end
