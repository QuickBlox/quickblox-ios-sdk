//
//  SecondViewController.m
//  sample-chat
//
//  Created by Igor Khomenko on 10/16/13.
//  Copyright (c) 2013 Igor Khomenko. All rights reserved.
//

#import "ChatRoomsViewController.h"
#import "СhatViewController.h"

@interface ChatRoomsViewController () <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>

@property (nonatomic, strong) NSMutableArray *chatRooms;
@property (nonatomic, weak) IBOutlet UITableView *chatRoomsTableView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation ChatRoomsViewController


#pragma mark
#pragma mark ViewController lyfe cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self.activityIndicator startAnimating];
    
    // Retieve Chat rooms
    [[ChatService instance] requestRoomsWithCompletionBlock:^(NSArray *rooms) {
        self.chatRooms = [rooms mutableCopy];
        
        [self.chatRoomsTableView reloadData];
        
        [self.activityIndicator stopAnimating];
    }];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.chatRoomsTableView reloadData];
}


#pragma mark
#pragma mark Actions

- (IBAction)createRoom:(id)sender{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enter a new room name" message:nil
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.delegate = self;
    [alert show];
}


#pragma mark
#pragma mark Storyboard

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    ChatViewController *destinationViewController = (ChatViewController *)segue.destinationViewController;
    
    QBChatRoom *chatRoom;
    if([sender isKindOfClass:[UITableViewCell class]]){
        chatRoom = (QBChatRoom *)self.chatRooms[((UITableViewCell *)sender).tag];
    }else{
        chatRoom = sender;
    }
    destinationViewController.chatRoom = chatRoom;
}


#pragma mark
#pragma mark UITableViewDelegate & UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.chatRooms count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatRoomCellIdentifier"];
    
    QBChatRoom *chatRoom = (QBChatRoom *)self.chatRooms[indexPath.row];
    cell.tag  = indexPath.row;
    cell.textLabel.text = chatRoom.name.length == 0 ? chatRoom.JID : chatRoom.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1){
        
        // Create a new Chat room
        NSString *roomName = [alertView textFieldAtIndex:0].text;
        [[ChatService instance] createOrJoinRoomWithName:roomName completionBlock:^(QBChatRoom *joinedChatRoom) {
            
            [self.chatRooms insertObject:joinedChatRoom atIndex:0];
            
            [self performSegueWithIdentifier:@"ChatViewControllerSeque" sender:joinedChatRoom];
        }];
    }
}

@end
