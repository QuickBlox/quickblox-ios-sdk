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
#import "ServicesManager.h"

#import "LoginTableViewController.h"
#import "DialogsViewController.h"
#import "MessageStatusStringBuilder.h"

#import "QMChatAttachmentIncomingCell.h"
#import "QMChatAttachmentOutgoingCell.h"
#import "QMChatAttachmentCell.h"

#import "UIImage+fixOrientation.h"

#import "QMCollectionViewFlowLayoutInvalidationContext.h"

static const NSUInteger widthPadding = 40.0f;

@interface ChatViewController ()
<
QMChatServiceDelegate,
QMChatConnectionDelegate,
UITextViewDelegate,
QMChatAttachmentServiceDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
UIActionSheetDelegate
>

@property (nonatomic, weak) QBUUser* opponentUser;
@property (nonatomic, strong) id<NSObject> observerDidBecomeActive;
@property (nonatomic, strong) MessageStatusStringBuilder* stringBuilder;
@property (nonatomic, strong) NSMapTable* attachmentCells;
@property (nonatomic, readonly) UIImagePickerController* pickerController;
@property (nonatomic, assign) BOOL shouldHoldScrollOnCollectionView;
@property (nonatomic, strong) NSTimer* typingTimer;
@property (nonatomic, strong) id observerDidEnterBackground;

@property (nonatomic, strong) NSArray* unreadMessages;

@property (nonatomic, assign) BOOL shouldUpdateMessagesAfterLogIn;

@end

@implementation ChatViewController
@synthesize pickerController = _pickerController;

- (UIImagePickerController *)pickerController
{
    if (_pickerController == nil) {
        _pickerController = [UIImagePickerController new];
        _pickerController.delegate = self;
    }
    return _pickerController;
}

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

    self.attachmentCells = [NSMapTable strongToWeakObjectsMapTable];
        
    self.showLoadEarlierMessagesHeader = YES;
    
    [self updateTitle];
    
    self.stringBuilder = [MessageStatusStringBuilder new];
    
    // Retrieving messages from memory storage.
    self.items = [[[ServicesManager instance].chatService.messagesMemoryStorage messagesWithDialogID:self.dialog.ID] mutableCopy];
    
    QMCollectionViewFlowLayoutInvalidationContext* context = [QMCollectionViewFlowLayoutInvalidationContext context];
    context.invalidateFlowLayoutMessagesCache = YES;
    [self.collectionView.collectionViewLayout invalidateLayoutWithContext:context];

    [self refreshCollectionView];

    // Handling 'typing' status.
    __weak typeof(self)weakSelf = self;
    [self.dialog setOnUserIsTyping:^(NSUInteger userID) {
        __typeof(self) strongSelf = weakSelf;
        if ([QBSession currentSession].currentUser.ID == userID) {
            return;
        }
        strongSelf.title = @"typing...";
    }];

    // Handling user stopped typing.
    [self.dialog setOnUserStoppedTyping:^(NSUInteger userID) {
        __typeof(self) strongSelf = weakSelf;
        [strongSelf updateTitle];
    }];
}

