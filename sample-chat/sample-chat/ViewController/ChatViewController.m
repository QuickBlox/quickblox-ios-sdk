//
//  ChatViewController.m
//  sample-chat
//
//  Created by Andrey Moskvin on 6/9/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import "ChatViewController.h"
#import "DialogInfoTableViewController.h"
#import "LoginTableViewController.h"
#import "DialogsViewController.h"
#import "MessageStatusStringBuilder.h"
#import "ServicesManager.h"

#import "UIImage+fixOrientation.h"
#import <TTTAttributedLabel/TTTAttributedLabel.h>
#import <TWMessageBarManager.h>

static const NSUInteger widthPadding = 40.0f;

@interface ChatViewController ()
<
QMChatServiceDelegate,
QMChatConnectionDelegate,
UITextViewDelegate,
QMChatAttachmentServiceDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
UIActionSheetDelegate,
QMChatCellDelegate
>

@property (nonatomic, weak) QBUUser *opponentUser;
@property (nonatomic, strong) MessageStatusStringBuilder *stringBuilder;
@property (nonatomic, strong) NSMapTable *attachmentCells;
@property (nonatomic, readonly) UIImagePickerController *pickerController;
@property (nonatomic, strong) NSTimer *typingTimer;
@property (nonatomic, strong) id observerWillResignActive;

@property (nonatomic, strong) NSArray<QBChatMessage *> *unreadMessages;

@property (nonatomic, strong) NSMutableSet *detailedCells;

@end

@implementation ChatViewController
@synthesize pickerController = _pickerController;

- (UIImagePickerController *)pickerController {
    if (_pickerController == nil) {
        _pickerController = [UIImagePickerController new];
        _pickerController.delegate = self;
    }
    return _pickerController;
}

#pragma mark - Override

- (NSUInteger)senderID {
    return [QBSession currentSession].currentUser.ID;
}

- (NSString *)senderDisplayName {
    return [QBSession currentSession].currentUser.fullName;
}

- (CGFloat)heightForSectionHeader {
    return 40.0f;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // top layout inset for collection view
    self.topContentAdditionalInset = self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.inputToolbar.contentView.backgroundColor = [UIColor whiteColor];
    self.inputToolbar.contentView.textView.placeHolder = NSLocalizedString(@"SA_STR_MESSAGE_PLACEHOLDER", nil);
    self.attachmentCells = [NSMapTable strongToWeakObjectsMapTable];
    self.stringBuilder = [MessageStatusStringBuilder new];
    self.detailedCells = [NSMutableSet set];
    
    [self updateTitle];
    
    if (self.dialog.type == QBChatDialogTypePrivate) {
        
        // Handling 'typing' status.
        __weak typeof(self)weakSelf = self;
        [self.dialog setOnUserIsTyping:^(NSUInteger userID) {
            
            __typeof(weakSelf)strongSelf = weakSelf;
            if ([QBSession currentSession].currentUser.ID == userID) {
                return;
            }
            strongSelf.title = NSLocalizedString(@"SA_STR_MESSAGE_PLACEHOLDER", nil);
        }];
        
        // Handling user stopped typing.
        [self.dialog setOnUserStoppedTyping:^(NSUInteger userID) {
            
            __typeof(weakSelf)strongSelf = weakSelf;
            if ([QBSession currentSession].currentUser.ID == userID) {
                return;
            }
            [strongSelf updateTitle];
        }];
    }
    
    [[ServicesManager instance].chatService addDelegate:self];
    [ServicesManager instance].chatService.chatAttachmentService.delegate = self;
    
    if ([[self storedMessages] count] > 0 && self.chatSectionManager.totalMessagesCount == 0) {
        // inserting all messages from memory storage
        [self.chatSectionManager addMessages:[self storedMessages]];
    }
    
    [self refreshMessagesShowingProgress:NO];
}

