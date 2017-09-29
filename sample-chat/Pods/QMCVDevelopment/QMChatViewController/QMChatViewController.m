//
//  QMChatViewController.m
//  QMChatViewController
//
//  Created by Andrey Ivanov on 06.04.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import "QMChatViewController.h"
#import "QMChatCollectionView.h"
#import "QMChatCollectionViewFlowLayout.h"
#import "QMDateUtils.h"
#import "QMChatResources.h"
#import "NSString+QM.h"
#import "UIColor+QM.h"
#import "UIImage+QM.h"
#import "QMHeaderCollectionReusableView.h"
#import "QMCollectionViewFlowLayoutInvalidationContext.h"
#import <Photos/Photos.h>
#import "QMKVOView.h"
#import "QMMediaViewDelegate.h"
#import "QMAudioRecordButton.h"

static void * kChatKeyValueObservingContext = &kChatKeyValueObservingContext;

const NSUInteger kQMSystemInputToolbarDebugHeight = 0;

@interface QMChatViewController ()
<QMInputToolbarDelegate, UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UIActionSheetDelegate, UIScrollViewDelegate,
UIAlertViewDelegate, QMChatDataSourceDelegate>

@property (weak, nonatomic) IBOutlet QMChatCollectionView *collectionView;
@property (weak, nonatomic) IBOutlet QMInputToolbar *inputToolbar;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolbarHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolbarBottomLayoutGuide;

@property (strong, nonatomic, readonly) UIImagePickerController *pickerController;

@property (strong, nonatomic) NSIndexPath *selectedIndexPathForMenu;

//Keyboard observing
@property (strong, nonatomic) QMKVOView *systemInputToolbar;

@end

@implementation QMChatViewController

@synthesize pickerController = _pickerController;

#pragma mark - Initialization

+ (UINib *)nib {
    
    return [QMChatResources nibWithNibName:NSStringFromClass([QMChatViewController class])];
}

+ (instancetype)messagesViewController {
    
    return [[QMChatViewController alloc] initWithNibName:NSStringFromClass([QMChatViewController class])
                                                  bundle:[QMChatResources resourceBundle]];
}

- (void)dealloc {
    
    [self registerForNotifications:NO];
    
    self.inputToolbar.contentView.textView.delegate = nil;
    self.inputToolbar.contentView.textView.pasteDelegate = nil;
    self.inputToolbar.delegate = nil;
    
    self.senderDisplayName = nil;
}

- (void)viewDidLoad {
    
    [[[self class] nib] instantiateWithOwner:self options:nil];
    
    [super viewDidLoad];
    
    [self configureMessagesViewController];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    //Customize your toolbar buttons
    self.inputToolbar.contentView.leftBarButtonItem = [self accessoryButtonItem];
    self.inputToolbar.contentView.rightBarButtonItem = [self sendButtonItem];
    self.inputToolbar.audioRecordingEnabled = YES;
    
    __weak __typeof(self) weakSelf = self;
    self.systemInputToolbar = [[QMKVOView alloc] init];
    self.systemInputToolbar.collectionView = self.collectionView;
    self.systemInputToolbar.inputView = self.inputToolbar;
    self.systemInputToolbar.frame = CGRectMake(0, 0, 0, kQMSystemInputToolbarDebugHeight);
    self.systemInputToolbar.hostViewFrameChangeBlock = ^(UIView *view, BOOL animated) {
        
        CGFloat pos = view.superview.frame.size.height - view.frame.origin.y ;
        
        if (weakSelf.inputToolbar.contentView.textView.isFirstResponder) {
            
            if (view.superview.frame.origin.y > 0 && pos == 0) {
                return;
            }
        }

        const CGFloat v = [weakSelf inputToolBarStartPos];
        
        if (pos < v ) {
            pos = v;
        }
        
        [weakSelf setToolbarBottomConstraintValue:pos animated:animated];
    };
    
    self.inputToolbar.contentView.textView.inputAccessoryView = self.systemInputToolbar;
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)viewWillAppear:(BOOL)animated {
    
    NSParameterAssert(self.senderID != 0);
    NSParameterAssert(self.senderDisplayName != nil);
    
    [super viewWillAppear:animated];
    
    self.toolbarHeightConstraint.constant = self.inputToolbar.preferredDefaultHeight;
    
    if (!self.inputToolbar.contentView.textView.isFirstResponder) {
        self.toolbarBottomLayoutGuide.constant = [self inputToolBarStartPos];
    }
    
    [self updateCollectionViewInsets];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    NSLog(@"MEMORY WARNING: %s", __PRETTY_FUNCTION__);
}