- (void)refreshMessagesShowingProgress:(BOOL)showingProgress {
	
	if (showingProgress) {
		[SVProgressHUD showWithStatus:@"Refreshing..." maskType:SVProgressHUDMaskTypeClear];
	}
	
    // Retrieving message from Quickblox REST history and cache.
	[[ServicesManager instance].chatService messagesWithChatDialogID:self.dialog.ID completion:^(QBResponse *response, NSArray *messages) {        
		if (response.success) {
            if (showingProgress) {
                [SVProgressHUD dismiss];
            }
		} else {
			[SVProgressHUD showErrorWithStatus:@"Can not refresh messages"];
			NSLog(@"can not refresh messages: %@", response.error.error);
		}
	}];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[ServicesManager instance].chatService addDelegate:self];
    [ServicesManager instance].chatService.chatAttachmentService.delegate = self;
	
	__weak __typeof(self) weakSelf = self;
	self.observerDidBecomeActive = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
		__typeof(self) strongSelf = weakSelf;
        
        if ([[QBChat instance] isLoggedIn]) {
            [strongSelf refreshMessagesShowingProgress:NO];
        } else {
            strongSelf.shouldUpdateMessagesAfterLogIn = YES;
        }
	}];
    
    self.observerDidEnterBackground = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        __typeof(self) strongSelf = weakSelf;
        [strongSelf fireStopTypingIfNecessary];
    }];
    
    // Saving currently opened dialog.
    [ServicesManager instance].currentDialogID = self.dialog.ID;
    
    if ([self.items count] > 0) {
        [self refreshMessagesShowingProgress:NO];
    } else {
        [self refreshMessagesShowingProgress:YES];
    }
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
    
    [[ServicesManager instance].chatService removeDelegate:self];
	[[NSNotificationCenter defaultCenter] removeObserver:self.observerDidBecomeActive];
    [[NSNotificationCenter defaultCenter] removeObserver:self.observerDidEnterBackground];
    
    // Deletes typing blocks.
    [self.dialog clearTypingStatusBlocks];
    
    // Resetting currently opened dialog.
    [ServicesManager instance].currentDialogID = nil;
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
        QBUUser* opponentUser = [qbUsersMemoryStorage userWithID:[opponentID unsignedIntegerValue]];
        NSAssert(opponentUser, @"opponent must exists");
        self.opponentUser = opponentUser;
        self.title = self.opponentUser.fullName;
    } else {
        self.title = self.dialog.name;
    }
}

#pragma mark - Utilities

- (void)sendReadStatusForMessage:(QBChatMessage *)message
{
    if (message.senderID != [QBSession currentSession].currentUser.ID && ![message.readIDs containsObject:@(self.senderID)]) {
        message.markable = YES;
        // Sending read message status.
        if (![[QBChat instance] readMessage:message]) {
            NSLog(@"Problems while marking message as read!");
        }
    }
}

- (void)readMessages:(NSArray *)messages forDialogID:(NSString *)dialogID
{
    if ([QBChat instance].isLoggedIn) {
        for (QBChatMessage* message in messages) {
            [self sendReadStatusForMessage:message];
        }
    } else {
        self.unreadMessages = messages;
    }
}

- (void)fireStopTypingIfNecessary
{
    [self.typingTimer invalidate];
    self.typingTimer = nil;
    [self.dialog sendUserStoppedTyping];
}

#pragma mark Tool bar Actions

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSUInteger)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date
{
    if (self.typingTimer != nil) {
        [self fireStopTypingIfNecessary];
    }
    
    QBChatMessage *message = [QBChatMessage message];
    message.text = text;
    message.senderID = senderId;
    message.markable = YES;
    message.readIDs = @[@(self.senderID)];
    message.dialogID = self.dialog.ID;
    
    // Sending message.
    [[ServicesManager instance].chatService sendMessage:message toDialogId:self.dialog.ID save:YES completion:nil];
    [self finishSendingMessageAnimated:YES];
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
            if ((item.attachments != nil && item.attachments.count > 0) || item.attachmentStatus != QMMessageAttachmentStatusNotLoaded) {
                return [QMChatAttachmentIncomingCell class];
            } else {
                return [QMChatIncomingCell class];
            }
        } else {
            if ((item.attachments != nil && item.attachments.count > 0) || item.attachmentStatus != QMMessageAttachmentStatusNotLoaded) {
                return [QMChatAttachmentOutgoingCell class];
            } else {
                return [QMChatOutgoingCell class];
            }
        }
    }
    return nil;
}

#pragma mark - Strings builder