- (void)refreshMessagesShowingProgress:(BOOL)showingProgress {
    
    if (showingProgress) {
        [SVProgressHUD showWithStatus:NSLocalizedString(@"SA_STR_LOADING_MESSAGES", nil) maskType:SVProgressHUDMaskTypeClear];
    }
    
    __weak __typeof(self)weakSelf = self;
	
	// Retrieving messages from Quickblox REST history and cache.
    [[ServicesManager instance].chatService messagesWithChatDialogID:self.dialog.ID completion:^(QBResponse *response, NSArray *messages) {
        if (response.success) {
			
			if ([messages count] > 0) {
				[weakSelf.chatSectionManager addMessages:messages];
			}
            [SVProgressHUD dismiss];
            
        } else {
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"SA_STR_ERROR", nil)];
            NSLog(@"can not refresh messages: %@", response.error.error);
        }
    }];
}

- (NSArray<QBChatMessage *> *)storedMessages {
    return [[ServicesManager instance].chatService.messagesMemoryStorage messagesWithDialogID:self.dialog.ID];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Saving currently opened dialog.
    [ServicesManager instance].currentDialogID = self.dialog.ID;
    
    __weak __typeof(self)weakSelf = self;
    self.observerWillResignActive = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillResignActiveNotification
                                                                                      object:nil
                                                                                       queue:nil
                                                                                  usingBlock:^(NSNotification *note) {
                                                                                      [weakSelf fireStopTypingIfNecessary];
                                                                                  }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self.observerWillResignActive];
    
    // Deletes typing blocks.
    [self.dialog clearTypingStatusBlocks];
    
    // Resetting currently opened dialog.
    [ServicesManager instance].currentDialogID = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"kShowDialogInfoViewController"]) {
        DialogInfoTableViewController *viewController = segue.destinationViewController;
        viewController.dialog = self.dialog;
    }
}

- (void)updateTitle {
    
    if (self.dialog.type == QBChatDialogTypePrivate) {
        
        NSMutableArray *mutableOccupants = [self.dialog.occupantIDs mutableCopy];
        [mutableOccupants removeObject:@([self senderID])];
        NSNumber *opponentID = [mutableOccupants firstObject];
        QBUUser *opponentUser = [[ServicesManager instance].usersService.usersMemoryStorage userWithID:[opponentID unsignedIntegerValue]];
		if (!opponentUser) {
			self.title = [opponentID stringValue];
			return;
		}
        self.opponentUser = opponentUser;
        self.title = self.opponentUser.fullName;
    }
    else {
        
        self.title = self.dialog.name;
    }
}

#pragma mark - Utilities

- (void)sendReadStatusForMessage:(QBChatMessage *)message {
    
    if (message.senderID != self.senderID && ![message.readIDs containsObject:@(self.senderID)]) {
        [[ServicesManager instance].chatService readMessage:message completion:^(NSError *error) {
            
            if (error != nil) {
                NSLog(@"Problems while marking message as read! Error: %@", error);
				return;
            }
			if ([UIApplication sharedApplication].applicationIconBadgeNumber > 0) {
				[UIApplication sharedApplication].applicationIconBadgeNumber--;
			}
        }];
    }
}

- (void)readMessages:(NSArray *)messages {
    
    if ([ServicesManager instance].isAuthorized) {
        
        [[ServicesManager instance].chatService readMessages:messages forDialogID:self.dialog.ID completion:nil];
    }
    else {
        
        self.unreadMessages = messages;
    }
}

- (void)fireStopTypingIfNecessary {
    
    [self.typingTimer invalidate];
    self.typingTimer = nil;
    [self.dialog sendUserStoppedTyping];
}

#pragma mark Tool bar Actions

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSUInteger)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date {
    
    if (self.typingTimer != nil) {
        [self fireStopTypingIfNecessary];
    }
    
    QBChatMessage *message = [QBChatMessage message];
    message.text = text;
    message.senderID = senderId;
    message.markable = YES;
    message.deliveredIDs = @[@(self.senderID)];
    message.readIDs = @[@(self.senderID)];
    message.dialogID = self.dialog.ID;
    message.dateSent = date;
    
    // Sending message.
    [[ServicesManager instance].chatService sendMessage:message toDialogID:self.dialog.ID saveToHistory:YES saveToStorage:YES completion:^(NSError *error) {
        
        if (error != nil) {
            NSLog(@"Failed to send message with error: %@", error);
            [[TWMessageBarManager sharedInstance] showMessageWithTitle:NSLocalizedString(@"SA_STR_ERROR", nil) description:error.localizedRecoverySuggestion type:TWMessageBarMessageTypeError];
        }
    }];
    
    [self finishSendingMessageAnimated:YES];
}

