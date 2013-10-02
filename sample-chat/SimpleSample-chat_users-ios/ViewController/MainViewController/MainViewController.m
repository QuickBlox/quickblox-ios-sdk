//
//  MainViewController.m
//  SimpleSample-chat_users-ios
//
//  Created by Ruslan on 9/18/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "MainViewController.h"
#import "UserTableViewCell.h"
#import "LoginViewController.h"
#import "ChatViewController.h"
#import "RegistrationViewController.h"

@implementation MainViewController

@synthesize users;

@synthesize toolBar;
@synthesize tableView;
@synthesize searchBar;
@synthesize selectedUsers;
@synthesize senderUsers;

#pragma mark -
#pragma mark View controller's lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.users         = [[[NSMutableArray alloc] init] autorelease];
        self.selectedUsers = [[[NSMutableArray alloc] init] autorelease];
        self.senderUsers   = [[[NSMutableArray alloc] init] autorelease];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Show Login  & Register button
    UIBarButtonItem *loginItem = [[UIBarButtonItem alloc] initWithTitle:@"Login"
                                                              style:UIBarButtonItemStyleBordered
                                                             target:self
                                                             action:@selector(login)];
    UIBarButtonItem *registerItem = [[UIBarButtonItem alloc] initWithTitle:@"Register"
                                                              style:UIBarButtonItemStyleBordered
                                                             target:self
                                                             action:@selector(registration)];
    [loginItem setWidth: 150];
    [registerItem setWidth: 150];
    NSArray *items = [NSArray arrayWithObjects: loginItem, registerItem, nil];
    [self.toolBar setItems:items animated:NO];
    [loginItem release];
    [registerItem release];

}

- (void)viewDidUnload{
    [self setToolBar:nil];
    [self setTableView:nil];
    [self setSearchBar:nil];
    
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [toolBar release];
    [tableView release];
    [searchBar release];
    [users release];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;
    [self.tableView reloadData];
    
    // Show 'Start Chat' button if users have been logged
    if([[DataManager shared] currentUser]){
        UIBarButtonItem *startChat = [[UIBarButtonItem alloc] initWithTitle:@"Start chat"
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:self
                                                                     action:@selector(startChat)];
        [startChat setWidth: 306];
        NSArray *items = [NSArray arrayWithObjects: startChat, nil];
        [self.toolBar setItems:items animated:NO];
        [startChat release];
    }
    
    // Set Chat delegate
    [QBChat instance].delegate = self;
    
    // send presence every 10 seconds & check for new rooms
    if([DataManager shared].currentUser){
        
        // send presence
        [NSTimer scheduledTimerWithTimeInterval:10 target:[QBChat instance] selector:@selector(sendPresence)
                                                                userInfo:nil 
                                                                 repeats:YES];
        
        // retrieve rooms
        [self updateRooms];
    }
}


#pragma mark -
#pragma mark Methods

- (void)updateUsers{
    // Retrieve all users
    PagedRequest* request = [PagedRequest request];
    request.perPage = 100; // 100 users
	[QBUsers usersWithPagedRequest:request delegate:self];
}

// send presence
- (void)sendPresence{
    // presence in QuickBlox Chat
    [[QBChat instance] sendPresence];
    // presence in QuickBlox
    [QBUsers userWithExternalID:1 delegate:nil]; 
}

// update rooms
- (void)updateRooms {
	[QBCustomObjects objectsWithClassName:@"ChatRoom" delegate:self];
}

- (void) login{
    // Show Login controller
    LoginViewController *loginViewController = [[LoginViewController alloc] init];
    [self.navigationController pushViewController:loginViewController animated:YES];
    [loginViewController release];
}

- (void)registration{
    // Show Registration controller
    RegistrationViewController *registrationViewController = [[RegistrationViewController alloc] init];
    [self.navigationController pushViewController:registrationViewController animated:YES];
    [registrationViewController release];
}

// Start Chat
- (void)startChat{
    
    // nobody selected
    if(![self.selectedUsers count]){
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" 
														message:@"You must choose at least one user for chat" 
													   delegate:nil 
											  cancelButtonTitle:@"Okay" 
											  otherButtonTitles:nil, nil];
		[alert show];
		[alert release];
        
    // Selected 1 user - Start chat 1-1
    }else if([self.selectedUsers count] == 1){
        
        // Show Chat view controller
        ChatViewController *chatViewController = [[ChatViewController alloc] init];
        QBUUser *opponent = [self.selectedUsers objectAtIndex:0];
        [self.selectedUsers removeAllObjects];
        [self.senderUsers removeAllObjects];
        [chatViewController setTitle:opponent.login ? opponent.login : opponent.fullName];
        [chatViewController setOpponent:opponent];
        [self.navigationController pushViewController:chatViewController animated:YES];
        [chatViewController release];
        
    // Selected some users - Start chat in room
    }else {
    
        // Show alert for enter room's topic
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Topic"
                                                        message:@"\n"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Start", nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alert setTag:2];
        [alert show];
        [alert release];
    }
}


