//
//  ChatViewController.m
//  sample-chat
//
//  Created by Andrey Moskvin on 6/9/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import "ChatViewController.h"
#import "DialogInfoTableViewController.h"

#import <UIColor+QM.h>
#import <UIImage+QM.h>

#import <TTTAttributedLabel/TTTAttributedLabel.h>
#import "ServicesManager.h"

#import "LoginTableViewController.h"
#import "DialogsViewController.h"
#import "MessageStatusStringBuilder.h"

#import "UIImage+fixOrientation.h"

#import <QMCollectionViewFlowLayoutInvalidationContext.h>

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

@property (nonatomic, assign) BOOL isSendingAttachment;

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

- (NSTimeInterval)timeIntervalBetweenSections {
    return 300.0f;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.inputToolbar.contentView.backgroundColor = [UIColor whiteColor];
    self.inputToolbar.contentView.textView.placeHolder = @"Message";
    
    self.attachmentCells = [NSMapTable strongToWeakObjectsMapTable];
    
    [self updateTitle];
    
    self.stringBuilder = [MessageStatusStringBuilder new];
    
    // Retrieving messages from memory storage.
//    self.items = [[[ServicesManager instance].chatService.messagesMemoryStorage messagesWithDialogID:self.dialog.ID] mutableCopy];
//    [self addMessages:[[ServicesManager instance].chatService.messagesMemoryStorage messagesWithDialogID:self.dialog.ID]];
    NSArray *chatDialogMessages = [[ServicesManager instance].chatService.messagesMemoryStorage messagesWithDialogID:self.dialog.ID];
    if (chatDialogMessages != nil) {
        [self insertMessagesToTheBottomAnimated:chatDialogMessages];
    }
    
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
    
    if (!self.dialog.isJoined) [self.dialog joinWithCompletionBlock:nil];
}

- (void)refreshMessagesShowingProgress:(BOOL)showingProgress {
	
	if (showingProgress && !self.isSendingAttachment) {
        [SVProgressHUD showWithStatus:@"Refreshing..." maskType:SVProgressHUDMaskTypeClear];
	}
	
    // Retrieving message from Quickblox REST history and cache.
	[[ServicesManager instance].chatService messagesWithChatDialogID:self.dialog.ID completion:^(QBResponse *response, NSArray *messages) {        
		if (response.success) {
            
            [self insertMessagesToTheBottomAnimated:messages];
            
            if (showingProgress && !self.isSendingAttachment) {
                [SVProgressHUD dismiss];
            }
            [SVProgressHUD dismiss];
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
        
        if ([[QBChat instance] isConnected]) {
            [strongSelf refreshMessagesShowingProgress:NO];
        }
	}];
    
    self.observerDidEnterBackground = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        __typeof(self) strongSelf = weakSelf;
        [strongSelf fireStopTypingIfNecessary];
    }];
    
    // Saving currently opened dialog.
    [ServicesManager instance].currentDialogID = self.dialog.ID;
    
//    if ([self.items count] > 0) {
//        [self refreshMessagesShowingProgress:NO];
//    }
//    else {
//        [self refreshMessagesShowingProgress:YES];
//    }
    [self refreshMessagesShowingProgress:NO];
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
        QBUUser* opponentUser = [[ServicesManager instance].usersService.usersMemoryStorage userWithID:[opponentID unsignedIntegerValue]];
        NSAssert(opponentUser, @"opponent must exists");
        self.opponentUser = opponentUser;
        self.title = self.opponentUser.fullName;
    } else {
        self.title = self.dialog.name;
    }
}

#pragma mark - Utilities

- (void)sendReadStatusForMessage:(QBChatMessage *)message forDialogID:(NSString *)dialogID
{
    if (message.senderID != [QBSession currentSession].currentUser.ID && ![message.readIDs containsObject:@(self.senderID)]) {
        [[ServicesManager instance].chatService readMessage:message completion:^(NSError * _Nullable error) {
            //
            if (error != nil) {
                NSLog(@"Problems while marking message as read! Error: %@", error);
            }
            else {
                if ([UIApplication sharedApplication].applicationIconBadgeNumber > 0) {
                    [UIApplication sharedApplication].applicationIconBadgeNumber--;
                }
            }
        }];
    }
}