#pragma mark - Cell classes

- (Class)viewClassForItem:(QBChatMessage *)item {
    if (item.isNotificatonMessage) {
        
        return [QMChatNotificationCell class];
	}
	
	if (item.senderID != self.senderID) {
		if (item.isMediaMessage && item.attachmentStatus != QMMessageAttachmentStatusError) {
			return [QMChatAttachmentIncomingCell class];
		}
		else {
			return [QMChatIncomingCell class];
		}
	}
	else {
		if (item.isMediaMessage && item.attachmentStatus != QMMessageAttachmentStatusError) {
			return [QMChatAttachmentOutgoingCell class];
		}
		else {
			return [QMChatOutgoingCell class];
		}
	}
}

#pragma mark - Strings builder

- (NSAttributedString *)attributedStringForItem:(QBChatMessage *)messageItem {
	
    UIColor *textColor;
    
    if (messageItem.isNotificatonMessage) {
        textColor =  [UIColor blackColor];
    }
    else {
       textColor = [messageItem senderID] == self.senderID ? [UIColor whiteColor] : [UIColor blackColor];
    }
    
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:17.0f] ;
    NSDictionary *attributes = @{ NSForegroundColorAttributeName:textColor, NSFontAttributeName:font};
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:messageItem.text ? messageItem.text : @"" attributes:attributes];

    return attrStr;
}

- (NSAttributedString *)topLabelAttributedStringForItem:(QBChatMessage *)messageItem {
    
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:17.0f];
    
    if ([messageItem senderID] == self.senderID || self.dialog.type == QBChatDialogTypePrivate) {
        return nil;
    }
	
    NSString *topLabelText = self.opponentUser.fullName != nil ? self.opponentUser.fullName : self.opponentUser.login;
    
    if (self.dialog.type != QBChatDialogTypePrivate) {
        QBUUser *messageSender = [[ServicesManager instance].usersService.usersMemoryStorage userWithID:messageItem.senderID];
		
		if (messageSender) {
			topLabelText = messageSender.login;
		}
		else {
			topLabelText = [NSString stringWithFormat:@"@%lu",(unsigned long)messageItem.senderID];
		}
    }
    
    // setting the paragraph style lineBreakMode to NSLineBreakByTruncatingTail in order to TTTAttributedLabel cut the line in a correct way
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    NSDictionary *attributes = @{ NSForegroundColorAttributeName:[UIColor colorWithRed:0 green:122.0f / 255.0f blue:1.0f alpha:1.000],
                                  NSFontAttributeName:font,
                                  NSParagraphStyleAttributeName: paragraphStyle};
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:topLabelText attributes:attributes];
    
    return attrStr;
}

- (NSAttributedString *)bottomLabelAttributedStringForItem:(QBChatMessage *)messageItem {
    
    UIColor *textColor = [messageItem senderID] == self.senderID ? [UIColor colorWithWhite:1 alpha:0.7f] : [UIColor colorWithWhite:0.000 alpha:0.7f];
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:13.0f];
    
    NSDictionary *attributes = @{ NSForegroundColorAttributeName:textColor, NSFontAttributeName:font};
    NSString *text = messageItem.dateSent ? [self timeStampWithDate:messageItem.dateSent] : @"";
    if ([messageItem senderID] == self.senderID) {
        text = [NSString stringWithFormat:@"%@\n%@", text, [self.stringBuilder statusFromMessage:messageItem]];
    }
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:text
                                                                                attributes:attributes];
    
    return attrStr;	
}

#pragma mark - Collection View Datasource

