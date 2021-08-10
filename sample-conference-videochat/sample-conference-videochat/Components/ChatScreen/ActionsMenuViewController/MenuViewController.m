//
//  MenuViewController.m
//  sample-conference-videochat
//
//  Created by Injoit on 2/6/20.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import "MenuViewController.h"
#import "UITableView+Chat.h"
#import "MenuActionCell.h"
#import "UIView+Chat.h"

typedef void(^SelectedActionHandler)(void);

@interface MenuViewController () <UITabBarDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (nonatomic, strong) NSMutableArray<MenuAction *> *actions;
@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView addShadowToTableViewWithShadowColor:[UIColor colorWithRed:0.78f green:0.81f blue:0.85f alpha:1.0f]];
    self.tableView.userInteractionEnabled = YES;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    [self setupViews];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.cancelAction) {
        self.cancelAction();
    }
}

- (void)setupViews {
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    switch (self.menuType) {
        case TypeMenuMediaInfo:
        case TypeMenuChatInfo:
            [self.tableView.rightAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.rightAnchor constant: -22.0f].active = YES;
            [self.tableView.widthAnchor constraintEqualToConstant: 154.0f].active = YES;
            [self.tableView.heightAnchor constraintEqualToConstant: self.tableView.contentSize.height].active = YES;
            break;
            
        case TypeMenuAppMenu:
            [self.tableView.leftAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leftAnchor constant: 22.0f].active = YES;
            [self.tableView.widthAnchor constraintEqualToConstant: 177.0f].active = YES;
            [self.tableView.heightAnchor constraintEqualToConstant: 280.0f].active = YES;
            break;

        default:
            break;
    }
    
    [self.tableView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant: 32.0f].active = YES;
    [self.tableView setRoundViewWithCornerRadius:6.0f];
    self.tableView.userInteractionEnabled = YES;
    [self.tableView reloadData];
}

- (IBAction)didTapcancelButton:(UIButton *)sender {
    [self dismissViewControllerAnimated:NO completion:^{
        if (self.cancelAction) {
            self.cancelAction();
        }
    }];
}

- (void)addAction:(MenuAction *)action {
    if (!self.actions) {
        self.actions = [NSMutableArray array];
    }
    [self.actions insertObject:action atIndex:0];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.actions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MenuActionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MenuActionCell"];
    MenuAction *menuAction = self.actions[indexPath.row];
    cell.actionLabel.text = menuAction.title;

    if (self.menuType == TypeMenuAppMenu) {
        if (menuAction.action == ChatActionUserProfile) {
            cell.actionLabel.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightMedium];
        }
        if (indexPath.row == 1 || indexPath.row == self.actions.count - 1) {
            cell.separatorView.hidden = NO;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MenuAction *action = self.actions[indexPath.row];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:NO completion:^{
            if (action.handler) {
                action.handler(action.action);
            }
            if (self.cancelAction) {
                self.cancelAction();
            }
        }];
    });
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    MenuAction *menuAction = self.actions[indexPath.row];
    if (self.menuType == TypeMenuAppMenu) {
        if (menuAction.action == ChatActionLogout || menuAction.action == ChatActionUserProfile) {
            return 74.0f;
        }
    }
    return 44.0f;
}

@end