- (void)readMessages:(NSArray *)messages forDialogID:(NSString *)dialogID
{
    if ([QBChat instance].isConnected) {
        [[ServicesManager instance].chatService readMessages:messages forDialogID:dialogID completion:^(NSError * _Nullable error) {
            //
        }];
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
    message.deliveredIDs = @[@(self.senderID)];
    message.readIDs = @[@(self.senderID)];
    message.dialogID = self.dialog.ID;
    message.dateSent = date;
    
    // Sending message.
    __weak __typeof(self)weakSelf = self;
    [[ServicesManager instance].chatService sendMessage:message toDialogID:self.dialog.ID saveToHistory:YES saveToStorage:YES completion:^(NSError *error, QBChatMessage *sentMessage) {
        //
        if (error != nil) {
            NSLog(@"Failed to send message with error: %@", error);
            [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Error" description:error.localizedRecoverySuggestion type:TWMessageBarMessageTypeError];
        } else {
            [weakSelf insertMessageToTheBottomAnimated:sentMessage];
        }
    }];
    
    // Custom push sending (uncomment sendPushWithText method and line below)
//    [self sendPushWithText:text];
    
    [self finishSendingMessageAnimated:YES];
    
}

/**
 *  If you want to send custom push notifications.
 *  uncomment methods bellow.
 *  By default push messages are disabled in admin panel.
 *  (you can change settings in admin panel -> Chat -> Alert)
 */

//#pragma mark - Custom push notifications
//
//- (void)sendPushWithText: (NSString*)text {
//    NSString *pushMessage = [[[[self senderDisplayName] stringByAppendingString:@": "] stringByAppendingString:text] mutableCopy];
//    [self createEventWithMessage:pushMessage];
//}
//
//- (void)sendPushWithAttachment {
//    NSString *pushMessage = [[[self senderDisplayName] stringByAppendingString:@" sent attachment."] mutableCopy];
//    [self createEventWithMessage:pushMessage];
//}
//
//- (void)createEventWithMessage: (NSString *)message {
//    // removing current user from occupantIDs
//    NSMutableArray *occupantsWithoutCurrentUser = [NSMutableArray array];
//    for (NSNumber *identifier in self.dialog.occupantIDs) {
//        if (![identifier isEqualToNumber:@(ServicesManager.instance.currentUser.ID)]) {
//            [occupantsWithoutCurrentUser addObject:identifier];
//        }
//    }
//    
//    // Sending push with event
//    QBMEvent *event = [QBMEvent event];
//    event.notificationType = QBMNotificationTypePush;
//    event.usersIDs = [occupantsWithoutCurrentUser componentsJoinedByString:@","];
//    event.type = QBMEventTypeOneShot;
//    //
//    // custom params
//    NSDictionary  *dictPush = @{kPushNotificationDialogMessageKey : message,
//                                kPushNotificationDialogIdentifierKey : self.dialog.ID
//                                };
//    //
//    NSError *error = nil;
//    NSData *sendData = [NSJSONSerialization dataWithJSONObject:dictPush options:NSJSONWritingPrettyPrinted error:&error];
//    NSString *jsonString = [[NSString alloc] initWithData:sendData encoding:NSUTF8StringEncoding];
//    //
//    event.message = jsonString;
//    
//    [QBRequest createEvent:event successBlock:^(QBResponse *response, NSArray *events) {
//        //
//    } errorBlock:^(QBResponse *response) {
//        //
//    }];
//}

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
    
    UIColor *textColor = [messageItem senderID] == self.senderID ? [UIColor whiteColor] : [UIColor blackColor];
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:17.0f] ;
    NSDictionary *attributes = @{ NSForegroundColorAttributeName:textColor, NSFontAttributeName:font};
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:messageItem.text ? messageItem.text : @"" attributes:attributes];
    
    return attrStr;
}