- (CGSize)collectionView:(QMChatCollectionView *)collectionView dynamicSizeAtIndexPath:(NSIndexPath *)indexPath maxWidth:(CGFloat)maxWidth {
    
    QBChatMessage *item = [self.chatSectionManager messageForIndexPath:indexPath];
    Class viewClass = [self viewClassForItem:item];
    CGSize size = CGSizeZero;
    
    if (viewClass == [QMChatAttachmentIncomingCell class]) {
        
        size = CGSizeMake(MIN(200, maxWidth), 200);
        
    }
    else if (viewClass == [QMChatAttachmentOutgoingCell class]) {
        
        NSAttributedString *attributedString = [self bottomLabelAttributedStringForItem:item];
        
        CGSize bottomLabelSize = [TTTAttributedLabel sizeThatFitsAttributedString:attributedString
                                                                  withConstraints:CGSizeMake(MIN(200, maxWidth), CGFLOAT_MAX)
                                                           limitedToNumberOfLines:0];
        size = CGSizeMake(MIN(200, maxWidth), 200 + ceilf(bottomLabelSize.height));
        
    }
    else if (viewClass == [QMChatNotificationCell class]) {
        
        NSAttributedString *attributedString = [self attributedStringForItem:item];
        
        size = [TTTAttributedLabel sizeThatFitsAttributedString:attributedString
                                                withConstraints:CGSizeMake(maxWidth, CGFLOAT_MAX)
                                         limitedToNumberOfLines:0];
    }
    else {
        
        NSAttributedString *attributedString = [self attributedStringForItem:item];
        
        size = [TTTAttributedLabel sizeThatFitsAttributedString:attributedString
                                                withConstraints:CGSizeMake(maxWidth, CGFLOAT_MAX)
                                         limitedToNumberOfLines:0];
    }
    
    return size;
}

- (CGFloat)collectionView:(QMChatCollectionView *)collectionView minWidthAtIndexPath:(NSIndexPath *)indexPath {
    
    QBChatMessage *item = [self.chatSectionManager messageForIndexPath:indexPath];
    
    CGSize size = CGSizeZero;
    if ([self.detailedCells containsObject:item.ID]) {
        
        size = [TTTAttributedLabel sizeThatFitsAttributedString:[self bottomLabelAttributedStringForItem:item]
                                                withConstraints:CGSizeMake(CGRectGetWidth(self.collectionView.frame) - widthPadding, CGFLOAT_MAX)
                                         limitedToNumberOfLines:0];
    }
    
    if (self.dialog.type != QBChatDialogTypePrivate) {
        
        CGSize topLabelSize = [TTTAttributedLabel sizeThatFitsAttributedString:[self topLabelAttributedStringForItem:item]
                                                               withConstraints:CGSizeMake(CGRectGetWidth(self.collectionView.frame) - widthPadding, CGFLOAT_MAX)
                                                        limitedToNumberOfLines:0];
        
        if (topLabelSize.width > size.width) {
            size = topLabelSize;
        }
    }
    
    return size.width;
}

/**
 * Allows to perform copy action for QMChatIncomingCell and QMChatOutgoingCell
 */
- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    
    QBChatMessage *item = [self.chatSectionManager messageForIndexPath:indexPath];
    Class viewClass = [self viewClassForItem:item];
    
    if (viewClass == [QMChatAttachmentIncomingCell class]
        || viewClass == [QMChatAttachmentOutgoingCell class]
        || viewClass == [QMChatNotificationCell class]
        || viewClass == [QMChatContactRequestCell class]){
        
        return NO;
    }
    
    return [super collectionView:collectionView canPerformAction:action forItemAtIndexPath:indexPath withSender:sender];
}

/**
 * Allows to perform copy action for QMChatIncomingCell and QMChatOutgoingCell
 */
- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    
    QBChatMessage *message = [self.chatSectionManager messageForIndexPath:indexPath];
    
    Class viewClass = [self viewClassForItem:message];
    
    if (viewClass == [QMChatAttachmentIncomingCell class] || viewClass == [QMChatAttachmentOutgoingCell class]) return;
    [UIPasteboard generalPasteboard].string = message.text;
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

#pragma mark - QMChatCollectionViewDelegateFlowLayout

