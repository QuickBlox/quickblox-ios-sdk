//
//  СhatViewController.m
//  sample-chat
//
//  Created by Igor Khomenko on 10/18/13.
//  Copyright (c) 2013 Igor Khomenko. All rights reserved.
//

#import "СhatViewController.h"
#import "ChatMessageTableViewCell.h"
#import <STKStickerPipe.h>
#import "ChatStickerTableViewCell.h"

static NSString *ChatMessageCellIdentifier = @"ChatMessageCellIdentifier";
static NSString *ChatStickerCellIdentifier = @"ChatStickerCellIdentifier";

@interface ChatViewController () <UITableViewDelegate, UITableViewDataSource, ChatServiceDelegate, STKStickerPanelDelegate>

@property (nonatomic, weak) IBOutlet UITextField *messageTextField;
@property (nonatomic, weak) IBOutlet UIButton *sendMessageButton;
@property (nonatomic, weak) IBOutlet UITableView *messagesTableView;
@property (nonatomic, weak) IBOutlet UIView *inputBackgroundView;
@property (nonatomic, strong) STKStickerPanel *stickerView;
@property (nonatomic, strong) UIButton *showStickersButton;
@property (nonatomic, assign) BOOL isKeyboradShow;

@property (nonatomic, strong) UIRefreshControl *refreshControl;

- (IBAction)sendMessage:(id)sender;

@end

@implementation ChatViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.messagesTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // Initialize the refresh control.
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self
                            action:@selector(getPreviousMessages)
                  forControlEvents:UIControlEventValueChanged];
    
    [self.messagesTableView addSubview:self.refreshControl];
    
    
    //Initialize sticker button
    self.showStickersButton = [UIButton buttonWithType:UIButtonTypeSystem];
    UIImage *stickerImage = [[UIImage imageNamed:@"ShowStickersIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    [self.showStickersButton addTarget:self action:@selector(toggleStickerView) forControlEvents:UIControlEventTouchUpInside];
    
    [self.showStickersButton setImage:stickerImage forState:UIControlStateNormal];
    [self.showStickersButton setImage:stickerImage forState:UIControlStateHighlighted];
    
    self.showStickersButton.frame = CGRectMake(0, 0, 25.0, 25.0);
    self.messageTextField.rightView = self.showStickersButton;
    self.messageTextField.rightViewMode = UITextFieldViewModeUnlessEditing;
    
    //Gesture
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(messageTextFieldDidTap:)];
    [self.messageTextField addGestureRecognizer:tapGesture];
    
    //Table view cells
    [self.messagesTableView registerClass:[ChatMessageTableViewCell class] forCellReuseIdentifier:ChatMessageCellIdentifier];
    [self.messagesTableView registerClass:[ChatStickerTableViewCell class] forCellReuseIdentifier:ChatStickerCellIdentifier];
}

- (void)viewWillAppear:(BOOL)animated{
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
    
    // sync messages history
    //
    [self syncMessages:NO];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [ChatService shared].delegate = nil;
}

-(BOOL)hidesBottomBarWhenPushed
{
    return YES;
}

- (void)getPreviousMessages{
    
    // load more messages here
    //
    [self syncMessages:YES];
}

- (void)syncMessages:(BOOL)loadPrevious{
    NSArray *messages = [[ChatService shared] messagsForDialogId:self.dialog.ID];
    NSDate *lastMessageDateSent = nil;
    NSDate *firstMessageDateSent = nil;
    if(messages.count > 0){
        lastMessageDateSent = ((QBChatMessage *)[messages lastObject]).dateSent;
        firstMessageDateSent = ((QBChatMessage *)[messages firstObject]).dateSent;
    }
    
    __weak __typeof(self)weakSelf = self;
    
    NSMutableDictionary *extendedRequest = [[NSMutableDictionary alloc] init];
    if(loadPrevious){
        if(firstMessageDateSent != nil){
            extendedRequest[@"date_sent[lte]"] = @([firstMessageDateSent timeIntervalSince1970]-1);
        }
    }else{
        if(lastMessageDateSent != nil){
            extendedRequest[@"date_sent[gte]"] = @([lastMessageDateSent timeIntervalSince1970]+1);
        }
    }
    extendedRequest[@"sort_desc"] = @"date_sent";
    
    QBResponsePage *page = [QBResponsePage responsePageWithLimit:100 skip:0];
    [QBRequest messagesWithDialogID:self.dialog.ID
                    extendedRequest:extendedRequest
                            forPage:page
                       successBlock:^(QBResponse *response, NSArray *messages, QBResponsePage *page) {
                           if(messages.count > 0){
                               [[ChatService shared] addMessages:messages forDialogId:self.dialog.ID];
                           }
                           
                           if(loadPrevious){
                               NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                               [formatter setDateFormat:@"MMM d, h:mm a"];
                               NSString *title = [NSString stringWithFormat:@"Last update: %@", [formatter stringFromDate:[NSDate date]]];
                               NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor blackColor]
                                                                                           forKey:NSForegroundColorAttributeName];
                               NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
                               weakSelf.refreshControl.attributedTitle = attributedTitle;
                               
                               [weakSelf.refreshControl endRefreshing];
                               
                               [weakSelf.messagesTableView reloadData];
                           }else{
                               [weakSelf.messagesTableView reloadData];
                               NSInteger count = [[ChatService shared] messagsForDialogId:self.dialog.ID].count;
                               if(count > 0){
                                   [weakSelf.messagesTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:count-1 inSection:0]
                                                                     atScrollPosition:UITableViewScrollPositionBottom animated:NO];
                               }
                           }
                       } errorBlock:^(QBResponse *response) {
                           
                       }];
}

