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
#import "QMMessageNotificationManager.h"

#import "NSString+EMOEmoji.h"

#import <SafariServices/SFSafariViewController.h>

#import "UIAlertView+Blocks.h"

#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

static const NSUInteger widthPadding = 40.0f;

static const NSUInteger maxCharactersNumber = 1024; // 0 - unlimited

@interface ChatViewController ()
<
QMChatServiceDelegate,
UITextViewDelegate,
QMChatConnectionDelegate,
QMChatAttachmentServiceDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
UIActionSheetDelegate,
QMChatCellDelegate,
UIAlertViewDelegate,
QMDeferredQueueManagerDelegate
>

@property (nonatomic, weak) QBUUser *opponentUser;
@property (nonatomic, strong) MessageStatusStringBuilder *stringBuilder;
@property (nonatomic, strong) NSMapTable *attachmentCells;
@property (nonatomic, readonly) UIImagePickerController *pickerController;
@property (nonatomic, strong) NSTimer *typingTimer;
@property (nonatomic, strong) id observerWillResignActive;

@property (nonatomic, strong) NSArray QB_GENERIC(QBChatMessage *) *unreadMessages;

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
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.inputToolbar.contentView.backgroundColor = [UIColor whiteColor];
    self.inputToolbar.contentView.textView.placeHolder = NSLocalizedString(@"SA_STR_MESSAGE_PLACEHOLDER", nil);
    
    self.attachmentCells = [NSMapTable strongToWeakObjectsMapTable];
    self.stringBuilder = [MessageStatusStringBuilder new];
    self.detailedCells = [NSMutableSet set];
    
    self.enableTextCheckingTypes = NSTextCheckingAllTypes;
    
    [self updateTitle];
    
    if (self.dialog.type == QBChatDialogTypePrivate) {
        
        // Handling 'typing' status.
        __weak typeof(self)weakSelf = self;
        [self.dialog setOnUserIsTyping:^(NSUInteger userID) {
            
            __typeof(weakSelf)strongSelf = weakSelf;
            if ([QBSession currentSession].currentUser.ID == userID) {
                return;
            }
            strongSelf.title = NSLocalizedString(@"SA_STR_TYPING", nil);
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
    [[self queueManager] addDelegate:self];
    
    if ([[self storedMessages] count] > 0 && self.chatDataSource.messagesCount == 0) {
        //inserting all messages from memory storage
        [self.chatDataSource addMessages:[self storedMessages]];
    }
    
    [self refreshMessagesShowingProgress:NO];
}

- (void)refreshMessagesShowingProgress:(BOOL)showingProgress {
    
    if (showingProgress) {
        [SVProgressHUD showWithStatus:NSLocalizedString(@"SA_STR_LOADING_MESSAGES", nil) maskType:SVProgressHUDMaskTypeNone];
    }
    
    __weak __typeof(self)weakSelf = self;
	
	// Retrieving messages from Quickblox REST history and cache.
    [[ServicesManager instance].chatService messagesWithChatDialogID:self.dialog.ID completion:^(QBResponse *response, NSArray *messages) {
        if (response.success) {
			
			if ([messages count] > 0) {
				[weakSelf.chatDataSource addMessages:messages];
			}
            [SVProgressHUD dismiss];
            
        } else {
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"SA_STR_ERROR", nil)];
            NSLog(@"can not refresh messages: %@", response.error.error);
        }
    }];
}

- (void)deferredQueueManager:(QMDeferredQueueManager*)queueManager didAddMessageLocally:(QBChatMessage*)addedMessage {
    [self.chatDataSource addMessage:addedMessage];
}

- (void)deferredQueueManager:(QMDeferredQueueManager*)queueManager didUpdateMessageLocally:(nonnull QBChatMessage *)addedMessage {
    [self.chatDataSource updateMessage:addedMessage];
}

