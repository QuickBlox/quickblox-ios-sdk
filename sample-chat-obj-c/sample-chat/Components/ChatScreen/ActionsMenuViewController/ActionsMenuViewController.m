//
//  ChatPopVC.m
//  samplechat
//
//  Created by Injoit on 2/6/20.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import "ActionsMenuViewController.h"
#import "UITableView+Chat.h"
#import "ChatActionCell.h"

typedef void(^SelectedActionHandler)(void);

@interface ActionsMenuViewController ()
@property (nonatomic, strong) NSMutableArray<MenuAction *> *chatActions;
@end

@implementation ActionsMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView addShadowToTableViewWithShadowColor:[UIColor colorWithRed:0.78f green:0.81f blue:0.85f alpha:1.0f]];
    self.tableView.userInteractionEnabled = YES;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.preferredContentSize = CGSizeMake(148.0f , self.tableView.contentSize.height);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.cancelAction) {
        self.cancelAction();
    }
}

- (void)addAction:(MenuAction *)action {
    if (!self.chatActions) {
        self.chatActions = [NSMutableArray array];
    }
    [self.chatActions insertObject:action atIndex:0];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.chatActions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChatActionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatActionCell"];
    MenuAction *action = self.chatActions[indexPath.row];
    cell.actionLabel.text = action.title;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MenuAction *action = self.chatActions[indexPath.row];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:NO completion:^{
            if (action.handler) {
                action.handler();
            }
            if (self.cancelAction) {
                self.cancelAction();
            }
        }];
    });
}

@end