- (void)configureMessagesViewController {
    
    [self registerCells];
    [self registerForNotifications:YES];
    
    self.collectionView.transform = CGAffineTransformMake(1, 0, 0, -1, 0, 0);
    
    self.chatDataSource = [[QMChatDataSource alloc] init];
    self.chatDataSource.delegate = self;
    
    self.inputToolbar.delegate = self;
    self.inputToolbar.contentView.textView.delegate = self;
    
    self.automaticallyScrollsToMostRecentMessage = YES;
}

- (void)registerCells {
    
    //Register header view
    UINib *headerNib = [QMHeaderCollectionReusableView nib];
    NSString *headerView = [QMHeaderCollectionReusableView cellReuseIdentifier];
    [self.collectionView registerNib:headerNib forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:headerView];
    
    // Register contact request cell
    [QMChatContactRequestCell registerForReuseInView:self.collectionView];
    
    // Register Notification cell
    [QMChatNotificationCell registerForReuseInView:self.collectionView];
    
    // Register outgoing cell
    [QMChatOutgoingCell registerForReuseInView:self.collectionView];
    // Register incoming cell
    [QMChatIncomingCell registerForReuseInView:self.collectionView];
    
    // Register attachment incoming cell
    [QMChatAttachmentIncomingCell registerForReuseInView:self.collectionView];
    // Register attachment outgoing cell
    [QMChatAttachmentOutgoingCell registerForReuseInView:self.collectionView];
    
    // Register location outgoing cell
    [QMChatLocationOutgoingCell registerForReuseInView:self.collectionView];
    // Register location incoming cell
    [QMChatLocationIncomingCell registerForReuseInView:self.collectionView];
    
    // Register video attachment outgoing cell
    [QMVideoOutgoingCell registerForReuseInView:self.collectionView];
    // Register video attachment incoming cell
    [QMVideoIncomingCell registerForReuseInView:self.collectionView];
    
    // Register audio attachment outgoing cell
    [QMAudioOutgoingCell registerForReuseInView:self.collectionView];
    // Register audio attachment incoming cell
    [QMAudioIncomingCell registerForReuseInView:self.collectionView];
    
    // Register image attachment outgoing cell
    [QMImageOutgoingCell registerForReuseInView:self.collectionView];
    // Register image attachment incoming cell
    [QMImageIncomingCell registerForReuseInView:self.collectionView];
    
    // Register link preview incoming cell
    [QMChatIncomingLinkPreviewCell registerForReuseInView:self.collectionView];
    // Register link preview outgoing cell
    [QMChatOutgoingLinkPreviewCell registerForReuseInView:self.collectionView];
}


#pragma mark - Getters

- (UIImagePickerController *)pickerController
{
    if (_pickerController == nil) {
        _pickerController = [UIImagePickerController new];
        _pickerController.delegate = self;
    }
    return _pickerController;
}

#pragma mark -
#pragma mark QMChatDataSourceDelegate
- (void)changeDataSource:(QMChatDataSource *)dataSource
            withMessages:(NSArray *)messages
              updateType:(QMDataSourceActionType)updateType {
    
    if (messages.count == 0) {
        return;
    }
    
    dispatch_block_t batchUpdatesBlock = ^{
        
        NSArray *indexPaths =
        [self.chatDataSource performChangesWithMessages:messages
                                             updateType:updateType];
        if (!self.collectionView.dataSource) {
            return;
        }
        
        switch (updateType) {
            
            case QMDataSourceActionTypeAdd:
            [self.collectionView insertItemsAtIndexPaths:indexPaths];
            break;
            
            case QMDataSourceActionTypeUpdate:
            [self.collectionView reloadItemsAtIndexPaths:indexPaths];
            break;
            
            case QMDataSourceActionTypeRemove:
            [self.collectionView deleteItemsAtIndexPaths:indexPaths];
            break;
        }
    };
    
    [self.collectionView performBatchUpdates:batchUpdatesBlock completion:nil];
}