- (NSAttributedString *)attributedStringForItem:(QBChatMessage *)messageItem {
    
    UIColor *textColor = [messageItem senderID] == self.senderID ? [UIColor whiteColor] : [UIColor colorWithWhite:0.290 alpha:1.000];
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:15];
    NSDictionary *attributes = @{ NSForegroundColorAttributeName:textColor, NSFontAttributeName:font};
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:messageItem.text ? messageItem.text : @"" attributes:attributes];
    
    return attrStr;
}

- (NSAttributedString *)topLabelAttributedStringForItem:(QBChatMessage *)messageItem {
    
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:14];
    
    if ([messageItem senderID] == self.senderID) {
        return nil;
    }
    
    NSString *topLabelText = self.opponentUser.fullName != nil ? self.opponentUser.fullName : self.opponentUser.login;
    
    if (self.dialog.type != QBChatDialogTypePrivate) {
        QBUUser* user = [qbUsersMemoryStorage userWithID:self.senderID];
        topLabelText = (user != nil) ? user.login : [NSString stringWithFormat:@"%lu",(unsigned long)messageItem.senderID];
    }

    NSDictionary *attributes = @{ NSForegroundColorAttributeName:[UIColor colorWithRed:0.184 green:0.467 blue:0.733 alpha:1.000], NSFontAttributeName:font};
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:topLabelText attributes:attributes];
    
    return attrStr;
}

- (NSAttributedString *)bottomLabelAttributedStringForItem:(QBChatMessage *)messageItem {
    
    UIColor *textColor = [messageItem senderID] == self.senderID ? [UIColor colorWithWhite:1.000 alpha:0.510] : [UIColor colorWithWhite:0.000 alpha:0.490];
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:12];
    
    NSDictionary *attributes = @{ NSForegroundColorAttributeName:textColor, NSFontAttributeName:font};
    NSString* text = [self timeStampWithDate:messageItem.dateSent];
    if ([messageItem senderID] == self.senderID) {
        text = [NSString stringWithFormat:@"%@\n%@", text, [self.stringBuilder statusFromMessage:messageItem]];
    }
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:text
                                                                                attributes:attributes];
    
    return attrStr;
}

#pragma mark - Collection View Datasource

- (CGSize)collectionView:(QMChatCollectionView *)collectionView dynamicSizeAtIndexPath:(NSIndexPath *)indexPath maxWidth:(CGFloat)maxWidth {
    
    QBChatMessage *item = self.items[indexPath.item];
    Class viewClass = [self viewClassForItem:item];
    CGSize size = CGSizeZero;
    
    if (viewClass == [QMChatAttachmentIncomingCell class]) {
        size = CGSizeMake(MIN(200, maxWidth), 200);
    } else if(viewClass == [QMChatAttachmentOutgoingCell class]) {
        NSAttributedString *attributedString = [self bottomLabelAttributedStringForItem:item];
    
        CGSize bottomLabelSize = [TTTAttributedLabel sizeThatFitsAttributedString:attributedString
                                                                  withConstraints:CGSizeMake(MIN(200, maxWidth), CGFLOAT_MAX)
                                                           limitedToNumberOfLines:0];
        size = CGSizeMake(MIN(200, maxWidth), 200 + ceilf(bottomLabelSize.height));
    } else {
        NSAttributedString *attributedString = [self attributedStringForItem:item];
        
        size = [TTTAttributedLabel sizeThatFitsAttributedString:attributedString
                                                withConstraints:CGSizeMake(maxWidth, CGFLOAT_MAX)
                                         limitedToNumberOfLines:0];
    }
    
    return size;
}

- (CGFloat)collectionView:(QMChatCollectionView *)collectionView minWidthAtIndexPath:(NSIndexPath *)indexPath {
    
    QBChatMessage *item = self.items[indexPath.item];
    
    NSAttributedString *attributedString =
    [item senderID] == self.senderID ?  [self bottomLabelAttributedStringForItem:item] : [self topLabelAttributedStringForItem:item];
    
    CGSize size = [TTTAttributedLabel sizeThatFitsAttributedString:attributedString
                                                   withConstraints:CGSizeMake(CGRectGetWidth(self.collectionView.frame) - widthPadding, CGFLOAT_MAX)
                                            limitedToNumberOfLines:0];
    
    return size.width;
}