- (NSAttributedString *)topLabelAttributedStringForItem:(QBChatMessage *)messageItem {
    
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:17.0f];
    
    if ([messageItem senderID] == self.senderID) {
        return nil;
    }
    
    NSString *topLabelText = self.opponentUser.fullName != nil ? self.opponentUser.fullName : self.opponentUser.login;
    
    if (self.dialog.type != QBChatDialogTypePrivate) {
        QBUUser* user = [[ServicesManager instance].usersService.usersMemoryStorage userWithID:messageItem.senderID];
        topLabelText = (user != nil) ? user.login : [NSString stringWithFormat:@"%lu",(unsigned long)messageItem.senderID];
    }

    NSDictionary *attributes = @{ NSForegroundColorAttributeName:[UIColor colorWithRed:0 green:122.0f / 255.0f blue:1.0f alpha:1.000], NSFontAttributeName:font};
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:topLabelText attributes:attributes];
    
    return attrStr;
}

- (NSAttributedString *)bottomLabelAttributedStringForItem:(QBChatMessage *)messageItem {
    
    UIColor *textColor = [messageItem senderID] == self.senderID ? [UIColor colorWithWhite:1 alpha:0.7f] : [UIColor colorWithWhite:0.000 alpha:0.7f];
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:13.0f];
    
    NSDictionary *attributes = @{ NSForegroundColorAttributeName:textColor, NSFontAttributeName:font};
    NSString* text = messageItem.dateSent ? [self timeStampWithDate:messageItem.dateSent] : @"";
    if ([messageItem senderID] == self.senderID) {
        text = [NSString stringWithFormat:@"%@\n%@", text, [self.stringBuilder statusFromMessage:messageItem]];
    }
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:text
                                                                                attributes:attributes];
    
    return attrStr;
}

#pragma mark - Collection View Datasource