- (NSArray *)storedMessages {
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
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
       withTextAttachments:(NSArray*)textAttachments
                  senderId:(NSUInteger)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date {
    
    NSTextAttachment * attachment = textAttachments.firstObject;
    
    if (attachment.image) {
        
        QBChatMessage *message = [QBChatMessage new];
        message.senderID = self.senderID;
        message.dialogID = self.dialog.ID;
        message.dateSent = [NSDate date];
        
        [[ServicesManager instance].chatService sendAttachmentMessage:message
                                                             toDialog:self.dialog
                                                  withAttachmentImage:attachment.image
                                                           completion:^(NSError *error) {
                                                               
                                                               [self.attachmentCells removeObjectForKey:message.ID];
                                                               
                                                               if (error != nil) {
                                                                   [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                                                                   
                                                                   // perform local attachment deleting
                                                                   [[ServicesManager instance].chatService deleteMessageLocally:message];
                                                                   [self.chatDataSource deleteMessage:message];
                                                               }
                                                           }];
        [self finishSendingMessageAnimated:YES];
    }
    
}


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
            NSString * title  = NSLocalizedString(@"SA_STR_ERROR", nil);
            NSString * subtitle = error.localizedDescription;
            UIImage *iconImage = [UIImage imageNamed:@"icon-error"];
            UIColor *backgroundColor = [UIColor colorWithRed:241.0/255.0 green:196.0/255.0 blue:15.0/255.0 alpha:1.0];
            
            [QMMessageNotificationManager showNotificationWithTitle:title
                                                           subtitle:subtitle
                                                              color:backgroundColor
                                                          iconImage:iconImage];
        }
    }];
    
    [self finishSendingMessageAnimated:YES];
}

#pragma mark - Cell classes

- (Class)viewClassForItem:(QBChatMessage *)item {
    
    if (item.isNotificatonMessage || item.isDateDividerMessage) {
        
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
    
    if (messageItem.isNotificatonMessage || messageItem.isDateDividerMessage) {
        textColor =  [UIColor blackColor];
    }
    else {
       textColor = [messageItem senderID] == self.senderID ? [UIColor whiteColor] : [UIColor blackColor];
    }
    
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:17.0f] ;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineHeightMultiple = 1.0;
    paragraphStyle.minimumLineHeight = font.lineHeight;
    paragraphStyle.maximumLineHeight = font.lineHeight;
    
    NSDictionary *attributes = @{ NSForegroundColorAttributeName:textColor,
                                  NSFontAttributeName:font,
                                  NSParagraphStyleAttributeName: paragraphStyle};
    
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
    
    UIFont *font = [UIFont systemFontOfSize:13.0f];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    paragraphStyle.minimumLineHeight = font.lineHeight;
    paragraphStyle.maximumLineHeight = font.lineHeight;
    
    NSDictionary *attributes = @{ NSForegroundColorAttributeName:textColor,
                                  NSFontAttributeName:font,
                                  NSParagraphStyleAttributeName: paragraphStyle};
    
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
    
    QBChatMessage *item = [self.chatDataSource messageForIndexPath:indexPath];
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
    
    QBChatMessage *item = [self.chatDataSource messageForIndexPath:indexPath];
    
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
    
    QBChatMessage *item = [self.chatDataSource messageForIndexPath:indexPath];
    Class viewClass = [self viewClassForItem:item];
    
    if (viewClass == [QMChatNotificationCell class]
        || viewClass == [QMChatContactRequestCell class]){
        
        return NO;
    }
    
    return [super collectionView:collectionView canPerformAction:action forItemAtIndexPath:indexPath withSender:sender];
}

/**
 * Allows to perform copy action for QMChatIncomingCell and QMChatOutgoingCell
 */
- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    
    if (action == @selector(copy:)) {
        
        QBChatMessage *message = [self.chatDataSource messageForIndexPath:indexPath];
        
        if ([message isMediaMessage]) {
           
            	[[ServicesManager instance].chatService.chatAttachmentService localImageForAttachmentMessage:message completion:^(NSError *error, UIImage *image) {
                    if (image) {
                        
                        [[UIPasteboard generalPasteboard] setValue:UIImageJPEGRepresentation(image, 1)
                                                 forPasteboardType:(NSString *)kUTTypeJPEG];
                    }
                }];
            
            }
         else {
            [[UIPasteboard generalPasteboard] setString:message.text];
        }
    }
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
    
    QBChatMessage *item = [self.chatDataSource messageForIndexPath:indexPath];
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
    
    
    QBChatMessage *message = [self.chatDataSource messageForIndexPath:indexPath];
    
    if ([cell isKindOfClass:[QMChatOutgoingCell class]]) {
        
        QMMessageStatus status = [[self queueManager] statusForMessage:message];
        
        switch (status) {
            case QMMessageStatusSent: {
                [chatCell containerView].bgColor = [UIColor colorWithRed:0 green:121.0f/255.0f blue:1 alpha:1.0f];
                break;
            }
            case QMMessageStatusSending: {
                [chatCell containerView].bgColor = [UIColor colorWithRed:0.761 green:0.772 blue:0.746 alpha:1.000];
                break;
            }
            case QMMessageStatusNotSent: {
                [chatCell containerView].bgColor = [UIColor colorWithRed:1.000 green:0.190 blue:0.108 alpha:1.000];
                break;
            }
        }
    }
    else if ([cell isKindOfClass:[QMChatAttachmentOutgoingCell class]]) {
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
	[[ServicesManager instance].chatService.chatAttachmentService imageForAttachmentMessage:message completion:^(NSError *error, UIImage *image) {
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
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)__unused cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.item == [self.collectionView numberOfItemsInSection:0] - 1) {
        // the very first message
        // load more if exists
        __weak typeof(self)weakSelf = self;
        // Getting earlier messages for chat dialog identifier.
        [[[ServicesManager instance].chatService loadEarlierMessagesWithChatDialogID:self.dialog.ID] continueWithBlock:^id(BFTask *task) {
            
            if ([task.result count] > 0) {
                [weakSelf.chatDataSource addMessages:task.result];
            }
            
            return nil;
        }];
    }
    
    // marking message as read if needed
    QBChatMessage *itemMessage = [self.chatDataSource messageForIndexPath:indexPath];
     [self sendReadStatusForMessage:itemMessage];
}


#pragma mark - QMChatCellDelegate

- (void)chatCellDidTapContainer:(QMChatCell *)cell {
    
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    QBChatMessage *currentMessage = [self.chatDataSource messageForIndexPath:indexPath];
    
    QMMessageStatus status = [[self queueManager] statusForMessage:currentMessage];
    
    if (status == QMMessageStatusNotSent && currentMessage.senderID == self.senderID)
    {
        
        [self handleNotSentMessage:currentMessage];
        return;
    }

    if ([self.detailedCells containsObject:currentMessage.ID]) {
        [self.detailedCells removeObject:currentMessage.ID];
    } else {
        [self.detailedCells addObject:currentMessage.ID];
    }
    
    [self.collectionView.collectionViewLayout removeSizeFromCacheForItemID:currentMessage.ID];
    [self.collectionView performBatchUpdates:nil completion:nil];
}

- (void)chatCell:(QMChatCell *)__unused cell didTapOnTextCheckingResult:(NSTextCheckingResult *)textCheckingResult {
    
    switch (textCheckingResult.resultType) {
            
        case NSTextCheckingTypeLink: {
            
            if ([SFSafariViewController class] != nil &&
                // SFSafariViewController supporting only http and https schemes
                 ([textCheckingResult.URL.scheme.lowercaseString isEqualToString:@"http"]
                    || [textCheckingResult.URL.scheme.lowercaseString isEqualToString:@"https"])) {
                
                SFSafariViewController *controller = [[SFSafariViewController alloc] initWithURL:textCheckingResult.URL entersReaderIfAvailable:false];
                [self presentViewController:controller animated:true completion:nil];
                
            }
            else {
                
                if ([[UIApplication sharedApplication] canOpenURL:textCheckingResult.URL]) {
                    
                    [[UIApplication sharedApplication] openURL:textCheckingResult.URL];
                }
            }
            
            break;
        }
            
        case NSTextCheckingTypePhoneNumber: {
            

            if (![self canMakeACall]) {
                [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"Your Device can't make a phone call", nil) maskType:SVProgressHUDMaskTypeNone];
                break;
            }
            
            NSString *urlString = [NSString stringWithFormat:@"tel:%@", textCheckingResult.phoneNumber];
            NSURL *url = [NSURL URLWithString:urlString];
            
            [self.view endEditing:YES];
            
            void (^callAction)(void) = ^ {
                
                [[UIApplication sharedApplication] openURL:url];
            };
            
            if ([UIAlertController class]) {
                UIAlertController *alertController = [UIAlertController
                                                      alertControllerWithTitle:nil
                                                      message:textCheckingResult.phoneNumber
                                                      preferredStyle:UIAlertControllerStyleAlert];
                
                [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"SA_STR_CANCEL", nil)
                                                                    style:UIAlertActionStyleCancel
                                                                  handler:^(UIAlertAction * _Nonnull __unused action) {
                                                                  }]];
                
                [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"SA_STR_CALL", nil)
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * _Nonnull __unused action) {
                                                                      
                                                                      callAction();
                                                                      
                                                                  }]];
                
                [self presentViewController:alertController animated:YES completion:nil];
            }
            else {
                
                [UIAlertView showWithTitle:@""
                                   message:textCheckingResult.phoneNumber
                         cancelButtonTitle:@"SA_STR_CANCEL"
                         otherButtonTitles:@[NSLocalizedString(@"SA_STR_CALL", nil)]
                                  tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                      if (buttonIndex == 0) {
                                          callAction();
                                      }
                                      
                                  }];
            }
            
            break;
        }
            
        default:
            break;
    }
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
        
        [self.chatDataSource addMessages:messages];
    }
}

