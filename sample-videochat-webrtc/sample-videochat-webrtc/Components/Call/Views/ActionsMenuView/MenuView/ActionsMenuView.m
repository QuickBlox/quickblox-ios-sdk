//
//  ActionsMenuView.m
//  sample-videochat-webrtc
//
//  Created by Injoit on 15.08.2021.
//  Copyright © 2021 QuickBlox Team. All rights reserved.
//

#import "ActionsMenuView.h"
#import "MenuActionCell.h"
#import "UIView+Videochat.h"

@interface ActionsMenuView () <UITableViewDataSource>
//MARK: - IBOutlets
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

//MARK: - Properties
@property (nonatomic, strong) NSMutableArray<MenuAction *> *actions;
@end

@implementation ActionsMenuView
//MARK: - Life Cycle
- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self setupViews];
}

//MARK: - Actions
- (IBAction)tapCancelButton:(UIButton *)sender {
    [self removeFromSuperview];
}

//MARK - Setup
- (void)setupViews {
    UINib *nibMenuCell = [UINib nibWithNibName:kMenuActionCellIdentifier bundle:nil];
    [self.tableView registerNib:nibMenuCell forCellReuseIdentifier:kMenuActionCellIdentifier];
    self.tableView.userInteractionEnabled = YES;
    
    CGFloat heightConstant = self.tableView.contentSize.height;
    self.containerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.containerView.topAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.topAnchor constant: 32.0f].active = YES;
    [self.containerView.rightAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.rightAnchor constant: -22.0f].active = YES;
    [self.containerView.widthAnchor constraintEqualToConstant: 200.0f].active = YES;
    [self.containerView.heightAnchor constraintEqualToConstant: heightConstant].active = YES;
    [self.containerView addShadow:[UIColor colorWithRed:0.78f green:0.81f blue:0.85f alpha:1.0f]];
    [self.containerView setRoundViewWithCornerRadius:14.0f];
    
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.tableView.topAnchor constraintEqualToAnchor:self.containerView.topAnchor constant: 3.0f].active = YES;
    [self.tableView.leftAnchor constraintEqualToAnchor:self.containerView.leftAnchor].active = YES;
    [self.tableView.bottomAnchor constraintEqualToAnchor:self.containerView.bottomAnchor constant: -3.0f].active = YES;
    [self.tableView.rightAnchor constraintEqualToAnchor:self.containerView.rightAnchor].active = YES;
    
    [self.tableView reloadData];
}

//MARK: - Public Methods
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
    MenuActionCell *cell = [tableView dequeueReusableCellWithIdentifier:kMenuActionCellIdentifier];
    MenuAction *menuAction = self.actions[indexPath.row];
    cell.actionLabel.text = menuAction.title;
    cell.accessoryType = menuAction.isSelected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MenuAction *menuAction = self.actions[indexPath.row];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self removeFromSuperview] ;
        if (menuAction.handler) {
            menuAction.handler(menuAction.action);
        }
    });
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

@end
