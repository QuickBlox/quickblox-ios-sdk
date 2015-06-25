//
//  ChatViewController.m
//  sample-chat
//
//  Created by Andrey Moskvin on 6/9/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import "ChatViewController.h"
#import "DialogInfoTableViewController.h"
#import "UIImage+QM.h"
#import "UIColor+QM.h"
#import <TTTAttributedLabel/TTTAttributedLabel.h>
#import "QBServicesManager.h"
#import "StorageManager.h"

#import "LoginTableViewController.h"
#import "DialogsViewController.h"

@interface ChatViewController () <QMChatServiceDelegate, UITextViewDelegate>

@property (nonatomic, weak) QBUUser* opponentUser;
@property (nonatomic, strong ) id <NSObject> observerDidBecomeActive;

@end

@implementation ChatViewController

- (void)refreshCollectionView
{
    [self.collectionView reloadData];
    [self scrollToBottomAnimated:NO];
}

#pragma mark - Override

- (NSUInteger)senderID
{
    return [QBSession currentSession].currentUser.ID;
}

- (NSString *)senderDisplayName
{
    return [QBSession currentSession].currentUser.fullName;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.inputToolbar.contentView.leftBarButtonItem = [self accessoryButtonItem];
    self.inputToolbar.contentView.rightBarButtonItem = [self sendButtonItem];
    
    self.showLoadEarlierMessagesHeader = YES;
    
    [self updateTitle];
    
    self.items = [[[QBServicesManager instance].chatService.messagesMemoryStorage messagesWithDialogID:self.dialog.ID] mutableCopy];
    [self refreshCollectionView];
    
	if ([self.items count]) {
		[self refreshMessagesShowingProgress:NO];
	} else {
		[self refreshMessagesShowingProgress:YES];
	}
    
    __weak typeof(self)weakSelf = self;
    [self.dialog setOnUserIsTyping:^(NSUInteger userID) {
        __typeof(self) strongSelf = weakSelf;
        if ([QBSession currentSession].currentUser.ID == userID) {
            return;
        }
        strongSelf.title = @"typing...";
    }];

    [self.dialog setOnUserStoppedTyping:^(NSUInteger userID) {
        __typeof(self) strongSelf = weakSelf;
        [strongSelf updateTitle];
    }];
}

- (void)refreshMessagesShowingProgress:(BOOL)showingProgress {
	
	if( showingProgress ) {
		[SVProgressHUD showWithStatus:@"Refreshing..." maskType:SVProgressHUDMaskTypeClear];
	}
	
	__weak typeof(self) weakSelf = self;
	[[QBServicesManager instance].chatService messagesWithChatDialogID:self.dialog.ID completion:^(QBResponse *response, NSArray *messages) {
		if( response.success ) {
			__typeof(self) strongSelf = weakSelf;
			strongSelf.items = [messages mutableCopy];
			[strongSelf refreshCollectionView];
			[SVProgressHUD dismiss];
		}
		else {
			[SVProgressHUD showErrorWithStatus:@"Can not refresh messages"];
			NSLog(@"can not refresh messages: %@", response.error.error);
		}
	}];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[QBServicesManager instance].chatService addDelegate:self];
	
	__weak __typeof(self) weakSelf = self;
	self.observerDidBecomeActive = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
		__typeof(self) strongSelf = weakSelf;
		[strongSelf refreshMessagesShowingProgress:YES];
	}];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	
    if (self.shouldUpdateNavigationStack) {
        NSMutableArray *newNavigationStack = [NSMutableArray array];
        
        [self.navigationController.viewControllers enumerateObjectsUsingBlock:^(UIViewController* obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[LoginTableViewController class]] || [obj isKindOfClass:[DialogsViewController class]]) {
                [newNavigationStack addObject:obj];
            }
        }];
        [newNavigationStack addObject:self];
        [self.navigationController setViewControllers:[newNavigationStack copy] animated:NO];
        
        self.shouldUpdateNavigationStack = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[QBServicesManager instance].chatService removeDelegate:self];
	[[NSNotificationCenter defaultCenter] removeObserver:self.observerDidBecomeActive];
    
    [self.dialog clearTypingStatusBlocks];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"kShowDialogInfoViewController"]) {
        DialogInfoTableViewController* viewController = segue.destinationViewController;
        viewController.dialog = self.dialog;
    }
}