- (void)chatDataSource:(QMChatDataSource *)chatDataSource willBeChangedWithMessageIDs:(NSArray *)messagesIDs {
    
    for (NSString *messageID in messagesIDs) {
        [self.collectionView.collectionViewLayout removeSizeFromCacheForItemID:messageID];
    }
}

#pragma mark - View lifecycle

- (NSUInteger)inputToolBarStartPos {
    
    if (self.tabBarItem) {
        return self.tabBarController.tabBar.frame.size.height;
    }
    
    return 0;
}

#pragma mark - Tool bar

- (UIButton *)accessoryButtonItem {
    
    UIImage *accessoryImage = [QMChatResources imageNamed:@"attachment_ic"];
    
    UIImage *normalImage = [accessoryImage imageMaskedWithColor:[UIColor lightGrayColor]];
    UIImage *highlightedImage = [accessoryImage imageMaskedWithColor:[UIColor darkGrayColor]];
    
    UIButton *accessoryButton =
    [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, accessoryImage.size.width, 32.0f)];
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
    
    CGRect sendTitleRect = [sendTitle boundingRectWithSize:CGSizeMake(1000, maxHeight)
                                                   options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                attributes:@{ NSFontAttributeName : sendButton.titleLabel.font }
                                                   context:nil];
    
    sendButton.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(CGRectIntegral(sendTitleRect)), maxHeight);
    
    return sendButton;
}

#pragma mark - Messages view controller

- (void)didPressSendButton:(UIButton *)button {
    
    NSArray *attachments = [self currentlyComposedMessageTextAttachments];
    
    if (attachments.count) {
        
        [self didPressSendButton:button
             withTextAttachments:attachments
                        senderId:self.senderID
               senderDisplayName:self.senderDisplayName
                            date:[NSDate date]];
    }
    else {
        
        if ([self currentlyComposedMessageText].length)
        {
            [self didPressSendButton:button
                     withMessageText:[self currentlyComposedMessageText]
                            senderId:self.senderID
                   senderDisplayName:self.senderDisplayName
                                date:[NSDate date]];
        }
    }
}

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSUInteger)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date {
    
    NSAssert(NO, @"Error! required method not implemented in subclass. Need to implement %s", __PRETTY_FUNCTION__);
}

- (void)didPressSendButton:(UIButton *)__unused button
       withTextAttachments:(NSArray *)__unused textAttachments
                  senderId:(NSUInteger)__unused senderId
         senderDisplayName:(NSString *)__unused senderDisplayName
                      date:(NSDate *)__unused date {
    
    NSAssert(NO, @"Error! required method not implemented in subclass. Need to implement %s", __PRETTY_FUNCTION__);
}

- (void)didPressAccessoryButton:(UIButton *)sender {
    
    UIAlertController *alertController =
    [UIAlertController alertControllerWithTitle:nil
                                        message:nil
                                 preferredStyle:UIAlertControllerStyleActionSheet];
    
    __weak __typeof(self) weakSelf = self;
    
    dispatch_block_t handler = ^{
        
        [self checkAuthorizationStatusWithCompletion:^(BOOL granted) {
            
            typeof(weakSelf) strongSelf = weakSelf;
            
            if (granted) {
                [strongSelf presentViewController:self.pickerController
                                         animated:YES
                                       completion:nil];
            }
            else {
                [strongSelf showAlertForAccess];
            }
        }];
        
    };
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Camera", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull __unused action) {
                                                          
                                                          self.pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                                                          handler();
                                                      }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Photo Library", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull __unused action) {
                                                          
                                                          self.pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                                          handler();
                                                      }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"SA_STR_CANCEL", nil)
                                                        style:UIAlertActionStyleCancel
                                                      handler:nil]];
    
    if (alertController.popoverPresentationController) {
        // iPad support
        alertController.popoverPresentationController.sourceView = sender;
        alertController.popoverPresentationController.sourceRect = sender.bounds;
    }
    
    [self presentViewController:alertController animated:YES completion:NULL];
}


- (void)didPickAttachmentImage:(UIImage *)image {
    NSAssert(NO, @"Error! required method not implemented in subclass. Need to implement %s", __PRETTY_FUNCTION__);
}

- (void)finishSendingMessage {
    
    [self finishSendingMessageAnimated:YES];
}