- (void)chatService:(QMChatService *)chatService didAddMessageToMemoryStorage:(QBChatMessage *)message forDialogID:(NSString *)dialogID {
    
    if ([self.dialog.ID isEqualToString:dialogID]) {
        // Inserting message received from XMPP or self sent
        if ([self.chatDataSource messageExists:message]) {
             [self.chatDataSource updateMessage:message];
        }
        else {
             [self.chatDataSource addMessage:message];
        }
       
    }
}

- (void)chatService:(QMChatService *)chatService didUpdateChatDialogInMemoryStorage:(QBChatDialog *)chatDialog {
    
    if (self.dialog.type != QBChatDialogTypePrivate && [self.dialog.ID isEqualToString:chatDialog.ID]) {
        self.dialog  = chatDialog;
        self.title = self.dialog.name;
    }
}

- (void)chatService:(QMChatService *)chatService didUpdateMessage:(QBChatMessage *)message forDialogID:(NSString *)dialogID {
    
    if ([self.dialog.ID isEqualToString:dialogID] && message.senderID == self.senderID) {
        
        [self.chatDataSource updateMessage:message];
    }
}

- (void)chatService:(QMChatService *)chatService didUpdateMessages:(NSArray *)messages forDialogID:(NSString *)dialogID {
    
    if ([self.dialog.ID isEqualToString:dialogID]) {
        
        [self.chatDataSource updateMessages:messages];
    }
}

#pragma mark - QMChatConnectionDelegate

- (void)refreshAndReadMessages; {
    
    [self refreshMessagesShowingProgress:YES];
    
    if (self.unreadMessages.count > 0) {
        [self readMessages:self.unreadMessages];
    }
    
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
            
            [self.chatDataSource updateMessage:message];
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
        
        NSIndexPath *indexPath = [self.chatDataSource indexPathForMessage:message];
        cell = (UICollectionViewCell <QMChatAttachmentCell> *)[self.collectionView cellForItemAtIndexPath:indexPath];
        [self.attachmentCells setObject:cell forKey:message.ID];
    }
    
    if (cell != nil) {
        
        [cell updateLoadingProgress:progress];
    }
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    
    [super textViewDidChange:textView];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if ([((QMPlaceHolderTextView*)textView) hasTextAttachment]) {
        if (text.length == 0)
        {
            [((QMPlaceHolderTextView*)textView) setDefaultSettings];
            return YES;
        }
        return NO;
    }
    
    // Prevent crashing undo bug
    if(range.length + range.location > textView.text.length)
    {
        return NO;
    }
    
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
    
    if (maxCharactersNumber > 0) {

        if (textView.text.length >= maxCharactersNumber && text.length > 0) {
            [self showCharactersNumberError];
            return NO;
        }
        
        NSString * newText = [textView.text stringByReplacingCharactersInRange:range withString:text];
      
        if ([newText length] <= maxCharactersNumber || text.length == 0) {
            return YES;
        }
        

        NSInteger symbolsToCut = maxCharactersNumber - textView.text.length;
        
        NSRange stringRange = {0, MIN([text length], symbolsToCut)};
        
        // adjust the range to include dependent chars
        stringRange = [text rangeOfComposedCharacterSequencesForRange:stringRange];
        
        // Now you can create the short string
        NSString *shortString = [text substringWithRange:stringRange];
        
        NSMutableString * newtext = textView.text.mutableCopy;
        [newtext insertString:shortString atIndex:range.location];
        
        textView.text = newtext.copy;
       
        [self showCharactersNumberError];
        
        [self textViewDidChange:textView];
        
        return NO;
    }

    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [super textViewDidEndEditing:textView];
    
    [self fireStopTypingIfNecessary];
}