- (QMChatCellLayoutModel)collectionView:(QMChatCollectionView *)collectionView layoutModelAtIndexPath:(NSIndexPath *)indexPath {
    QMChatCellLayoutModel layoutModel = [super collectionView:collectionView layoutModelAtIndexPath:indexPath];
    
    layoutModel.avatarSize = (CGSize){0.0, 0.0};
    layoutModel.topLabelHeight = 0.0f;
    layoutModel.maxWidthMarginSpace = 20.0f;
    
    QBChatMessage *item = [self.chatSectionManager messageForIndexPath:indexPath];
    Class class = [self viewClassForItem:item];
    
    if (class == [QMChatAttachmentIncomingCell class] ||
        class == [QMChatIncomingCell class]) {
        
        if (self.dialog.type != QBChatDialogTypePrivate) {
            
            NSAttributedString *topLabelString = [self topLabelAttributedStringForItem:item];
            CGSize size = [TTTAttributedLabel sizeThatFitsAttributedString:topLabelString
                                                           withConstraints:CGSizeMake(CGRectGetWidth(self.collectionView.frame) - widthPadding, CGFLOAT_MAX)
                                                    limitedToNumberOfLines:1];
            layoutModel.topLabelHeight = size.height;
        }
        
        layoutModel.spaceBetweenTopLabelAndTextView = 5.0f;
    }
    else if (class == [QMChatNotificationCell class]) {
        
        layoutModel.spaceBetweenTopLabelAndTextView = 5.0f;
    }
    
    CGSize size = CGSizeZero;
    if ([self.detailedCells containsObject:item.ID]) {
        NSAttributedString *bottomAttributedString = [self bottomLabelAttributedStringForItem:item];
        size = [TTTAttributedLabel sizeThatFitsAttributedString:bottomAttributedString
                                                withConstraints:CGSizeMake(CGRectGetWidth(self.collectionView.frame) - widthPadding, CGFLOAT_MAX)
                                         limitedToNumberOfLines:0];
    }
    layoutModel.bottomLabelHeight = ceilf(size.height);
    
    layoutModel.spaceBetweenTextViewAndBottomLabel = 5.0f;
    
    return layoutModel;
}

- (void)collectionView:(QMChatCollectionView *)collectionView configureCell:(UICollectionViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    [super collectionView:collectionView configureCell:cell forIndexPath:indexPath];
	
	QMChatCell *chatCell = (QMChatCell *)cell;
	
    // subscribing to cell delegate
    [chatCell setDelegate:self];
    
    [chatCell containerView].highlightColor = [UIColor colorWithWhite:0.5 alpha:0.5];
    
    if ([cell isKindOfClass:[QMChatOutgoingCell class]] || [cell isKindOfClass:[QMChatAttachmentOutgoingCell class]]) {
        [chatCell containerView].bgColor = [UIColor colorWithRed:0 green:121.0f/255.0f blue:1 alpha:1.0f];
    }
    else if ([cell isKindOfClass:[QMChatIncomingCell class]] || [cell isKindOfClass:[QMChatAttachmentIncomingCell class]]) {
        [chatCell containerView].bgColor = [UIColor colorWithRed:231.0f / 255.0f green:231.0f / 255.0f blue:231.0f / 255.0f alpha:1.0f];
    }
    else if ([cell isKindOfClass:[QMChatNotificationCell class]]) {
        [chatCell containerView].bgColor = self.collectionView.backgroundColor;
        // avoid tapping for Notification Cell
        cell.userInteractionEnabled = NO;
    }
    
    if (![cell conformsToProtocol:@protocol(QMChatAttachmentCell)]) {
		return;
	}
	
	QBChatMessage *message = [self.chatSectionManager messageForIndexPath:indexPath];
	
	if (message.attachments == nil) {
		return;
	}
	QBChatAttachment *attachment = message.attachments.firstObject;
	
	NSMutableArray *keysToRemove = [NSMutableArray array];
	
	NSEnumerator *enumerator = [self.attachmentCells keyEnumerator];
	NSString *existingAttachmentID = nil;
	while (existingAttachmentID = [enumerator nextObject]) {
		UICollectionViewCell *cachedCell = [self.attachmentCells objectForKey:existingAttachmentID];
		if ([cachedCell isEqual:cell]) {
			[keysToRemove addObject:existingAttachmentID];
		}
	}
	
	for (NSString *key in keysToRemove) {
		[self.attachmentCells removeObjectForKey:key];
	}
	
	[self.attachmentCells setObject:cell forKey:attachment.ID];
	[(id<QMChatAttachmentCell>)cell setAttachmentID:attachment.ID];
	
	__weak typeof(self)weakSelf = self;
	// Getting image from chat attachment service.
	[[ServicesManager instance].chatService.chatAttachmentService getImageForAttachmentMessage:message completion:^(NSError *error, UIImage *image) {
		//
		
		if ([(id<QMChatAttachmentCell>)cell attachmentID] != attachment.ID) return;
		
		[weakSelf.attachmentCells removeObjectForKey:attachment.ID];
		
		if (error != nil) {
			[SVProgressHUD showErrorWithStatus:error.localizedDescription];
		} else {
			if (image != nil) {
				[(id<QMChatAttachmentCell>)cell setAttachmentImage:image];
				[cell updateConstraints];
			}
		}
	}];
	
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	
    NSUInteger lastSection = [self.collectionView numberOfSections] - 1;
    if (indexPath.section == lastSection && indexPath.item == [self.collectionView numberOfItemsInSection:lastSection] - 1) {
        // the very first message
        // load more if exists
        __weak typeof(self)weakSelf = self;
        // Getting earlier messages for chat dialog identifier.
        [[[ServicesManager instance].chatService loadEarlierMessagesWithChatDialogID:self.dialog.ID] continueWithBlock:^id(BFTask *task) {
            
            if ([task.result count] > 0) {
                [weakSelf.chatSectionManager addMessages:task.result];
            }
            
            return nil;
        }];
    }
    
    // marking message as read if needed
    QBChatMessage *itemMessage = [self.chatSectionManager messageForIndexPath:indexPath];
    [self sendReadStatusForMessage:itemMessage];
    
    return [super collectionView:collectionView cellForItemAtIndexPath:indexPath];
}