- (CGSize)collectionView:(QMChatCollectionView *)collectionView dynamicSizeAtIndexPath:(NSIndexPath *)indexPath maxWidth:(CGFloat)maxWidth {
    
    QBChatMessage *item = [self messageForIndexPath:indexPath];
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
    
    QBChatMessage *item = [self messageForIndexPath:indexPath];
    
    NSAttributedString *attributedString =
    [item senderID] == self.senderID ?  [self bottomLabelAttributedStringForItem:item] : [self topLabelAttributedStringForItem:item];
    
    CGSize size = [TTTAttributedLabel sizeThatFitsAttributedString:attributedString
                                                   withConstraints:CGSizeMake(CGRectGetWidth(self.collectionView.frame) - widthPadding, CGFLOAT_MAX)
                                            limitedToNumberOfLines:0];
    
    return size.width;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    Class viewClass = [self viewClassForItem:[self messageForIndexPath:indexPath]];
    if (viewClass == [QMChatAttachmentIncomingCell class] || viewClass == [QMChatAttachmentOutgoingCell class]) return NO;
    
    return [super collectionView:collectionView canPerformAction:action forItemAtIndexPath:indexPath withSender:sender];
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    QBChatMessage* message = [self messageForIndexPath:indexPath];
    
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

#pragma mark = QMChatCollectionViewDelegateFlowLayout

- (QMChatCellLayoutModel)collectionView:(QMChatCollectionView *)collectionView layoutModelAtIndexPath:(NSIndexPath *)indexPath {
    QMChatCellLayoutModel layoutModel = [super collectionView:collectionView layoutModelAtIndexPath:indexPath];
    
    layoutModel.avatarSize = (CGSize){0.0, 0.0};
    
    QBChatMessage *item = [self messageForIndexPath:indexPath];
    Class class = [self viewClassForItem:item];
    
    if (class == [QMChatOutgoingCell class] ||
        class == [QMChatAttachmentOutgoingCell class]) {
        layoutModel.topLabelHeight = 0.0;
        NSAttributedString* bottomAttributedString = [self bottomLabelAttributedStringForItem:item];
        CGSize size = [TTTAttributedLabel sizeThatFitsAttributedString:bottomAttributedString
                                                       withConstraints:CGSizeMake(CGRectGetWidth(self.collectionView.frame) - widthPadding, CGFLOAT_MAX)
                                                limitedToNumberOfLines:0];
        
        layoutModel.bottomLabelHeight = ceilf(size.height);
    } else if (class == [QMChatAttachmentIncomingCell class] ||
               class == [QMChatIncomingCell class]) {
        layoutModel.topLabelHeight = 20.0f;        
        layoutModel.spaceBetweenTopLabelAndTextView = 5.0f;
    }
    
    layoutModel.spaceBetweenTextViewAndBottomLabel = 5.0f;
    
    return layoutModel;
}

- (void)collectionView:(QMChatCollectionView *)collectionView configureCell:(UICollectionViewCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    [super collectionView:collectionView configureCell:cell forIndexPath:indexPath];

    [(QMChatCell *)cell containerView].highlightColor = [UIColor colorWithWhite:0.5 alpha:0.5];
    
    if ([cell isKindOfClass:[QMChatOutgoingCell class]] || [cell isKindOfClass:[QMChatAttachmentOutgoingCell class]]) {
        [(QMChatIncomingCell *)cell containerView].bgColor = [UIColor colorWithRed:0 green:121.0f/255.0f blue:1 alpha:1.0f];
    } else if ([cell isKindOfClass:[QMChatIncomingCell class]] || [cell isKindOfClass:[QMChatAttachmentIncomingCell class]]) {
        [(QMChatOutgoingCell *)cell containerView].bgColor = [UIColor colorWithRed:231.0f / 255.0f green:231.0f / 255.0f blue:231.0f / 255.0f alpha:1.0f];
    }
    
    if ([cell conformsToProtocol:@protocol(QMChatAttachmentCell)]) {
        QBChatMessage* message = [self messageForIndexPath:indexPath];
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

- (void)collectionViewHasReachedTop:(QMChatCollectionView *)collectionView {
    // load earlier messages
    
    self.shouldHoldScrollOnCollectionView = YES;
    __weak typeof(self)weakSelf = self;
    // Getting earlier messages for chat dialog identifier.
    [[[ServicesManager instance].chatService loadEarlierMessagesWithChatDialogID:self.dialog.ID] continueWithBlock:^id(BFTask<NSArray<QBChatMessage *> *> *task) {
        
        if (task.result.count > 0) {
            [weakSelf insertMessagesToTheTopAnimated:task.result];
            weakSelf.shouldHoldScrollOnCollectionView = NO;
        }
        return nil;
    }];
}

#pragma mark - QMChatServiceDelegate

- (void)chatService:(QMChatService *)chatService didAddMessageToMemoryStorage:(QBChatMessage *)message forDialogID:(NSString *)dialogID {
    if ([self.dialog.ID isEqualToString:dialogID]) {
        [self insertMessageToTheBottomAnimated:message];
        [self sendReadStatusForMessage:message forDialogID:self.dialog.ID];
    }
}
//
//- (void)chatService:(QMChatService *)chatService didAddMessagesToMemoryStorage:(NSArray *)messages forDialogID:(NSString *)dialogID
//{
//    if ([self.dialog.ID isEqualToString:dialogID]) {
//        [self readMessages:messages forDialogID:dialogID];
//        [self addMessages:messages];
////        self.items = [[chatService.messagesMemoryStorage messagesWithDialogID:dialogID] mutableCopy];
////        
////        if (self.shouldHoldScrollOnCollectionView) {
////            CGFloat bottomOffset = self.collectionView.contentSize.height - self.collectionView.contentOffset.y;
////            [CATransaction begin];
////            [CATransaction setDisableActions:YES];
////            [self.collectionView reloadData];
////            
//////            __weak __typeof(self)weakSelf = self;
//////            [self.collectionView performBatchUpdates:^{
//////                //
//////                __typeof(weakSelf)strongSelf = weakSelf;
//////                
//////                NSMutableArray *mutableArray = [NSMutableArray array];
//////                [mutableArray addObjectsFromArray:messages];
//////                [mutableArray addObjectsFromArray:strongSelf.items];
//////                
//////                strongSelf.items = [mutableArray mutableCopy];
//////                
//////                NSMutableArray *indexPaths = [NSMutableArray array];
//////                
////////                for (NSInteger i = messages.count - 1; i >= 0; i--) {
////////                    [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
////////                }
//////                for (QBChatMessage *message in [messages reverseObjectEnumerator]) {
//////                    [indexPaths addObject:[self indexPathForMessage:message]];
//////                }
//////                
//////                [strongSelf.collectionView insertSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 5)]];
//////                [strongSelf.collectionView insertItemsAtIndexPaths:indexPaths];
//////            } completion:^(BOOL finished) {
//////                //
//////                __typeof(weakSelf)strongSelf = weakSelf;
//////                strongSelf.collectionView.contentOffset = (CGPoint){0, strongSelf.collectionView.contentSize.height - bottomOffset};
//////                [CATransaction commit];
//////            }];
////
////            
////            [self.collectionView performBatchUpdates:^{
////                //
////            } completion:^(BOOL finished) {
////                //
////                self.collectionView.contentOffset = (CGPoint){0, self.collectionView.contentSize.height - bottomOffset};
////                [CATransaction commit];
////            }];
////        } else {
//////            self.items = [[chatService.messagesMemoryStorage messagesWithDialogID:dialogID] mutableCopy];
////            [self refreshCollectionView];
////        }
//    }
//}

- (void)chatService:(QMChatService *)chatService didUpdateChatDialogInMemoryStorage:(QBChatDialog *)chatDialog{
	if( [self.dialog.ID isEqualToString:chatDialog.ID] ) {
		self.dialog = chatDialog;
	}
}

- (void)chatService:(QMChatService *)chatService didUpdateMessage:(QBChatMessage *)message forDialogID:(NSString *)dialogID
{
    if ([self.dialog.ID isEqualToString:dialogID]) {
        QMCollectionViewFlowLayoutInvalidationContext* context = [QMCollectionViewFlowLayoutInvalidationContext context];
        context.invalidateFlowLayoutMessagesCache = YES;
        [self.collectionView.collectionViewLayout invalidateLayoutWithContext:context];
        
        [self.collectionView reloadItemsAtIndexPaths:@[[self updateMessage:message]]];
    }
}

#pragma mark - QMChatConnectionDelegate

- (void)refreshAndReadMessages;
{
    if (self.dialog.type != QBChatDialogTypePrivate) {
        [self refreshMessagesShowingProgress:YES];
    }
    
    for (QBChatMessage* message in self.unreadMessages) {
        [self sendReadStatusForMessage:message forDialogID:self.dialog.ID];
    }
    
    self.unreadMessages = nil;
}

- (void)chatServiceChatDidConnect:(QMChatService *)chatService
{
    [self refreshAndReadMessages];
}

- (void)chatServiceChatDidReconnect:(QMChatService *)chatService
{
    [self refreshAndReadMessages];
}

#pragma mark - QMChatAttachmentServiceDelegate

- (void)chatAttachmentService:(QMChatAttachmentService *)chatAttachmentService didChangeAttachmentStatus:(QMMessageAttachmentStatus)status forMessage:(QBChatMessage *)message
{
    if (message.dialogID == self.dialog.ID) {
        // Retrieving messages for dialog from memory storage.
//        self.items = [[[ServicesManager instance].chatService.messagesMemoryStorage messagesWithDialogID:self.dialog.ID] mutableCopy];
//        [self refreshCollectionView];
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
    self.isSendingAttachment = YES;
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
        message.dateSent = [NSDate date];
        
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
                                                                              // Custom push sending (uncomment sendPushWithAttachment method and line below)
//                                                                             [weakSelf sendPushWithAttachment];
                                                                          }
                                                                          weakSelf.isSendingAttachment = NO;
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

