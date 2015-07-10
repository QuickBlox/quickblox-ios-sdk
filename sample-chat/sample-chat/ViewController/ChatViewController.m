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
#import "MessageStatusStringBuilder.h"

#import "QMChatAttachmentIncomingCell.h"
#import "QMChatAttachmentOutgoingCell.h"
#import "QMChatAttachmentCell.h"

#import "UIImage+fixOrientation.h"

#import "QMCollectionViewFlowLayoutInvalidationContext.h"

@interface ChatViewController ()
<
QMChatServiceDelegate,
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
    
    self.inputToolbar.contentView.leftBarButtonItem = [self accessoryButtonItem];
    self.inputToolbar.contentView.rightBarButtonItem = [self sendButtonItem];
    
    self.showLoadEarlierMessagesHeader = YES;
    
    [self updateTitle];
    
    self.stringBuilder = [MessageStatusStringBuilder new];
    
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
	
    __weak typeof(self)weakSelf = self;
	[[QBServicesManager instance].chatService messagesWithChatDialogID:self.dialog.ID completion:^(QBResponse *response, NSArray *messages) {        
		if (response.success) {
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
    
    [[QBServicesManager instance].chatService addDelegate:self];
    [QBServicesManager instance].chatService.chatAttachmentService.delegate = self;
	
	__weak __typeof(self) weakSelf = self;
	self.observerDidBecomeActive = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
		__typeof(self) strongSelf = weakSelf;
		[strongSelf refreshMessagesShowingProgress:YES];
	}];
    
    self.observerDidEnterBackground = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        __typeof(self) strongSelf = weakSelf;
        [strongSelf fireStopTypingIfNecessary];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self.observerDidEnterBackground];
    
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

#pragma mark - Utilities

- (void)sendReadStatusForMessage:(QBChatMessage *)message
{
    if (message.senderID != [QBSession currentSession].currentUser.ID && ![message.readIDs containsObject:@(self.senderID)]) {
        message.markable = YES;
        if (![[QBChat instance] readMessage:message]) {
            NSLog(@"Problems while marking message as read!");
        }
    }
}

- (void)fireStopTypingIfNecessary
{
    [self.typingTimer invalidate];
    self.typingTimer = nil;
    [self.dialog sendUserStoppedTyping];
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
    [self fireStopTypingIfNecessary];
    
    QBChatMessage *message = [QBChatMessage message];
    message.text = text;
    message.senderID = senderId;
    message.markable = YES;
    message.readIDs = @[@(self.senderID)];
    message.dialogID = self.dialog.ID;
    
    [[QBServicesManager instance].chatService sendMessage:message toDialogId:self.dialog.ID save:YES completion:nil];
    [self finishSendingMessageAnimated:YES];
}

- (void)didPressAccessoryButton:(UIButton *)sender
{
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Photo Library", nil];
    [actionSheet showInView:self.view];
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
        QBUUser* user = [[StorageManager instance]userByID:self.senderID];
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
        text = [NSString stringWithFormat:@"%@ %@", [self.stringBuilder statusFromMessage:messageItem], text];
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
    
    if (viewClass == [QMChatAttachmentIncomingCell class] || viewClass == [QMChatAttachmentOutgoingCell class]) {
        size = CGSizeMake(MIN(200, maxWidth), 200);
    } else {
        NSAttributedString *attributedString = [self attributedStringForItem:item];
        
        size = [TTTAttributedLabel sizeThatFitsAttributedString:attributedString
                                                       withConstraints:CGSizeMake(maxWidth, MAXFLOAT)
                                                limitedToNumberOfLines:0];        
    }
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
    self.shouldHoldScrollOnCollectionView = YES;
    __weak typeof(self)weakSelf = self;
    [[QBServicesManager instance].chatService earlierMessagesWithChatDialogID:self.dialog.ID completion:^(QBResponse *response, NSArray *messages) {
        __typeof(self) strongSelf = weakSelf;
        
        strongSelf.shouldHoldScrollOnCollectionView = NO;
    }];
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
            [[QBServicesManager instance].chatService.chatAttachmentService getImageForChatAttachment:attachment completion:^(NSError *error, UIImage *image) {
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
        self.items = [[chatService.messagesMemoryStorage messagesWithDialogID:dialogID] mutableCopy];
        [self refreshCollectionView];
        
        [self sendReadStatusForMessage:message];
    }
}

- (void)chatService:(QMChatService *)chatService didAddMessagesToMemoryStorage:(NSArray *)messages forDialogID:(NSString *)dialogID
{
    if ([self.dialog.ID isEqualToString:dialogID]) {
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

#pragma mark - QMChatAttachmentServiceDelegate

- (void)chatAttachmentService:(QMChatAttachmentService *)chatAttachmentService didChangeAttachmentStatus:(QMMessageAttachmentStatus)status forMessage:(QBChatMessage *)message
{
    if (message.dialogID == self.dialog.ID) {
        self.items = [[[QBServicesManager instance].chatService.messagesMemoryStorage messagesWithDialogID:self.dialog.ID] mutableCopy];
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

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex  == 0) {
        self.pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:self.pickerController animated:YES completion:nil];
    } else if (buttonIndex == 1) {
        self.pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:self.pickerController animated:YES completion:nil];
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    [SVProgressHUD showWithStatus:@"Uploading attachment" maskType:SVProgressHUDMaskTypeClear];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage* image = info[UIImagePickerControllerOriginalImage];
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            image = [image fixOrientation];
        }
        
        UIImage* resizedImage = [self resizedImageFromImage:image];
        
        QBChatMessage* message = [QBChatMessage new];
        message.senderID = self.senderID;
        message.dialogID = self.dialog.ID;
        
        [[QBServicesManager instance].chatService.chatAttachmentService sendMessage:message
                                                                           toDialog:self.dialog
                                                                    withChatService:[QBServicesManager instance].chatService
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