- (void)finishSendingMessageAnimated:(BOOL)animated {
    
    QMPlaceHolderTextView *textView = self.inputToolbar.contentView.textView;
    [textView setDefaultSettings];
    
    textView.text = nil;
    textView.attributedText = nil;
    [textView.undoManager removeAllActions];
    
    [self.inputToolbar toggleSendButtonEnabled];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UITextViewTextDidChangeNotification object:textView];
    
    if (self.automaticallyScrollsToMostRecentMessage) {
        [self scrollToBottomAnimated:animated];
    }
}

- (void)finishReceivingMessage {
    
    [self finishReceivingMessageAnimated:YES];
}

- (void)finishReceivingMessageAnimated:(BOOL)animated {
    
    if (self.automaticallyScrollsToMostRecentMessage && ![self isMenuVisible]) {
        [self scrollToBottomAnimated:animated];
    }
}

- (void)scrollToBottomAnimated:(BOOL)animated {
    
    if ([self.collectionView numberOfItemsInSection:0] > 0) {
        
        CGPoint contentOffset = self.collectionView.contentOffset;
        
        if (contentOffset.y > 0) {
            contentOffset.y = 0;
            [self.collectionView setContentOffset:contentOffset
                                         animated:animated];
        }
    }
}

#pragma mark - UIScrollViewDelegate

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    // disabling scroll to bottom when tapping status bar
    return NO;
}

#pragma mark - Collection view data source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return [self.chatDataSource messagesCount];
}

- (UICollectionViewCell *)collectionView:(QMChatCollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    QBChatMessage *messageItem =
    [self.chatDataSource messageForIndexPath:indexPath];
    
    Class class = [self viewClassForItem:messageItem];
    NSString *itemIdentifier = [class cellReuseIdentifier];
    
    QMChatCell *cell =
    [collectionView dequeueReusableCellWithReuseIdentifier:itemIdentifier
                                              forIndexPath:indexPath];
    
    [self collectionView:collectionView configureCell:cell forIndexPath:indexPath];
    
    return cell;
}

- (void)collectionView:(QMChatCollectionView *)collectionView
         configureCell:(UICollectionViewCell *)cell
          forIndexPath:(NSIndexPath *)indexPath {
    
    if ([cell isKindOfClass:[QMChatContactRequestCell class]]) {
        
        QMChatContactRequestCell *contactRequestCell = (id)cell;
        contactRequestCell.actionsHandler = self.actionsHandler;
    }
    
    QBChatMessage *messageItem = [self.chatDataSource messageForIndexPath:indexPath];
    
    if ([cell isKindOfClass:[QMChatNotificationCell class]]) {
        
        [(QMChatNotificationCell *)cell notificationLabel].attributedText = [self attributedStringForItem:messageItem];
        return;
    }
    
    if ([cell isKindOfClass:[QMChatCell class]]) {
        
        QMChatCell *chatCell = (QMChatCell *)cell;
        
        if ([cell isKindOfClass:[QMChatIncomingCell class]]
            || [cell isKindOfClass:[QMChatOutgoingCell class]]
            || [cell isKindOfClass:[QMChatBaseLinkPreviewCell class]]) {
            
            chatCell.textView.enabledTextCheckingTypes = self.enableTextCheckingTypes;
        }
        
        chatCell.topLabel.text = [self topLabelAttributedStringForItem:messageItem];
        chatCell.textView.text = [self attributedStringForItem:messageItem];
        chatCell.bottomLabel.text = [self bottomLabelAttributedStringForItem:messageItem];
    }
}

- (NSAttributedString *)topLabelAttributedStringForItem:(QBChatMessage *)messageItem {
    NSAssert(NO, @"Have to be overridden in subclasses!");
    return nil;
}

- (NSAttributedString *)attributedStringForItem:(QBChatMessage *)messageItem {
    NSAssert(NO, @"Have to be overridden in subclasses!");
    return nil;
}

- (NSAttributedString *)bottomLabelAttributedStringForItem:(QBChatMessage *)messageItem {
    NSAssert(NO, @"Have to be overridden in subclasses!");
    return nil;
}

#pragma mark - Collection view delegate

- (BOOL)collectionView:(QMChatCollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    self.selectedIndexPathForMenu = indexPath;
    
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    
    return action == @selector(copy:);
}