- (BOOL)placeHolderTextView:(QMPlaceHolderTextView *)textView shouldPasteWithSender:(id)sender {
    
    if ([UIPasteboard generalPasteboard].image) {
        
        /* Variant 1*/
        
        //        // If there's an image in the pasteboard, construct a message with that image and `send` it.
        //
        //        QBChatMessage *message = [QBChatMessage new];
        //        message.senderID = self.senderID;
        //        message.dialogID = self.dialog.ID;
        //        message.dateSent = [NSDate date];
        //
        //        [[ServicesManager instance].chatService sendAttachmentMessage:message
        //                                                             toDialog:self.dialog
        //                                                  withAttachmentImage:[UIPasteboard generalPasteboard].image
        //                                                           completion:^(NSError *error) {
        //
        //                                                               [self.attachmentCells removeObjectForKey:message.ID];
        //
        //                                                               if (error != nil) {
        //                                                                   [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        //
        //                                                                   // perform local attachment deleting
        //                                                                   [[ServicesManager instance].chatService deleteMessageLocally:message];
        //                                                                   [self.chatSectionManager deleteMessage:message];
        //                                                               }
        //                                                           }];
        
        /* Variant 2*/
        NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
        textAttachment.image = [UIPasteboard generalPasteboard].image;
        textAttachment.bounds = CGRectMake(0, 0, 100, 100);
        NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
        [self.inputToolbar.contentView.textView setAttributedText:attrStringWithImage];
        [self textViewDidChange:self.inputToolbar.contentView.textView];
        
        return NO;
    }
    return YES;
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
                                                                       [strongSelf.chatDataSource deleteMessage:message];
                                                                   }
                                                               }];
        });
    });
}


- (void)showCharactersNumberError {

        NSString * title  = NSLocalizedString(@"SA_STR_ERROR", nil);
        NSString * subtitle = [NSString stringWithFormat:@"The character limit is %lu. ", (unsigned long)maxCharactersNumber];
        
        [QMMessageNotificationManager showNotificationWithTitle:title
                                                       subtitle:subtitle
                                                           type:QMMessageNotificationTypeWarning];

}
- (BOOL)canMakeACall {
    BOOL canMakeACall = false;
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel://"]]) {
        // Check if iOS Device supports phone calls
        CTTelephonyNetworkInfo *netInfo = [[CTTelephonyNetworkInfo alloc] init];
        CTCarrier *carrier = [netInfo subscriberCellularProvider];
        NSString *mnc = [carrier mobileNetworkCode];
        // User will get an alert error when they will try to make a phone call in airplane mode.
        if (([mnc length] == 0)) {
            // Device cannot place a call at this time.  SIM might be removed.
        } else {
            // iOS Device is capable for making calls
            canMakeACall = true;
        }
    } else {
        // iOS Device is not capable for making calls
    }
    return canMakeACall;
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

- (void)handleNotSentMessage:(QBChatMessage*)notSentMessage {
    
    UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:@""
                                                                      message:NSLocalizedString(@"SA_STR_MESSAGE_FAILED_TO_SEND", nil)
                                                               preferredStyle:UIAlertControllerStyleActionSheet];
    
    
    UIAlertAction *resend = [UIAlertAction actionWithTitle:NSLocalizedString(@"SA_STR_TRY_AGAIN_MESSAGE", nil)
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action)
                             {
                                 [[self queueManager] perfromDefferedActionForMessage:notSentMessage withCompletion:nil];
                                 [alertVC dismissViewControllerAnimated:YES completion:nil];
                             }];
    
    UIAlertAction *delete = [UIAlertAction actionWithTitle:NSLocalizedString(@"SA_STR_DELETE_MESSAGE", nil)
                                                     style:UIAlertActionStyleDestructive
                                                   handler:^(UIAlertAction * action)
                             {
                                 [self.chatDataSource deleteMessage:notSentMessage];
                                 [[self queueManager] removeMessage:notSentMessage];
                                 
                                 [alertVC dismissViewControllerAnimated:YES completion:nil];
                             }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"SA_STR_CANCEL", nil)
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction * action)
                             {
                                 
                             }];
    
    [alertVC addAction:resend];
    [alertVC addAction:delete];
    [alertVC addAction:cancel];
    
    [self presentViewController:alertVC animated:YES completion:nil];
    
}

- (QMDeferredQueueManager *)queueManager {
    return [ServicesManager instance].chatService.deferredQueueManager;
}
@end
