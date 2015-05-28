//
//  СhatViewController.m
//  sample-chat
//
//  Created by Igor Khomenko on 10/18/13.
//  Copyright (c) 2013 Igor Khomenko. All rights reserved.
//

#import "СhatViewController.h"
#import "ChatMessageTableViewCell.h"

@interface ChatViewController () <UITableViewDelegate, UITableViewDataSource, ChatServiceDelegate>

@property (nonatomic, weak) IBOutlet UITextField *messageTextField;
@property (nonatomic, weak) IBOutlet UIButton *sendMessageButton;
@property (nonatomic, weak) IBOutlet UITableView *messagesTableView;
@property (nonatomic, strong) NSMutableArray* messages;

- (IBAction)sendMessage:(id)sender;

@end

@implementation ChatViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.messagesTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Set keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    [ChatService shared].delegate = self;
    
    // Set title
    if(self.dialog.type == QBChatDialogTypePrivate){
        QBUUser *recipient = [ChatService shared].usersAsDictionary[@(self.dialog.recipientID)];
        self.title = recipient.login == nil ? recipient.email : recipient.login;
    }else{
        self.title = self.dialog.name;
    }

    // Join room
    //
    if(self.dialog.type != QBChatDialogTypePrivate){
        [self.dialog join];
    }
    
    // get messages history
    [QBRequest messagesWithDialogID:self.dialog.ID extendedRequest:nil forPage:[QBResponsePage responsePageWithLimit:1000 skip:0] successBlock:^(QBResponse *response, NSArray *messages, QBResponsePage *page) {
        [self.messages addObjectsFromArray:[messages mutableCopy]];
        //
        [self.messagesTableView reloadData];
        [self.messagesTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messages.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    } errorBlock:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [ChatService shared].delegate = nil;
    
    [self.dialog leave];
}

-(BOOL)hidesBottomBarWhenPushed
{
    return YES;
}

- (void)joinDialog{
    if(![[self.dialog chatRoom] isJoined]){
        [SVProgressHUD showWithStatus:@"Joining..."];
        
        [self.dialog setOnJoin:^{
            [SVProgressHUD dismiss];
        }];
        [self.dialog join];
    }
}

- (void)leaveDialog{
    [[self.dialog chatRoom] leaveRoom];
}

- (void)syncMessages{
    NSArray *messages = [[ChatService shared] messagsForDialogId:self.dialog.ID];
    NSDate *lastMessageDateSent = nil;
    if(messages.count > 0){
        QBChatMessage *lastMsg = [messages lastObject];
        lastMessageDateSent = lastMsg.dateSent;
    }
    
    __weak __typeof(self)weakSelf = self;
    
    [QBRequest messagesWithDialogID:self.dialog.ID
                    extendedRequest:lastMessageDateSent == nil ? nil : @{@"date_sent[gt]": @([lastMessageDateSent timeIntervalSince1970])}
                            forPage:nil
                       successBlock:^(QBResponse *response, NSArray *messages, QBResponsePage *page) {
        if(messages.count > 0){
            [[ChatService shared] addMessages:messages forDialogId:self.dialog.ID];
        }
                           
        [weakSelf.messagesTableView reloadData];
        NSInteger count = [[ChatService shared] messagsForDialogId:self.dialog.ID].count;
        if(count > 0){
           [weakSelf.messagesTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:count-1 inSection:0]
                                         atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }                      
    } errorBlock:^(QBResponse *response) {
        
    }];
}

#pragma mark
#pragma mark Actions

- (IBAction)sendMessage:(id)sender{
    if(self.messageTextField.text.length == 0){
        return;
    }
    
    // create a message
    QBChatMessage *message = [[QBChatMessage alloc] init];
    message.text = self.messageTextField.text;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"save_to_history"] = @YES;
    [message setCustomParameters:params];
    
    // 1-1 Chat
    if(self.dialog.type == QBChatDialogTypePrivate){
        // send message
//        message.recipientID = [self.dialog recipientID];
//        message.senderID = [LocalStorageService shared].currentUser.ID;
        [self.dialog sendMessage:message sentBlock:^(NSError *error) {
            if (error == nil) {
                NSLog(@"Sent!");
            } else {
                NSLog(@"Sending error: %@", [error description]);
            }
        }];
        
        // save message
        [[ChatService shared] addMessage:message forDialogId:self.dialog.ID];

    // Group Chat
    }else {
        [self.dialog sendMessage:message];
    }
    
    // Reload table
    [self.messagesTableView reloadData];
    if([[ChatService shared] messagsForDialogId:self.dialog.ID].count > 0){
        [self.messagesTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[[[ChatService shared] messagsForDialogId:self.dialog.ID] count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
    // Clean text field
    [self.messageTextField setText:nil];
}


#pragma mark
#pragma mark Chat Notifications

- (void)chatDidReceiveMessageNotification:(NSNotification *)notification{

    QBChatMessage *message = notification.userInfo[kMessage];
    if(message.senderID != self.dialog.recipientID){
        return;
    }
    
    // save message
    [self.messages addObject:message];
    
    // Reload table
    [self.messagesTableView reloadData];
    if(self.messages.count > 0){
        [self.messagesTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.messages count]-1 inSection:0]
                                      atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (void)chatRoomDidReceiveMessageNotification:(NSNotification *)notification{
    QBChatMessage *message = notification.userInfo[kMessage];
    NSString *roomJID = notification.userInfo[kRoomJID];
    
    if(![self.dialog.chatRoom.JID isEqualToString:roomJID]){
        return;
    }
    
    // save message
    [self.messages addObject:message];
    
    // Reload table
    [self.messagesTableView reloadData];
    if(self.messages.count > 0){
        [self.messagesTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.messages count]-1 inSection:0]
                                      atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}


#pragma mark
#pragma mark UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [[[ChatService shared] messagsForDialogId:self.dialog.ID] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ChatMessageCellIdentifier = @"ChatMessageCellIdentifier";
    
    ChatMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ChatMessageCellIdentifier];
    if (cell == nil) {
        cell = [[ChatMessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ChatMessageCellIdentifier];
    }
    
    QBChatMessage *message = self.messages[indexPath.row];
    //
    [cell configureCellWithMessage:message];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    QBChatMessage *chatMessage = [self.messages objectAtIndex:indexPath.row];
    CGFloat cellHeight = [ChatMessageTableViewCell heightForCellWithMessage:chatMessage];
    return cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}


#pragma mark
#pragma mark Keyboard notifications

- (void)keyboardWillShow:(NSNotification *)note
{
    [UIView animateWithDuration:0.3 animations:^{
		self.messageTextField.transform = CGAffineTransformMakeTranslation(0, -250);
        self.sendMessageButton.transform = CGAffineTransformMakeTranslation(0, -250);
        self.messagesTableView.frame = CGRectMake(self.messagesTableView.frame.origin.x,
                                                  self.messagesTableView.frame.origin.y,
                                                  self.messagesTableView.frame.size.width,
                                                  self.messagesTableView.frame.size.height-252);
    }];
}

- (void)keyboardWillHide:(NSNotification *)note
{
    [UIView animateWithDuration:0.3 animations:^{
		self.messageTextField.transform = CGAffineTransformIdentity;
        self.sendMessageButton.transform = CGAffineTransformIdentity;
        self.messagesTableView.frame = CGRectMake(self.messagesTableView.frame.origin.x,
                                                  self.messagesTableView.frame.origin.y,
                                                  self.messagesTableView.frame.size.width,
                                                  self.messagesTableView.frame.size.height+252);
    }];
}


#pragma mark
#pragma mark ChatServiceDelegate

- (void)chatDidLogin{
    [self joinDialog];
    
    // sync messages history
    //
    [self syncMessages];
}

- (BOOL)chatDidReceiveMessage:(QBChatMessage *)message{
    
    if(message.senderID != self.dialog.recipientID){
        return NO;
    }
    
    // save message
    [[ChatService shared] addMessage:message forDialogId:self.dialog.ID];
    
    // Reload table
    [self.messagesTableView reloadData];
    if([[ChatService shared] messagsForDialogId:self.dialog.ID].count > 0){
        [self.messagesTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[[[ChatService shared] messagsForDialogId:self.dialog.ID] count]-1 inSection:0]
                                      atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
    return YES;
}

- (BOOL)chatRoomDidReceiveMessage:(QBChatMessage *)message fromRoomJID:(NSString *)roomJID{
    if(![[self.dialog chatRoom].JID isEqualToString:roomJID]){
        return NO;
    }
    
    // save message
    [[ChatService shared] addMessage:message forDialogId:self.dialog.ID];
    
    // Reload table
    [self.messagesTableView reloadData];
    if([[ChatService shared] messagsForDialogId:self.dialog.ID].count > 0){
        [self.messagesTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[[[ChatService shared] messagsForDialogId:self.dialog.ID] count]-1 inSection:0]
                                      atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
    return YES;
}

@end