- (void)collectionView:(QMChatCollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    NSAssert(NO, @"Have to be overridden in subclasses.");
}

- (Class)viewClassForItem:(QBChatMessage *)item {
    NSAssert(NO, @"Have to be overridden in subclasses.");
    return nil;
}

#pragma mark - Collection view delegate flow layout

- (CGSize)collectionView:(QMChatCollectionView *)collectionView
                  layout:(QMChatCollectionViewFlowLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return [collectionViewLayout sizeForItemAtIndexPath:indexPath];
}

- (NSString *)collectionView:(QMChatCollectionView *)collectionView
           itemIdAtIndexPath:(NSIndexPath *)indexPath {
    
    QBChatMessage *message = [self.chatDataSource messageForIndexPath:indexPath];
    
    return message.ID;
}

- (QMChatCellLayoutModel)collectionView:(QMChatCollectionView *)collectionView
                 layoutModelAtIndexPath:(NSIndexPath *)indexPath {
    
    QBChatMessage *item = [self.chatDataSource messageForIndexPath:indexPath];
    Class class = [self viewClassForItem:item];
    
    return [class layoutModel];
}

#pragma mark - Input toolbar delegate

- (void)messagesInputToolbar:(QMInputToolbar *)toolbar didPressLeftBarButton:(UIButton *)sender {
    
    if (toolbar.sendButtonOnRight) {
        
        [self didPressAccessoryButton:sender];
    }
    else {
        
        [self didPressSendButton:sender];
    }
}

- (void)messagesInputToolbar:(QMInputToolbar *)toolbar didPressRightBarButton:(UIButton *)sender {
    
    if (toolbar.sendButtonOnRight) {
        
        [self didPressSendButton:sender];
    }
    else {
        
        [self didPressAccessoryButton:sender];
    }
}

- (NSString *)currentlyComposedMessageText {
    
    //  auto-accept any auto-correct suggestions
    [self.inputToolbar.contentView.textView.inputDelegate selectionWillChange:self.inputToolbar.contentView.textView];
    [self.inputToolbar.contentView.textView.inputDelegate selectionDidChange:self.inputToolbar.contentView.textView];
    
    return [self.inputToolbar.contentView.textView.text stringByTrimingWhitespace];
}

- (NSArray *)currentlyComposedMessageTextAttachments {
    
    NSAttributedString * attributedText = self.inputToolbar.contentView.textView.attributedText;
    
    if (!attributedText.length) {
        return nil;
    }
    
    NSMutableArray * __block textAttachments = [NSMutableArray array];
    
    [attributedText enumerateAttribute:NSAttachmentAttributeName
                               inRange:NSMakeRange(0, [attributedText length])
                               options:0
                            usingBlock:^(id value, NSRange range, BOOL *stop)
     {
         if ([value isKindOfClass:[NSTextAttachment class]]) {
             
             NSTextAttachment *attachment = (NSTextAttachment *)value;
             [textAttachments addObject:attachment];
         }
     }];
    
    return textAttachments;
}

