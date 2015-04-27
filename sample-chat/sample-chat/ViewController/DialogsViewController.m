//
//  SecondViewController.m
//  sample-chat
//
//  Created by Igor Khomenko on 10/16/13.
//  Copyright (c) 2013 Igor Khomenko. All rights reserved.
//

#import "DialogsViewController.h"
#import "СhatViewController.h"
#import "ChatMessageTableViewCell.h"

@interface DialogsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITableView *dialogsTableView;

@end

@implementation DialogsViewController

#pragma mark
#pragma mark ViewController lyfe cycle

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if([LocalStorageService shared].currentUser != nil){
        [SVProgressHUD showWithStatus:@"Loading"];
        
        // get dialogs
        
        __weak __typeof(self)weakSelf = self;
        [QBRequest dialogsWithSuccessBlock:^(QBResponse *response, NSArray *dialogObjects, NSSet *dialogsUsersIDs) {

            [LocalStorageService shared].dialogs = dialogObjects.mutableCopy;
            
            QBGeneralResponsePage *pagedRequest = [QBGeneralResponsePage responsePageWithCurrentPage:0 perPage:100];

            [QBRequest usersWithIDs:[dialogsUsersIDs allObjects] page:pagedRequest
                       successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users) {
                
                [LocalStorageService shared].users = users;

                [weakSelf.dialogsTableView reloadData];
                [SVProgressHUD dismiss];
                
            } errorBlock:nil];

        } errorBlock:^(QBResponse *response) {
            
        }];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Show splash
        [self.navigationController performSegueWithIdentifier:kShowSplashViewControllerSegue sender:nil];
    });
    
    if(self.createdDialog != nil){
        [self performSegueWithIdentifier:kShowNewChatViewControllerSegue sender:nil];
    }
}


#pragma mark
#pragma mark Actions

- (IBAction)createDialog:(id)sender{
    [self performSegueWithIdentifier:kShowUsersViewControllerSegue sender:nil];
}


#pragma mark
#pragma mark Storyboard

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.destinationViewController isKindOfClass:ChatViewController.class]){
        ChatViewController *destinationViewController = (ChatViewController *)segue.destinationViewController;
        
        if(self.createdDialog != nil){
            destinationViewController.dialog = self.createdDialog;
            self.createdDialog = nil;
        }else{
            QBChatDialog *dialog = [LocalStorageService shared].dialogs[((UITableViewCell *)sender).tag];
            destinationViewController.dialog = dialog;
        }
    }
}


#pragma mark
#pragma mark UITableViewDelegate & UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [[LocalStorageService shared].dialogs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatRoomCellIdentifier"];
    
    QBChatDialog *chatDialog = [LocalStorageService shared].dialogs[indexPath.row];
    cell.tag  = indexPath.row;
    
    switch (chatDialog.type) {
        case QBChatDialogTypePrivate:{
            cell.detailTextLabel.text = chatDialog.lastMessageText;
            QBUUser *recipient = [LocalStorageService shared].usersAsDictionary[@(chatDialog.recipientID)];
            cell.textLabel.text = recipient.login == nil ? recipient.email : recipient.login;
        }
            break;
        case QBChatDialogTypeGroup:{
            cell.detailTextLabel.text = chatDialog.lastMessageText;
            cell.textLabel.text = chatDialog.name;
            cell.imageView.image = [UIImage imageNamed:@"GroupChatIcon"];
        }
            break;
        case QBChatDialogTypePublicGroup:{
            cell.detailTextLabel.text = chatDialog.lastMessageText;
            cell.textLabel.text = chatDialog.name;
            cell.imageView.image = [UIImage imageNamed:@"GroupChatIcon"];
        }
            break;
            
        default:
            break;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    QBChatDialog *chatDialog = [LocalStorageService shared].dialogs[indexPath.row];
    if(chatDialog.unreadMessagesCount > 0){
        [cell setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:255 alpha:0.1]];
    }else{
        [cell setBackgroundColor:[UIColor clearColor]];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
