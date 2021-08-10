//
//  BaseUsersViewController.h
//  sample-conference-videochat
//
//  Created by Injoit on 08.02.2021.
//  Copyright © 2021 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatManager.h"
#import "QBUUser+Chat.h"
#import "TitleView.h"
#import "UserTableViewCell.h"
#import "SVProgressHUD.h"

NS_ASSUME_NONNULL_BEGIN

@interface BaseUsersViewController : UIViewController
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UIButton *cancelSearchButton;
@property (nonatomic, strong) QBUUser *currentUser;
@property (nonatomic, strong) TitleView *titleView;
@property (nonatomic, strong) NSMutableArray<QBUUser *> *users;
@property (nonatomic, strong) NSMutableArray<QBUUser *> *downloadedUsers;
@property (nonatomic, strong) NSMutableSet<QBUUser *> *selectedUsers;
@property (nonatomic, strong) NSMutableArray<QBUUser *> *foundedUsers;
@property (nonatomic, strong) ChatManager *chatManager;
@property (nonatomic, assign) Boolean cancel;
@property (nonatomic, assign) Boolean cancelFetch;
@property (nonatomic, assign) Boolean isSearch;
@property (nonatomic, assign) Boolean useSearchBar;
@property (nonatomic, assign) NSUInteger currentFetchPage;
@property (nonatomic, assign) NSUInteger currentSearchPage;
@property (nonatomic, strong) NSString *navBarTitle;

- (void)setupViewWillAppear;
- (void)tableView:(UITableView *)tableView configureCell:(UserTableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath;
- (void)checkCreateChatButtonState;
- (void)searchUsers:(NSString *)text;
- (void)fetchUsers;
- (void)setupNavigationTitle;
- (void)setupUsers:(NSArray <QBUUser *> *)users;
- (void)addFoundUsers:(NSArray<QBUUser *> *)users;
- (void)updateWithConnect;
@end

NS_ASSUME_NONNULL_END