#pragma mark - Text view delegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    
    if (textView != self.inputToolbar.contentView.textView) {
        return;
    }
    
    if (self.automaticallyScrollsToMostRecentMessage) {
        [self scrollToBottomAnimated:YES];
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    
    if (textView != self.inputToolbar.contentView.textView) {
        return;
    }
    
    [self.inputToolbar toggleSendButtonEnabled];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    
    if (textView != self.inputToolbar.contentView.textView) {
        return;
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    [self didPickAttachmentImage:image];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Notifications

- (void)didReceiveMenuWillShowNotification:(NSNotification *)notification {
    
    if (!self.selectedIndexPathForMenu) {
        return;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIMenuControllerWillShowMenuNotification
                                                  object:nil];
    
    UIMenuController *menu = [notification object];
    [menu setMenuVisible:NO animated:NO];
    
    QMChatCell *selectedCell = (QMChatCell *)[self.collectionView cellForItemAtIndexPath:self.selectedIndexPathForMenu];
    CGRect selectedCellMessageBubbleFrame = [selectedCell convertRect:selectedCell.containerView.frame toView:self.view];
    
    [menu setTargetRect:selectedCellMessageBubbleFrame inView:self.view];
    [menu setMenuVisible:YES animated:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveMenuWillShowNotification:)
                                                 name:UIMenuControllerWillShowMenuNotification
                                               object:nil];
}

- (void)didReceiveMenuWillHideNotification:(NSNotification *)notification {
    
    if (!self.selectedIndexPathForMenu) {
        return;
    }
    
    //  per comment above in 'shouldShowMenuForItemAtIndexPath:'
    //  re-enable 'selectable', thus re-enabling data detectors if present
    //    QMChatCollectionViewCell *selectedCell = (id)[self.collectionView cellForItemAtIndexPath:self.selectedIndexPathForMenu];
    //    selectedCell.textView.selectable = YES;
    self.selectedIndexPathForMenu = nil;
}

#pragma mark - Input toolbar utilities

- (void)setToolbarBottomConstraintValue:(CGFloat)constraintValue animated:(BOOL)animated {
    
    if (constraintValue < 0) {
        return;
    }
    
    if (!animated) {
        
        CGFloat offset = self.collectionView.contentOffset.y +
        constraintValue - self.toolbarBottomLayoutGuide.constant;
        
        self.collectionView.contentOffset =
        CGPointMake(self.collectionView.contentOffset.x, offset);
    }
    
    self.toolbarBottomLayoutGuide.constant = constraintValue;
    
    if (animated) {
        
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        });
        
        [self.view layoutIfNeeded];
    }
}

- (BOOL)inputToolbarHasReachedMaximumHeight {
    
    return CGRectGetMinY(self.inputToolbar.frame) ==
    (self.topLayoutGuide.length + self.topContentAdditionalInset);
}

#pragma mark - Collection view utilities

- (void)setTopContentAdditionalInset:(CGFloat)topContentAdditionalInset {
    
    if (topContentAdditionalInset != _topContentAdditionalInset) {
        
        _topContentAdditionalInset = topContentAdditionalInset;
        [self updateCollectionViewInsets];
    }
}

- (void)updateCollectionViewInsets {
    
    CGFloat topValue = 0;
    CGFloat bottomValue = self.topContentAdditionalInset;
    
    [self setCollectionViewInsetsTopValue:topValue
                              bottomValue:bottomValue];
}

- (void)setBottomCollectionViewInsetsValue:(CGFloat)bottom {
    
    [self setCollectionViewInsetsTopValue:self.collectionView.contentInset.bottom
                              bottomValue:bottom];
}

- (void)setTopCollectionViewInsetsValue:(CGFloat)top {
    
    [self setCollectionViewInsetsTopValue:top
                              bottomValue:self.collectionView.contentInset.top];
}

- (void)setCollectionViewInsetsTopValue:(CGFloat)top bottomValue:(CGFloat)bottom {
    
    UIEdgeInsets insets = UIEdgeInsetsMake(top, 0.0f, bottom , 0.0f);
    
    if (UIEdgeInsetsEqualToEdgeInsets(self.collectionView.contentInset, insets)) {
        return;
    }
    
    self.collectionView.contentInset = insets;
    self.collectionView.scrollIndicatorInsets = insets;
}

- (BOOL)isMenuVisible {
    //  check if cell copy menu is showing
    //  it is only our menu if `selectedIndexPathForMenu` is not `nil`
    return self.selectedIndexPathForMenu != nil && [[UIMenuController sharedMenuController] isMenuVisible];
}

#pragma mark - Utilities

- (BOOL)shouldCancelScrollingForItemIndexPaths:(NSArray*)indexPathes {
    
    NSSet *visibleInxexPathes= [NSSet setWithArray:self.collectionView.indexPathsForVisibleItems];
    //Index path of the first cell - last message
    NSIndexPath *pathToLastMessage = [NSIndexPath indexPathForRow:0 inSection:0];
    
    if ([visibleInxexPathes containsObject:pathToLastMessage]) {
        return NO;
    }
    
    NSArray *sortedIndexPaths = [visibleInxexPathes.allObjects sortedArrayUsingSelector:@selector(compare:)];
    NSIndexPath *firstVisibleIndexPath = [sortedIndexPaths firstObject];
    
    NSComparisonResult result = [[indexPathes lastObject] compare:firstVisibleIndexPath];
    
    return result == NSOrderedAscending;
}