- (void)updateTitle
{
    if (self.dialog.type == QBChatDialogTypePrivate) {
        NSMutableArray* mutableOccupants = [self.dialog.occupantIDs mutableCopy];
        [mutableOccupants removeObject:@([self senderID])];
        NSNumber* opponentID = [mutableOccupants firstObject];
        QBUUser* opponentUser = [[StorageManager instance] userByID:[opponentID unsignedIntegerValue]];
        NSAssert(opponentUser, @"opponent must exists");
        self.opponentUser = opponentUser;
        self.title = self.opponentUser.fullName;
    } else {
        self.title = self.dialog.name;
    }
}

#pragma mark - Tool bar

- (UIButton *)accessoryButtonItem {
    
    UIImage *accessoryImage = [UIImage imageNamed:@"attachment_ic"];
    UIImage *normalImage = [accessoryImage imageMaskedWithColor:[UIColor lightGrayColor]];
    UIImage *highlightedImage = [accessoryImage imageMaskedWithColor:[UIColor darkGrayColor]];
    
    UIButton *accessoryButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, accessoryImage.size.width, 32.0f)];
    [accessoryButton setImage:normalImage forState:UIControlStateNormal];
    [accessoryButton setImage:highlightedImage forState:UIControlStateHighlighted];
    
    accessoryButton.contentMode = UIViewContentModeScaleAspectFit;
    accessoryButton.backgroundColor = [UIColor clearColor];
    accessoryButton.tintColor = [UIColor lightGrayColor];
    
    return accessoryButton;
}

- (UIButton *)sendButtonItem {
    
    NSString *sendTitle = NSLocalizedString(@"Send", nil);
    
    UIButton *sendButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [sendButton setTitle:sendTitle forState:UIControlStateNormal];
    [sendButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [sendButton setTitleColor:[[UIColor blueColor] colorByDarkeningColorWithValue:0.1f] forState:UIControlStateHighlighted];
    [sendButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    
    sendButton.titleLabel.font = [UIFont boldSystemFontOfSize:17.0f];
    sendButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    sendButton.titleLabel.minimumScaleFactor = 0.85f;
    sendButton.contentMode = UIViewContentModeCenter;
    sendButton.backgroundColor = [UIColor clearColor];
    sendButton.tintColor = [UIColor blueColor];
    
    CGFloat maxHeight = 32.0f;
    
    CGRect sendTitleRect = [sendTitle boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, maxHeight)
                                                   options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                attributes:@{NSFontAttributeName : sendButton.titleLabel.font}
                                                   context:nil];
    
    sendButton.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(CGRectIntegral(sendTitleRect)), maxHeight);
    
    return sendButton;
}

#pragma mark Tool bar Actions

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSUInteger)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date
{
    QBChatMessage *message = [QBChatMessage message];
    message.text = text;
    message.senderID = senderId;
    message.senderNick = [QBServicesManager instance].currentUser.fullName;
    
    [[QBServicesManager instance].chatService sendMessage:message toDialogId:self.dialog.ID save:YES completion:nil];
    [self finishSendingMessageAnimated:YES];
}

- (void)didPressAccessoryButton:(UIButton *)sender
{
    
}

#pragma mark - Cell classes

- (Class)viewClassForItem:(QBChatMessage *)item
{    
    if (item.senderID == QMMessageTypeContactRequest) {
        if (item.senderID != self.senderID) {
            return [QMChatContactRequestCell class];
        }
    } else if (item.senderID == QMMessageTypeRejectContactRequest) {
        return [QMChatNotificationCell class];
    } else if (item.senderID == QMMessageTypeAcceptContactRequest) {
        return [QMChatNotificationCell class];
    } else {
        if (item.senderID != self.senderID) {
            return [QMChatIncomingCell class];
        } else {
            return [QMChatOutgoingCell class];
        }
    }
    return nil;
}

#pragma mark - Strings builder

- (NSAttributedString *)attributedStringForItem:(QBChatMessage *)messageItem {
    
    UIColor *textColor = [messageItem senderID] == self.senderID ? [UIColor whiteColor] : [UIColor colorWithWhite:0.290 alpha:1.000];
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:15];
    NSDictionary *attributes = @{ NSForegroundColorAttributeName:textColor, NSFontAttributeName:font};
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:messageItem.text attributes:attributes];
    
    return attrStr;
}