#pragma mark
#pragma mark Actions

- (IBAction)sendMessage:(id)sender{
    NSString *messageText = self.messageTextField.text;
    if(messageText.length == 0){
        return;
    }
    
    [self sendMessageWithText:messageText];
    
    // clean text field
    [self.messageTextField setText:nil];
}

#pragma mark - Sending

- (void) sendMessageWithText:(NSString*)text {
    
    // send a message
    BOOL sent = [[ChatService shared] sendMessage:text toDialog:self.dialog];
    if(!sent){
        [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Error"
                                                       description:@"Please check your internet connection"
                                                              type:TWMessageBarMessageTypeInfo];
        return;
    }
    
    // reload table
    [self.messagesTableView reloadData];
    if([[ChatService shared] messagsForDialogId:self.dialog.ID].count > 0){
        [self.messagesTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[[[ChatService shared] messagsForDialogId:self.dialog.ID] count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}


#pragma mark
#pragma mark UITableViewDelegate & UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[ChatService shared] messagsForDialogId:self.dialog.ID] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    QBChatMessage *message = [[ChatService shared] messagsForDialogId:self.dialog.ID][indexPath.row];
    if ([STKStickersManager isStickerMessage:message.text]) {
        ChatStickerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ChatStickerCellIdentifier];
        [cell fillWithStickerMessage:message];
        return cell;
    } else {
        ChatMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ChatMessageCellIdentifier];
        [cell configureCellWithMessage:message];
        return cell;
    }
    
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    QBChatMessage *chatMessage = [[[ChatService shared] messagsForDialogId:self.dialog.ID] objectAtIndex:indexPath.row];
    if ([STKStickersManager isStickerMessage:chatMessage.text]) {
        return 105.0;
    }
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

#pragma mark - UIGestureRecognizer

- (void) messageTextFieldDidTap:(UITapGestureRecognizer*) gesture {
    [self.messageTextField becomeFirstResponder];
    if (self.stickerView.isShowed) {
        [self hideStickersView];
    }
}

#pragma mark
#pragma mark Keyboard notifications

- (void)keyboardWillShow:(NSNotification *)note
{
    
    CGRect keyboardBounds = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardBounds.size.height, 0.0);
    
    [self.messagesTableView setContentInset:contentInsets];
    
    [self.messagesTableView setScrollIndicatorInsets:contentInsets];
    
    if([[ChatService shared] messagsForDialogId:self.dialog.ID].count > 0){
        [self.messagesTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[[[ChatService shared] messagsForDialogId:self.dialog.ID] count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        self.inputBackgroundView.transform = CGAffineTransformMakeTranslation(0, -keyboardBounds.size.height);
        
    }];
    
    self.isKeyboradShow = YES;
}

- (void)keyboardWillHide:(NSNotification *)note
{
    self.isKeyboradShow = NO;
    
    [self.messagesTableView setContentInset:UIEdgeInsetsZero];
    
    [self.messagesTableView setScrollIndicatorInsets:UIEdgeInsetsZero];
    
    if([[ChatService shared] messagsForDialogId:self.dialog.ID].count > 0){
        [self.messagesTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[[[ChatService shared] messagsForDialogId:self.dialog.ID] count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        self.inputBackgroundView.transform = CGAffineTransformIdentity;
        
    }];
}

#pragma mark - STKStickerPanelDelegate

- (void) stickerPanel:(STKStickerPanel*)stickerPanel didSelectStickerWithMessage:(NSString*) stickerMessage {
    [self sendMessageWithText:stickerMessage];
}

#pragma mark - Show/hide stickers

- (void) toggleStickerView {
    if (self.stickerView.isShowed) {
        [self hideStickersView];
        
    } else {
        [self showStickersView];
    }
}

- (void) showStickersView {
    UIImage *buttonImage = [[UIImage imageNamed:@"ShowKeyboadIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    [self.showStickersButton setImage:buttonImage forState:UIControlStateNormal];
    [self.showStickersButton setImage:buttonImage forState:UIControlStateHighlighted];
    
    self.messageTextField.inputView = self.stickerView;
    [self reloadStickersInputViews];
}

- (void) hideStickersView {
    
    UIImage *buttonImage = [[UIImage imageNamed:@"ShowStickersIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    [self.showStickersButton setImage:buttonImage forState:UIControlStateNormal];
    [self.showStickersButton setImage:buttonImage forState:UIControlStateHighlighted];
    
    self.messageTextField.inputView = nil;
    
    [self reloadStickersInputViews];
}


- (void) reloadStickersInputViews {
    [self.messageTextField reloadInputViews];
    if (!self.isKeyboradShow) {
        [self.messageTextField becomeFirstResponder];
    }
}


#pragma mark
#pragma mark ChatServiceDelegate

- (void)chatDidLogin
{
    // sync messages history
    //
    [self syncMessages:NO];
}

- (BOOL)chatDidReceiveMessage:(QBChatMessage *)message
{
    NSString *dialogId = message.dialogID;
    if(![self.dialog.ID isEqualToString:dialogId]){
        return NO;
    }
    
    // Reload table
    [self.messagesTableView reloadData];
    if([[ChatService shared] messagsForDialogId:self.dialog.ID].count > 0){
        [self.messagesTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[[[ChatService shared] messagsForDialogId:self.dialog.ID] count]-1 inSection:0]
                                      atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
    return YES;
}

#pragma mark - Property

- (STKStickerPanel *)stickerView {
    if (!_stickerView) {
        _stickerView = [[STKStickerPanel alloc] init];
        _stickerView.delegate = self;
    }
    return _stickerView;
}



@end