- (void)registerForNotifications:(BOOL)registerForNotifications {
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    
    if (registerForNotifications) {
        
        [defaultCenter addObserver:self
                          selector:@selector(didReceiveMenuWillShowNotification:)
                              name:UIMenuControllerWillShowMenuNotification
                            object:nil];
        
        [defaultCenter addObserver:self
                          selector:@selector(didReceiveMenuWillHideNotification:)
                              name:UIMenuControllerWillHideMenuNotification
                            object:nil];
    }
    else {
        
        [defaultCenter removeObserver:self
                                 name:UIMenuControllerWillShowMenuNotification
                               object:nil];
        
        [defaultCenter removeObserver:self
                                 name:UIMenuControllerWillHideMenuNotification
                               object:nil];
    }
}

- (void)checkAuthorizationStatusWithCompletion:(void (^)(BOOL granted))completion {
    
    if (self.pickerController.sourceType == UIImagePickerControllerSourceTypeCamera) {
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        switch (status) {
            case AVAuthorizationStatusNotDetermined: {
                
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (completion) {
                            completion(granted);
                        }
                    });
                }];
                break;
            }
            case AVAuthorizationStatusRestricted: {
                if (completion) {
                    completion(NO);
                }
                break;
            }
            case AVAuthorizationStatusDenied: {
                if (completion) {
                    completion(NO);
                }
                break;
            }
            case AVAuthorizationStatusAuthorized: {
                if (completion) {
                    completion(YES);
                }
                break;
            }
        }
    }
    else if (self.pickerController.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        
        switch (status)
        {
            case PHAuthorizationStatusAuthorized:
            if (completion) {
                completion(YES);
            }
            break;
            case PHAuthorizationStatusNotDetermined:
            {
                [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus authorizationStatus)
                 {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         if (completion) {
                             completion(authorizationStatus == PHAuthorizationStatusAuthorized);
                         }
                     });
                 }];
                break;
            }
            default:
            if (completion) {
                completion(NO);
            }
            break;
        }
    }
}

- (void)showAlertForAccess {
    
    NSString *title;
    NSString *message;
    
    if (self.pickerController.sourceType == UIImagePickerControllerSourceTypeCamera) {
        title = NSLocalizedString(@"Camera Access Disabled", nil);
        message = NSLocalizedString(@"You can allow access to Camera in Settings", nil);
    }
    else if (self.pickerController.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        title = NSLocalizedString(@"Photos Access Disabled", nil);
        message = NSLocalizedString(@"You can allow access to Photos in Settings", nil);
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"SA_STR_CANCEL", nil)
                                          otherButtonTitles:NSLocalizedString(@"Open Settings", nil),nil];
    
    [alert show];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [coordinator animateAlongsideTransition:nil
                                 completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
                                     [self updateCollectionViewInsets];
                                 }];
    
    if (self.inputToolbar.contentView.textView.isFirstResponder && self.splitViewController) {
        if(!self.splitViewController.isCollapsed) {
            [self.inputToolbar.contentView.textView resignFirstResponder];
        }
    }
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    
    [super traitCollectionDidChange:previousTraitCollection];
}

- (BOOL)scrollIsAtTop {
    
    return CGRectGetMaxY([self scrollVisibleRect]) >= CGRectGetMaxY([self scrollTopRect]);
}

- (CGRect)scrollVisibleRect {
    
    CGRect visibleRect = CGRectZero;
    visibleRect.origin = self.collectionView.contentOffset;
    visibleRect.size = self.collectionView.frame.size;
    return visibleRect;
}

- (CGRect)scrollTopRect {
    
    return CGRectMake(0.0,
                      self.collectionView.contentSize.height - CGRectGetHeight(self.collectionView.bounds),
                      CGRectGetWidth(self.collectionView.bounds),
                      CGRectGetHeight(self.collectionView.bounds));
}

- (void)hideKeyboard:(BOOL)animated {
    
    dispatch_block_t hideKeyboardBlock = ^{
        if (self.inputToolbar.contentView.textView.isFirstResponder) {
            [self.inputToolbar.contentView resignFirstResponder];
        }
    };
    
    if (!animated) {
        [UIView performWithoutAnimation:hideKeyboardBlock];
    }
    else {
        hideKeyboardBlock();
    }
}

@end