- (NSAttributedString *)topLabelAttributedStringForItem:(QBChatMessage *)messageItem {
    
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:14];
    
    if ([messageItem senderID] == self.senderID) {
        return nil;
    }
    
    NSString *topLabelText = self.opponentUser.fullName != nil ? self.opponentUser.fullName : self.opponentUser.login;
    
    if (self.dialog.type != QBChatDialogTypePrivate) {
        topLabelText = (messageItem.senderNick != nil) ? messageItem.senderNick : [NSString stringWithFormat:@"%lu",(unsigned long)messageItem.senderID];
    }

    NSDictionary *attributes = @{ NSForegroundColorAttributeName:[UIColor colorWithRed:0.184 green:0.467 blue:0.733 alpha:1.000], NSFontAttributeName:font};
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:topLabelText attributes:attributes];
    
    return attrStr;
}

- (NSAttributedString *)bottomLabelAttributedStringForItem:(QBChatMessage *)messageItem {
    
    UIColor *textColor = [messageItem senderID] == self.senderID ? [UIColor colorWithWhite:1.000 alpha:0.510] : [UIColor colorWithWhite:0.000 alpha:0.490];
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:12];
    
    NSDictionary *attributes = @{ NSForegroundColorAttributeName:textColor, NSFontAttributeName:font};
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:[self timeStampWithDate:messageItem.dateSent]
                                                                                attributes:attributes];
    
    return attrStr;
}

#pragma mark - Collection View Datasource

- (CGSize)collectionView:(QMChatCollectionView *)collectionView dynamicSizeAtIndexPath:(NSIndexPath *)indexPath maxWidth:(CGFloat)maxWidth {
    
    QBChatMessage *item = self.items[indexPath.item];
    
    NSAttributedString *attributedString = [self attributedStringForItem:item];
    
    CGSize size = [TTTAttributedLabel sizeThatFitsAttributedString:attributedString
                                                   withConstraints:CGSizeMake(maxWidth, MAXFLOAT)
                                            limitedToNumberOfLines:0];
    return size;
}

- (CGFloat)collectionView:(QMChatCollectionView *)collectionView minWidthAtIndexPath:(NSIndexPath *)indexPath {
    
    QBChatMessage *item = self.items[indexPath.item];
    
    NSAttributedString *attributedString =
    [item senderID] == self.senderID ?  [self bottomLabelAttributedStringForItem:item] : [self topLabelAttributedStringForItem:item];
    
    CGSize size = [TTTAttributedLabel sizeThatFitsAttributedString:attributedString
                                                   withConstraints:CGSizeMake(1000, 10000)
                                            limitedToNumberOfLines:1];
    
    return size.width;
}

- (void)collectionView:(QMChatCollectionView *)collectionView header:(QMLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
    [[QBServicesManager instance].chatService earlierMessagesWithChatDialogID:self.dialog.ID completion:nil];
}

#pragma mark - Utility

- (NSString *)timeStampWithDate:(NSDate *)date {
    
    static NSDateFormatter *dateFormatter = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"HH:mm";
    });
    
    NSString *timeStamp = [dateFormatter stringFromDate:date];
    
    return timeStamp;
}

- (QMChatCellLayoutModel)collectionView:(QMChatCollectionView *)collectionView layoutModelAtIndexPath:(NSIndexPath *)indexPath {
    QMChatCellLayoutModel layoutModel = [super collectionView:collectionView layoutModelAtIndexPath:indexPath];
    layoutModel.avatarSize = (CGSize){0.0, 0.0};
    
    return layoutModel;
}

#pragma mark - QMChatServiceDelegate

- (void)chatService:(QMChatService *)chatService didAddMessageToMemoryStorage:(QBChatMessage *)message forDialogID:(NSString *)dialogID {
    if ([self.dialog.ID isEqualToString:dialogID]) {
        self.items = [[chatService.messagesMemoryStorage messagesWithDialogID:dialogID] mutableCopy];
        [self refreshCollectionView];
    }
}

- (void)chatService:(QMChatService *)chatService didAddMessagesToMemoryStorage:(NSArray *)messages forDialogID:(NSString *)dialogID
{
    if ([self.dialog.ID isEqualToString:dialogID]) {
        self.items = [[chatService.messagesMemoryStorage messagesWithDialogID:dialogID] mutableCopy];
        [self refreshCollectionView];
    }
}


- (void)chatService:(QMChatService *)chatService didUpdateChatDialogInMemoryStorage:(QBChatDialog *)chatDialog{
	if( [self.dialog.ID isEqualToString:chatDialog.ID] ) {
		self.dialog = chatDialog;
	}
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [super textViewDidBeginEditing:textView];
    
    [self.dialog sendUserIsTyping];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [super textViewDidEndEditing:textView];
    
    [self.dialog sendUserStoppedTyping];
}


@end