- (void)collectionView:(QMChatCollectionView *)collectionView header:(QMLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
    self.shouldHoldScrollOnCollectionView = YES;
    __weak typeof(self)weakSelf = self;
    // Getting earlier messages for chat dialog identifier.
    [[ServicesManager instance].chatService earlierMessagesWithChatDialogID:self.dialog.ID completion:^(QBResponse *response, NSArray *messages) {
        __typeof(self) strongSelf = weakSelf;
        
        strongSelf.shouldHoldScrollOnCollectionView = NO;
    }];
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    Class viewClass = [self viewClassForItem:self.items[indexPath.row]];
    if (viewClass == [QMChatAttachmentIncomingCell class] || viewClass == [QMChatAttachmentOutgoingCell class]) return NO;
    
    return [super collectionView:collectionView canPerformAction:action forItemAtIndexPath:indexPath withSender:sender];
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    QBChatMessage* message = self.items[indexPath.row];
    
    Class viewClass = [self viewClassForItem:self.items[indexPath.row]];
    
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

- (QMChatCellLayoutModel)collectionView:(QMChatCollectionView *)collectionView layoutModelAtIndexPath:(NSIndexPath *)indexPath {
    QMChatCellLayoutModel layoutModel = [super collectionView:collectionView layoutModelAtIndexPath:indexPath];
    
    if (self.dialog.type == QBChatDialogTypePrivate) {
        layoutModel.topLabelHeight = 0.0;
    }
    
    layoutModel.avatarSize = (CGSize){0.0, 0.0};
    
    QBChatMessage* item = self.items[indexPath.row];
    Class class = [self viewClassForItem:item];
    
    if (class == [QMChatOutgoingCell class] || class == [QMChatAttachmentOutgoingCell class]) {
        NSAttributedString* bottomAttributedString = [self bottomLabelAttributedStringForItem:item];
        CGSize size = [TTTAttributedLabel sizeThatFitsAttributedString:bottomAttributedString
                                                       withConstraints:CGSizeMake(CGRectGetWidth(self.collectionView.frame) - widthPadding, CGFLOAT_MAX)
                                                limitedToNumberOfLines:0];
        
        layoutModel.bottomLabelHeight = ceilf(size.height);
    }
    
    return layoutModel;
}

- (void)collectionView:(QMChatCollectionView *)collectionView configureCell:(UICollectionViewCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    [super collectionView:collectionView configureCell:cell forIndexPath:indexPath];
    
    if ([cell conformsToProtocol:@protocol(QMChatAttachmentCell)]) {
        QBChatMessage* message = self.items[indexPath.row];
        if (message.attachments != nil) {
            QBChatAttachment* attachment = message.attachments.firstObject;
            
            BOOL shouldLoadFile = YES;
            if ([self.attachmentCells objectForKey:attachment.ID] != nil) {
                shouldLoadFile = NO;
            }
            
            NSMutableArray* keysToRemove = [NSMutableArray array];
            
            NSEnumerator* enumerator = [self.attachmentCells keyEnumerator];
            NSString* existingAttachmentID = nil;
            while (existingAttachmentID = [enumerator nextObject]) {
                UICollectionViewCell* cachedCell = [self.attachmentCells objectForKey:existingAttachmentID];
                if ([cachedCell isEqual:cell]) {
                    [keysToRemove addObject:existingAttachmentID];
                }
            }
            
            for (NSString* key in keysToRemove) {
                [self.attachmentCells removeObjectForKey:key];
            }
            
            [self.attachmentCells setObject:cell forKey:attachment.ID];
            [(UICollectionViewCell<QMChatAttachmentCell> *)cell setAttachmentID:attachment.ID];
            
            if (!shouldLoadFile) return;
            
            __weak typeof(self)weakSelf = self;
            // Getting image from chat attachment service.
            [[ServicesManager instance].chatService.chatAttachmentService getImageForChatAttachment:attachment completion:^(NSError *error, UIImage *image) {
                __typeof(self) strongSelf = weakSelf;
                
                if ([(UICollectionViewCell<QMChatAttachmentCell> *)cell attachmentID] != attachment.ID) return;
                
                [strongSelf.attachmentCells removeObjectForKey:attachment.ID];
                
                if (error != nil) {
                    [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                } else {
                    if (image != nil) {
                        [(UICollectionViewCell<QMChatAttachmentCell> *)cell setAttachmentImage:image];
                        [cell updateConstraints];
                    }
                }
            }];
        }
    }
}

#pragma mark - QMChatServiceDelegate

- (void)chatService:(QMChatService *)chatService didAddMessageToMemoryStorage:(QBChatMessage *)message forDialogID:(NSString *)dialogID {
    if ([self.dialog.ID isEqualToString:dialogID]) {
        // Retrieving messages from memory strorage.
        self.items = [[chatService.messagesMemoryStorage messagesWithDialogID:dialogID] mutableCopy];
        [self refreshCollectionView];
        
        [self sendReadStatusForMessage:message];
    }
}

- (void)chatService:(QMChatService *)chatService didAddMessagesToMemoryStorage:(NSArray *)messages forDialogID:(NSString *)dialogID
{
    if ([self.dialog.ID isEqualToString:dialogID]) {
        [self readMessages:messages forDialogID:dialogID];
        self.items = [[chatService.messagesMemoryStorage messagesWithDialogID:dialogID] mutableCopy];
        
        if (self.shouldHoldScrollOnCollectionView) {
            CGFloat bottomOffset = self.collectionView.contentSize.height - self.collectionView.contentOffset.y;
            [CATransaction begin];
            [CATransaction setDisableActions:YES];
            
            [self.collectionView reloadData];
            [self.collectionView performBatchUpdates:nil completion:nil];
            
            self.collectionView.contentOffset = (CGPoint){0, self.collectionView.contentSize.height - bottomOffset};
            
            [CATransaction commit];
        } else {
            [self refreshCollectionView];
        }
    }
}


- (void)chatService:(QMChatService *)chatService didUpdateChatDialogInMemoryStorage:(QBChatDialog *)chatDialog{
	if( [self.dialog.ID isEqualToString:chatDialog.ID] ) {
		self.dialog = chatDialog;
	}
}

- (void)chatService:(QMChatService *)chatService didUpdateMessage:(QBChatMessage *)message forDialogID:(NSString *)dialogID
{
    if ([self.dialog.ID isEqualToString:dialogID]) {        
        self.items = [[chatService.messagesMemoryStorage messagesWithDialogID:dialogID] mutableCopy];
        NSUInteger index = [self.items indexOfObject:message];
        if (index != NSNotFound) {
            QMCollectionViewFlowLayoutInvalidationContext* context = [QMCollectionViewFlowLayoutInvalidationContext context];
            context.invalidateFlowLayoutMessagesCache = YES;
            [self.collectionView.collectionViewLayout invalidateLayoutWithContext:context];
            [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]];
        }
    }
}

#pragma mark - QMChatConnectionDelegate

- (void)chatServiceChatDidConnect:(QMChatService *)chatService
{
    [SVProgressHUD showSuccessWithStatus:@"Chat connected!" maskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD showWithStatus:@"Logging in to chat..." maskType:SVProgressHUDMaskTypeClear];
}

- (void)chatServiceChatDidReconnect:(QMChatService *)chatService
{
    [SVProgressHUD showSuccessWithStatus:@"Chat reconnected!" maskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD showWithStatus:@"Logging in to chat..." maskType:SVProgressHUDMaskTypeClear];
}

- (void)chatServiceChatDidAccidentallyDisconnect:(QMChatService *)chatService
{
    [SVProgressHUD showErrorWithStatus:@"Chat disconnected!"];
}

- (void)chatServiceChatDidLogin
{
    [SVProgressHUD showSuccessWithStatus:@"Logged in!"];
    
    for (QBChatMessage* message in self.unreadMessages) {
        [self sendReadStatusForMessage:message];
    }
    
    self.unreadMessages = nil;
    
    if (self.shouldUpdateMessagesAfterLogIn) {
        
        self.shouldUpdateMessagesAfterLogIn = NO;
        
        [self refreshMessagesShowingProgress:NO];
    }
}

- (void)chatServiceChatDidNotLoginWithError:(NSError *)error
{
    [SVProgressHUD showErrorWithStatus:@"Unable to login to chat!"];
}

- (void)chatServiceChatDidFailWithStreamError:(NSError *)error
{
    [SVProgressHUD showErrorWithStatus:@"Chat error occured!"];
}

#pragma mark - QMChatAttachmentServiceDelegate

- (void)chatAttachmentService:(QMChatAttachmentService *)chatAttachmentService didChangeAttachmentStatus:(QMMessageAttachmentStatus)status forMessage:(QBChatMessage *)message
{
    if (message.dialogID == self.dialog.ID) {
        // Retrieving messages for dialog from memory storage.
        self.items = [[[ServicesManager instance].chatService.messagesMemoryStorage messagesWithDialogID:self.dialog.ID] mutableCopy];
        [self refreshCollectionView];
    }
}

- (void)chatAttachmentService:(QMChatAttachmentService *)chatAttachmentService didChangeLoadingProgress:(CGFloat)progress forChatAttachment:(QBChatAttachment *)attachment
{
    UICollectionViewCell<QMChatAttachmentCell>* cell = [self.attachmentCells objectForKey:attachment.ID];
    if (cell != nil) {
        [cell updateLoadingProgress:progress];
    }
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (self.typingTimer) {
        [self.typingTimer invalidate];
        self.typingTimer = nil;
    } else {
        [self.dialog sendUserIsTyping];
    }
    
    self.typingTimer = [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(fireStopTypingIfNecessary) userInfo:nil repeats:NO];
    
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [super textViewDidEndEditing:textView];
    
    [self fireStopTypingIfNecessary];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)didPickAttachmentImage:(UIImage *)image
{
    [SVProgressHUD showWithStatus:@"Uploading attachment" maskType:SVProgressHUDMaskTypeClear];
    
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __typeof(self) strongSelf = weakSelf;
        UIImage* newImage = image;
        if (strongSelf.pickerController.sourceType == UIImagePickerControllerSourceTypeCamera) {
            newImage = [newImage fixOrientation];
        }
        
        UIImage* resizedImage = [strongSelf resizedImageFromImage:newImage];
        
        QBChatMessage* message = [QBChatMessage new];
        message.senderID = strongSelf.senderID;
        message.dialogID = strongSelf.dialog.ID;
        
        // Sending attachment to dialog.
        [[ServicesManager instance].chatService.chatAttachmentService sendMessage:message
                                                                         toDialog:strongSelf.dialog
                                                                  withChatService:[ServicesManager instance].chatService
                                                                withAttachedImage:resizedImage completion:^(NSError *error) {
                                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                                          if (error != nil) {
                                                                              [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                                                                          } else {
                                                                              [SVProgressHUD showSuccessWithStatus:@"Completed"];
                                                                          }
                                                                      });
                                                                  }];
    });
}

- (UIImage *)resizedImageFromImage:(UIImage *)image
{
    CGFloat largestSide = image.size.width > image.size.height ? image.size.width : image.size.height;
    CGFloat scaleCoefficient = largestSide / 560.0f;
    CGSize newSize = CGSizeMake(image.size.width / scaleCoefficient, image.size.height / scaleCoefficient);
    
    UIGraphicsBeginImageContext(newSize);
    
    [image drawInRect:(CGRect){0, 0, newSize.width, newSize.height}];
    UIImage* resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resizedImage;
}

@end