#pragma mark - QMChatCellDelegate

- (void)chatCellDidTapContainer:(QMChatCell *)cell {
    
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    QBChatMessage *currentMessage = [self.chatSectionManager messageForIndexPath:indexPath];
    
    if ([self.detailedCells containsObject:currentMessage.ID]) {
        [self.detailedCells removeObject:currentMessage.ID];
    } else {
        [self.detailedCells addObject:currentMessage.ID];
    }
    
    [self.collectionView.collectionViewLayout removeSizeFromCacheForItemID:currentMessage.ID];
    [self.collectionView performBatchUpdates:nil completion:nil];
}

- (void)chatCell:(QMChatCell *)cell didPerformAction:(SEL)action withSender:(id)sender {
    
}

- (void)chatCellDidTapAvatar:(QMChatCell *)cell {
    
}

- (void)chatCell:(QMChatCell *)cell didTapAtPosition:(CGPoint)position {
    
}

#pragma mark - QMChatServiceDelegate

- (void)chatService:(QMChatService *)chatService didLoadMessagesFromCache:(NSArray *)messages forDialogID:(NSString *)dialogID {
    
    if ([self.dialog.ID isEqualToString:dialogID]) {
        
        [self.chatSectionManager addMessages:messages];
    }
}

- (void)chatService:(QMChatService *)chatService didAddMessageToMemoryStorage:(QBChatMessage *)message forDialogID:(NSString *)dialogID {
    
    if ([self.dialog.ID isEqualToString:dialogID]) {
        // Inserting message received from XMPP or self sent
        [self.chatSectionManager addMessage:message];
    }
}

- (void)chatService:(QMChatService *)chatService didUpdateChatDialogInMemoryStorage:(QBChatDialog *)chatDialog {
    
    if (self.dialog.type != QBChatDialogTypePrivate && [self.dialog.ID isEqualToString:chatDialog.ID]) {
        
        self.title = self.dialog.name;
    }
}

- (void)chatService:(QMChatService *)chatService didUpdateMessage:(QBChatMessage *)message forDialogID:(NSString *)dialogID {
    
    if ([self.dialog.ID isEqualToString:dialogID] && message.senderID == self.senderID) {
        
        [self.chatSectionManager updateMessage:message];
    }
}

- (void)chatService:(QMChatService *)chatService didUpdateMessages:(NSArray *)messages forDialogID:(NSString *)dialogID {
    
    if ([self.dialog.ID isEqualToString:dialogID]) {
        
        [self.chatSectionManager updateMessages:messages];
    }
}

#pragma mark - QMChatConnectionDelegate

- (void)refreshAndReadMessages; {
    
    [self refreshMessagesShowingProgress:YES];
    
    [self readMessages:self.unreadMessages];
    self.unreadMessages = nil;
}

