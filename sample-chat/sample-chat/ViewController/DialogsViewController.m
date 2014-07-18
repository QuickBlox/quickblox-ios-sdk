//
//  SecondViewController.m
//  sample-chat
//
//  Created by Igor Khomenko on 10/16/13.
//  Copyright (c) 2013 Igor Khomenko. All rights reserved.
//

#import "DialogsViewController.h"
#import "СhatViewController.h"

@interface DialogsViewController () <UITableViewDelegate, UITableViewDataSource, QBActionStatusDelegate>

@property (nonatomic, strong) NSMutableArray *dialogs;
@property (nonatomic, weak) IBOutlet UITableView *dialogsTableView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation DialogsViewController

#pragma mark
#pragma mark ViewController lyfe cycle

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if([LocalStorageService shared].currentUser != nil){
        [self.activityIndicator startAnimating];
        
        // get dialogs
        [QBChat dialogsWithExtendedRequest:nil delegate:self];
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
            QBChatDialog *dialog = self.dialogs[((UITableViewCell *)sender).tag];
            destinationViewController.dialog = dialog;
        }
    }
}


#pragma mark
#pragma mark UITableViewDelegate & UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.dialogs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatRoomCellIdentifier"];
    
    QBChatDialog *chatDialog = self.dialogs[indexPath.row];
    cell.tag  = indexPath.row;
    
    switch (chatDialog.type) {
        case QBChatDialogTypePrivate:{
            cell.detailTextLabel.text = @"private";
            QBUUser *recipient = [LocalStorageService shared].usersAsDictionary[@(chatDialog.recipientID)];
            cell.textLabel.text = recipient.login == nil ? recipient.email : recipient.login;
        }
            break;
        case QBChatDialogTypeGroup:{
            cell.detailTextLabel.text = @"group";
            cell.textLabel.text = chatDialog.name;
        }
            break;
        case QBChatDialogTypePublicGroup:{
            cell.detailTextLabel.text = @"public group";
            cell.textLabel.text = chatDialog.name;
        }
            break;
            
        default:
            break;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark -
#pragma mark QBActionStatusDelegate

// QuickBlox API queries delegate
- (void)completedWithResult:(Result *)result{
    if (result.success && [result isKindOfClass:[QBDialogsPagedResult class]]) {
        QBDialogsPagedResult *pagedResult = (QBDialogsPagedResult *)result;
        //
        NSArray *dialogs = pagedResult.dialogs;
        self.dialogs = [dialogs mutableCopy];
        
        // Get dialogs users
        PagedRequest *pagedRequest = [PagedRequest request];
        pagedRequest.perPage = 100;
        //
        NSSet *dialogsUsersIDs = pagedResult.dialogsUsersIDs;
        //
        [QBUsers usersWithIDs:[[dialogsUsersIDs allObjects] componentsJoinedByString:@","] pagedRequest:pagedRequest delegate:self];

    }else if (result.success && [result isKindOfClass:[QBUUserPagedResult class]]) {
        QBUUserPagedResult *res = (QBUUserPagedResult *)result;
        [LocalStorageService shared].users = res.users;
        //
        [self.dialogsTableView reloadData];
        [self.activityIndicator stopAnimating];
    }
}

@end