#pragma mark -
#pragma mark TableViewDataSource & TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.searchBar resignFirstResponder];
    
    // Select room
    if([[[DataManager shared] rooms] count] > 0 && indexPath.section == 0){
        
        QBCOCustomObject *selectedRoom = [[[DataManager shared] rooms] objectAtIndex:indexPath.row];
        
        [[QBChat instance] createOrJoinRoomWithName:selectedRoom.fields[@"name"] membersOnly:NO persistent:NO];

    // Mark/unmark users
    }else {
        QBUUser *selectedUser = [self.users objectAtIndex:indexPath.row];
        
        if([self.senderUsers containsObject:selectedUser]){
            [self.senderUsers removeObject:selectedUser];
            [self.tableView reloadData];
            ChatViewController *chatViewController = [[ChatViewController alloc] init];
            [self.selectedUsers removeAllObjects];
            [self.senderUsers removeAllObjects];
            [chatViewController setTitle:selectedUser.login ? selectedUser.login : selectedUser.fullName];
            [chatViewController setOpponent:selectedUser];
            [self.navigationController pushViewController:chatViewController animated:YES];
            [chatViewController release];
            
        // Mark
        }else if(![self.selectedUsers containsObject:selectedUser]){
            [self.selectedUsers addObject:selectedUser];
            [self.tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
            
        // Unmark
        }else{
            [self.selectedUsers removeObject:selectedUser];
            [self.tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if([[[DataManager shared] rooms] count]){
        return 2;
    }else{
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if([[[DataManager shared] rooms] count] && section == 0){
        return [[[DataManager shared] rooms] count];
    }else{
        return [self.users count];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if([[[DataManager shared] rooms] count] && section == 0){
        return @"Rooms";
    }else{
        return @"Users";
    }
}

- (UITableViewCell*)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* SimpleTableIdentifier = @"SimpleTableIdentifier";
    
    // Create cell
    UserTableViewCell* cell = [_tableView dequeueReusableCellWithIdentifier:SimpleTableIdentifier];
    if (cell == nil){
        cell = [[[UserTableViewCell alloc] init] autorelease];
    }

    // Room's cell
    if([[[DataManager shared] rooms] count] && indexPath.section == 0){
        
        // set room's name & icon
        QBCOCustomObject *room = [[[DataManager shared] rooms] objectAtIndex:indexPath.row];
        [cell.text setText:room.fields[@"name"]];
        [cell.icon setImage:[UIImage imageNamed:@"room-icon.png"]];
        
    // User's cell
    }else{

        // set user's name & icon
        QBUUser *user = [self.users objectAtIndex:indexPath.row];
        [cell.text setText:user.login ? user.login : user.fullName];
        [cell.icon setImage:[UIImage imageNamed:@"pin.png"]];
        
        NSInteger currentDate = [[NSDate date] timeIntervalSince1970];
        NSInteger userDate    = [[user lastRequestAt] timeIntervalSince1970];
        
        if((currentDate - userDate) > 300){ // if user didn't do anything last 5 minutes - he is offline
            [cell.status setImage:[UIImage imageNamed:@"offLine.png" ]];
        }else {
            [cell.status setImage:[UIImage imageNamed:@"onLine.png" ]];
        }
        
        // mark/unmark
        if([self.selectedUsers containsObject:user]){
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.section == (self.tableView.numberOfSections - 1) && [self.users count]){
        QBUUser *user = [self.users objectAtIndex:indexPath.row];
    
        UIColor *color = [UIColor colorWithRed:176.0/255.0 green:226.0/255.0 blue:255.0/255.0 alpha:1];
    
        if([self.senderUsers containsObject:user]){
            [cell setBackgroundColor:color];
            [(UserTableViewCell *)cell setBackgroundColor:color];
        }else {
            [cell setBackgroundColor:[UIColor clearColor]];
            [(UserTableViewCell *)cell setBackgroundColor:[UIColor clearColor]];
        }
    }
}

#pragma mark -
#pragma mark UISearchBarDelegate

-(void) searchBarSearchButtonClicked:(UISearchBar *)SearchBar{
    [self.searchBar resignFirstResponder];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self.users removeAllObjects];
    
    // clear
    if([searchText length] == 0){
        [self.users addObjectsFromArray:[[DataManager shared] users]];
        [self.searchBar resignFirstResponder];
        
    // search users
    }else{
        for(QBUUser *user in [[DataManager shared] users]){
            
            NSRange note;
            if(user.login){
                note = [user.login rangeOfString:searchText options:NSCaseInsensitiveSearch];
            }else {
                note = [user.fullName rangeOfString:searchText options:NSCaseInsensitiveSearch];
            }
            
            if(note.location != NSNotFound){
                [self.users addObject:user];
            }
        }
    }
   
    [self.tableView reloadData];
}


#pragma mark -
#pragma mark UIAlertView delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    // Room's topic alert
    if(alertView.tag == 2 && buttonIndex == 1){
        
        NSString *roomName = [alertView textFieldAtIndex:0].text;
        
        // check name
        if(roomName.length > 0){
            
            // Create room
            QBCOCustomObject *roomObj = [QBCOCustomObject customObject];
            roomObj.className = @"ChatRoom";
            [roomObj.fields setObject:roomName forKey:@"name"];
            [QBCustomObjects createObject:roomObj delegate:self];

            //
            [[QBChat instance] createOrJoinRoomWithName:roomName membersOnly:NO persistent:NO];
        }
    }
}


#pragma mark -
#pragma mark QBActionStatusDelegate

// QuickBlox API queries delegate
- (void)completedWithResult:(Result *)result{
    
    // Get all users result
	if([result isKindOfClass:[QBUUserPagedResult class]]){
        
        // Success result
        if (result.success){
            QBUUserPagedResult *res = (QBUUserPagedResult *)result;
            
            // Save users
            [DataManager shared].users = res.users;
            [self.users addObjectsFromArray:[[DataManager shared] users]];
            
            // reload table
            [self.tableView reloadData];
        }
        
    // get rooms
	}else if([result isKindOfClass:QBCOCustomObjectPagedResult.class]){
        QBCOCustomObjectPagedResult *res = (QBCOCustomObjectPagedResult *)result;

        // save rooms
        [DataManager shared].rooms = [[res.objects mutableCopy] autorelease];
        
        // reload table
        [self.tableView reloadData];
    
    // create room
    } else if([result isKindOfClass:QBCOCustomObjectResult.class]){
        QBCOCustomObjectResult *res = (QBCOCustomObjectResult *)result;
        [[DataManager shared].rooms addObject:res.object];
    }
}


#pragma mark -
#pragma mark QBChat delegate

// Did receive 1-1 message
- (void)chatDidReceiveMessage:(QBChatMessage *)message{
    
    for(QBUUser *user in [[DataManager shared] users]){
        if(message.senderID == user.ID && ![self.senderUsers containsObject:user]){
            [self.senderUsers addObject:user];
            [self.tableView reloadData];
            NSMutableArray *messages = [[NSMutableArray alloc] init];
            if([[DataManager shared] chatHistoryWithOpponentID:message.senderID]){
                [messages addObjectsFromArray:[[[DataManager shared] chatHistoryWithOpponentID:message.senderID] retain]];
            }
            
            [messages addObject:message];
            [[DataManager shared] saveMessage:[NSKeyedArchiver archivedDataWithRootObject:messages]
                      toHistoryWithOpponentID:message.senderID];
            [messages release];
        }
    }
    
}

// Fired when you did enter to room
- (void)chatRoomDidEnter:(QBChatRoom *)room{
    NSLog(@"Main Controller chatRoomDidEnter");
    
    // add users if are creating room
    if([self.selectedUsers count] > 0){
        // add selected users to room
        NSMutableArray *userIDs = [[NSMutableArray alloc] init];
        for(QBUUser *user in self.selectedUsers){
            [userIDs addObject:[NSNumber numberWithInt:user.ID]];
        }
        [room addUsers:userIDs];
        
        [userIDs release];
        
        [self.senderUsers removeAllObjects];
        [self.selectedUsers removeAllObjects];
    }
    
    // show chat view controller
    ChatViewController *chatViewController = [[[ChatViewController alloc] init] autorelease];
    [chatViewController setTitle:room.name];
    [chatViewController setCurrentRoom:room];
    [self.selectedUsers removeAllObjects];
    [self.navigationController pushViewController:chatViewController animated:YES];
}

// Fired when you did not enter to room
- (void)chatRoomDidNotEnter:(NSString *)roomName error:(NSError *)error{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@, error:", roomName]
                                                    message:[error domain]
                                                   delegate:nil
                                          cancelButtonTitle:@"Okay"
                                          otherButtonTitles:nil, nil];
    [alert show];
    [alert release];
}

// Fired when you did leave room
- (void)chatRoomDidLeave:(NSString *)roomName{
    NSLog(@"Main Controller chatRoomDidLeave");
}

@end