- (void)chatServiceChatDidConnect:(QMChatService *)chatService {
    
    [self refreshAndReadMessages];
}

- (void)chatServiceChatDidReconnect:(QMChatService *)chatService {
    
    [self refreshAndReadMessages];
}

#pragma mark - QMChatAttachmentServiceDelegate

- (void)chatAttachmentService:(QMChatAttachmentService *)chatAttachmentService didChangeAttachmentStatus:(QMMessageAttachmentStatus)status forMessage:(QBChatMessage *)message {

    if (status != QMMessageAttachmentStatusNotLoaded) {
		
        if ([message.dialogID isEqualToString:self.dialog.ID]) {
            
            [self.chatSectionManager updateMessage:message];
        }
    }
}

- (void)chatAttachmentService:(QMChatAttachmentService *)chatAttachmentService didChangeLoadingProgress:(CGFloat)progress forChatAttachment:(QBChatAttachment *)attachment {
    
    id<QMChatAttachmentCell> cell = [self.attachmentCells objectForKey:attachment.ID];
    if (cell != nil) {
        
        [cell updateLoadingProgress:progress];
    }
}

- (void)chatAttachmentService:(QMChatAttachmentService *)chatAttachmentService didChangeUploadingProgress:(CGFloat)progress forMessage:(QBChatMessage *)message {
    
    id<QMChatAttachmentCell> cell = [self.attachmentCells objectForKey:message.ID];
    
    if (cell == nil && progress < 1.0f) {
        
        NSIndexPath *indexPath = [self.chatSectionManager indexPathForMessage:message];
        cell = (UICollectionViewCell <QMChatAttachmentCell> *)[self.collectionView cellForItemAtIndexPath:indexPath];
        [self.attachmentCells setObject:cell forKey:message.ID];
    }
    
    if (cell != nil) {
        
        [cell updateLoadingProgress:progress];
    }
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if (![ServicesManager instance].isAuthorized) {
        
        return YES;
    }
    
    if (self.typingTimer) {
        
        [self.typingTimer invalidate];
        self.typingTimer = nil;
    } else {
        
        [self.dialog sendUserIsTyping];
    }
    
    self.typingTimer = [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(fireStopTypingIfNecessary) userInfo:nil repeats:NO];
    
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [super textViewDidEndEditing:textView];
    
    [self fireStopTypingIfNecessary];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)didPickAttachmentImage:(UIImage *)image {
    
    QBChatMessage *message = [QBChatMessage new];
    message.senderID = self.senderID;
    message.dialogID = self.dialog.ID;
    message.dateSent = [NSDate date];
    
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __typeof(weakSelf)strongSelf = weakSelf;
        UIImage *newImage = image;
        if (strongSelf.pickerController.sourceType == UIImagePickerControllerSourceTypeCamera) {
            newImage = [newImage fixOrientation];
        }
        
        UIImage *resizedImage = [strongSelf resizedImageFromImage:newImage];
        
        // Sending attachment to the dialog.
        dispatch_async(dispatch_get_main_queue(), ^{
            [[ServicesManager instance].chatService sendAttachmentMessage:message
                                                                 toDialog:strongSelf.dialog
                                                      withAttachmentImage:resizedImage
                                                               completion:^(NSError *error) {
                                                                   
                                                                   [strongSelf.attachmentCells removeObjectForKey:message.ID];
                                                                   
                                                                   if (error != nil) {
                                                                       [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                                                                       
                                                                       // perform local attachment deleting
                                                                       [[ServicesManager instance].chatService deleteMessageLocally:message];
                                                                       [strongSelf.chatSectionManager deleteMessage:message];
                                                                   }
                                                               }];
        });
    });
}

- (UIImage *)resizedImageFromImage:(UIImage *)image {
    
    CGFloat largestSide = image.size.width > image.size.height ? image.size.width : image.size.height;
    CGFloat scaleCoefficient = largestSide / 560.0f;
    CGSize newSize = CGSizeMake(image.size.width / scaleCoefficient, image.size.height / scaleCoefficient);
    
    UIGraphicsBeginImageContext(newSize);
    
    [image drawInRect:(CGRect){0, 0, newSize.width, newSize.height}];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resizedImage;
}

@end
