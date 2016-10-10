//
//  QMChatViewController.m
//  QMChatViewController
//
//  Created by Andrey Ivanov on 06.04.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import "QMChatViewController.h"
#import "QMChatCollectionView.h"
#import "QMToolbarContentView.h"
#import "QMChatCollectionViewFlowLayout.h"
#import "QMChatSection.h"
#import "QMChatSectionManager.h"
#import "QMDateUtils.h"
#import "QMChatResources.h"
#import "NSString+QM.h"
#import "UIColor+QM.h"
#import "UIImage+QM.h"
#import "QMHeaderCollectionReusableView.h"
#import "QMCollectionViewFlowLayoutInvalidationContext.h"
#import <Photos/Photos.h>

@interface QMChatViewController () <QMInputToolbarDelegate, UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UIActionSheetDelegate, UIScrollViewDelegate,
UIAlertViewDelegate,QMPlaceHolderTextViewPasteDelegate, QMChatDataSourceDelegate>

@property (weak, nonatomic) IBOutlet QMChatCollectionView *collectionView;
@property (weak, nonatomic) IBOutlet QMInputToolbar *inputToolbar;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolbarHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolbarBottomLayoutGuide;

@property (strong, nonatomic, readonly) UIImagePickerController *pickerController;
@property (weak, nonatomic) UIView *snapshotView;

@property (strong, nonatomic) NSIndexPath *selectedIndexPathForMenu;

@property (nonatomic, assign) CGFloat lastContentOffset;

@property (assign, nonatomic) BOOL isViewAppeared;
@property (assign, nonatomic) BOOL isLastCellVisible;
@property (assign, nonatomic) BOOL isScrollingToBottom;
@property (assign, nonatomic) BOOL isPerformingAppereanceTransition;

@end

@implementation QMChatViewController

@synthesize pickerController = _pickerController;

+ (UINib *)nib {
    
    return [QMChatResources nibWithNibName:NSStringFromClass([QMChatViewController class])];
}

+ (instancetype)messagesViewController {
    
    return [[QMChatViewController alloc] initWithNibName:NSStringFromClass([QMChatViewController class])
                                                  bundle:[QMChatResources resourceBundle]];
}

- (void)dealloc {
    
    [self registerForNotifications:NO];
    
    self.collectionView.dataSource = nil;
    self.collectionView.delegate = nil;
    
    self.inputToolbar.contentView.textView.delegate = nil;
    self.inputToolbar.contentView.textView.pasteDelegate = nil;
    self.inputToolbar.delegate = nil;
    
    self.senderDisplayName = nil;
}

#pragma mark - Initialization

- (void)configureMessagesViewController {
    
    self.toolbarHeightConstraint.constant = self.inputToolbar.preferredDefaultHeight;
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    self.chatDataSource = [[QMChatDataSource alloc] init];
    self.chatDataSource.delegate = self;
    
    self.chatSectionManager = [[QMChatSectionManager alloc] initWithChatDataSource:self.chatDataSource];
    
    self.inputToolbar.delegate = self;
    
    self.inputToolbar.contentView.textView.delegate = self;
    
    [self.inputToolbar removeFromSuperview];
    
    self.automaticallyScrollsToMostRecentMessage = YES;
    self.topContentAdditionalInset = 0.0f;
    
    [self registerCells];
    
    self.isLastCellVisible = YES;
}

- (void)registerCells {
    //Register header view
    UINib *headerNib = [QMHeaderCollectionReusableView nib];
    NSString *headerView = [QMHeaderCollectionReusableView cellReuseIdentifier];
    [self.collectionView registerNib:headerNib forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:headerView];
    // Register contact request cell
    UINib *requestNib = [QMChatContactRequestCell nib];
    NSString *requestIdentifier = [QMChatContactRequestCell cellReuseIdentifier];
    [self.collectionView registerNib:requestNib forCellWithReuseIdentifier:requestIdentifier];
    // Register Notification cell
    UINib *notificationNib = [QMChatNotificationCell nib];
    NSString *notificationIdentifier = [QMChatNotificationCell cellReuseIdentifier];
    [self.collectionView  registerNib:notificationNib forCellWithReuseIdentifier:notificationIdentifier];
    // Register outgoing cell
    UINib *outgoingNib = [QMChatOutgoingCell nib];
    NSString *outgoingIdentifier = [QMChatOutgoingCell cellReuseIdentifier];
    [self.collectionView registerNib:outgoingNib forCellWithReuseIdentifier:outgoingIdentifier];
    // Register incoming cell
    UINib *incomingNib = [QMChatIncomingCell nib];
    NSString *incomingIdentifier = [QMChatIncomingCell cellReuseIdentifier];
    [self.collectionView  registerNib:incomingNib forCellWithReuseIdentifier:incomingIdentifier];
    // Register attachment incoming cell
    UINib *attachmentIncomingNib = [QMChatAttachmentIncomingCell nib];
    NSString *attachmentIncomingIdentifier = [QMChatAttachmentIncomingCell cellReuseIdentifier];
    [self.collectionView registerNib:attachmentIncomingNib forCellWithReuseIdentifier:attachmentIncomingIdentifier];
    // Register attachment outgoing cell
    UINib *attachmentOutgoingNib  = [QMChatAttachmentOutgoingCell nib];
    NSString *attachmentOutgoingIdentifier = [QMChatAttachmentOutgoingCell cellReuseIdentifier];
    [self.collectionView registerNib:attachmentOutgoingNib forCellWithReuseIdentifier:attachmentOutgoingIdentifier];
    // Register location outgoing cell
    UINib *locOutgoingNib = [QMChatLocationOutgoingCell nib];
    NSString *locOugoingIdentifier = [QMChatLocationOutgoingCell cellReuseIdentifier];
    [self.collectionView registerNib:locOutgoingNib forCellWithReuseIdentifier:locOugoingIdentifier];
    // Register location incoming cell
    UINib *locIncomingNib = [QMChatLocationIncomingCell nib];
    NSString *locIncomingIdentifier = [QMChatLocationIncomingCell cellReuseIdentifier];
    [self.collectionView registerNib:locIncomingNib forCellWithReuseIdentifier:locIncomingIdentifier];
}

- (UIView *)inputAccessoryView {
    
    return self.inputToolbar;
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
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

#pragma mark - Setters

- (void)setTopContentAdditionalInset:(CGFloat)topContentAdditionalInset {
    
    _topContentAdditionalInset = topContentAdditionalInset;
    [self updateCollectionViewInsets];
}


#pragma mark -
#pragma mark QMChatDataSourceDelegate
- (void)changeDataSource:(QMChatDataSource *)dataSource withMessages:(NSArray *)messages updateType:(QMDataSourceActionType)updateType {
    
    if (messages.count == 0) {
        return;
    }
    
    if (self.isViewAppeared) {
        
        __weak typeof(self) weakSelf = self;
        
        [self.collectionView performBatchUpdates:^{
            
            typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            NSArray *indexPaths = [strongSelf.chatDataSource performChangesWithMessages:messages updateType:updateType];
            
            switch (updateType) {
                    
                case QMDataSourceActionTypeAdd:
                    [strongSelf.collectionView insertItemsAtIndexPaths:indexPaths];
                    break;
                    
                case QMDataSourceActionTypeUpdate:
                    [strongSelf.collectionView reloadItemsAtIndexPaths:indexPaths];
                    break;
                    
                case QMDataSourceActionTypeRemove:
                    [strongSelf.collectionView deleteItemsAtIndexPaths:indexPaths];
                    break;
                    
            }
        }
                                      completion:nil];
    }
    else {
        
        [self.chatDataSource performChangesWithMessages:messages updateType:updateType];
        [self.collectionView reloadData];
    }
}

- (void)chatDataSource:(QMChatDataSource *)chatDataSource willBeChangedWithMessageIDs:(NSArray *)messagesIDs {
    
    for (NSString *messageID in messagesIDs) {
        [self.collectionView.collectionViewLayout removeSizeFromCacheForItemID:messageID];
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[[self class] nib] instantiateWithOwner:self options:nil];
    
    [self configureMessagesViewController];
    
    //Customize your toolbar buttons
    self.inputToolbar.contentView.leftBarButtonItem = [self accessoryButtonItem];
    self.inputToolbar.contentView.rightBarButtonItem = [self sendButtonItem];
    
    self.collectionView.transform = CGAffineTransformMake(1, 0, 0, -1, 0, 0);
    
    self.isViewAppeared = NO;
    
    __weak typeof(self)weakSelf = self;
    
    [self.inputToolbar setInputToolbarFrameChangedBlock:^(CGRect rect) {
        
        typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.isPerformingAppereanceTransition) {
            return;
        }
        CGRect convertedRect = [strongSelf.view convertRect:rect fromView:nil];
        CGFloat value = CGRectGetHeight(strongSelf.view.frame) - CGRectGetMinY(convertedRect);
        
        if (value < strongSelf.inputToolbar.preferredDefaultHeight) {
            value =  strongSelf.inputToolbar.preferredDefaultHeight;
        }
        
        [strongSelf setCollectionViewInsetsTopValue:strongSelf.collectionView.contentInset.bottom
                                        bottomValue:value];
    }];

}

- (void)viewWillAppear:(BOOL)animated {
    
    NSParameterAssert(self.senderID != 0);
    NSParameterAssert(self.senderDisplayName != nil);
    
    [self registerForNotifications:YES];
    
    [super viewWillAppear:animated];
    
    self.toolbarHeightConstraint.constant = self.inputToolbar.preferredDefaultHeight;
    [self.view layoutIfNeeded];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    self.isViewAppeared = YES;
    
    self.isPerformingAppereanceTransition = NO;
    
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    self.isPerformingAppereanceTransition = NO;
    [self updateCollectionViewInsets];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    NSLog(@"MEMORY WARNING: %s", __PRETTY_FUNCTION__);
}

#pragma mark - Tool bar

- (UIButton *)accessoryButtonItem {
    
    UIImage *accessoryImage = [QMChatResources imageNamed:@"attachment_ic"];
    
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
    
    [self becomeFirstResponder];
    [self.inputToolbar.contentView.textView resignFirstResponder];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    __weak __typeof(self) weakSelf = self;
    
    dispatch_block_t handler = ^{
        
        __weak typeof(self) weakSelf = self;
        [self checkAuthorizationStatusWithCompletion:^(BOOL granted) {
            
            typeof(weakSelf) strongSelf = weakSelf;
            
            if (granted) {
                [strongSelf presentViewController:self.pickerController animated:YES completion:nil];
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
        
        NSIndexPath *topIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.collectionView scrollToItemAtIndexPath:topIndexPath atScrollPosition:UICollectionViewScrollPositionTop animated:animated];
        _isLastCellVisible = YES;
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

- (UICollectionViewCell *)collectionView:(QMChatCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    QBChatMessage *messageItem = [self.chatDataSource messageForIndexPath:indexPath];
    
    Class class = [self viewClassForItem:messageItem];
    NSString *itemIdentifier = [class cellReuseIdentifier];
    
    QMChatCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:itemIdentifier forIndexPath:indexPath];
    cell.transform = self.collectionView.transform;
    
    [self collectionView:collectionView configureCell:cell forIndexPath:indexPath];
    
    cell.layer.shouldRasterize = YES;
    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    
    return cell;
}

- (void)collectionView:(QMChatCollectionView *)collectionView configureCell:(UICollectionViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    
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
            || [cell isKindOfClass:[QMChatOutgoingCell class]]) {
            
            chatCell.textView.enabledTextCheckingTypes = self.enableTextCheckingTypes;
        }
        
        chatCell.textView.text = [self attributedStringForItem:messageItem];
        chatCell.topLabel.text = [self topLabelAttributedStringForItem:messageItem];
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
                  layout:(QMChatCollectionViewFlowLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return [collectionViewLayout sizeForItemAtIndexPath:indexPath];
}

- (NSString *)collectionView:(QMChatCollectionView *)collectionView itemIdAtIndexPath:(NSIndexPath *)indexPath {
    
    QBChatMessage *message = [self.chatDataSource messageForIndexPath:indexPath];
    
    return message.ID;
}

- (QMChatCellLayoutModel)collectionView:(QMChatCollectionView *)collectionView layoutModelAtIndexPath:(NSIndexPath *)indexPath {
    
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
    
    [textView becomeFirstResponder];
    
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
    
    [textView resignFirstResponder];
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1 && &UIApplicationOpenSettingsURLString != NULL) {
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

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
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

- (BOOL)inputToolbarHasReachedMaximumHeight {
    
    return CGRectGetMinY(self.inputToolbar.frame) == (self.topLayoutGuide.length + self.topContentAdditionalInset);
}

- (void)adjustInputToolbarForComposerTextViewContentSizeChange:(CGFloat)dy {
    
    BOOL contentSizeIsIncreasing = (dy > 0);
    
    if ([self inputToolbarHasReachedMaximumHeight]) {
        
        BOOL contentOffsetIsPositive = (self.inputToolbar.contentView.textView.contentOffset.y > 0);
        
        if (contentSizeIsIncreasing || contentOffsetIsPositive) {
            [self scrollComposerTextViewToBottomAnimated:YES];
            
            return;
        }
    }
    
    CGFloat toolbarOriginY = CGRectGetMinY(self.inputToolbar.frame);
    CGFloat newToolbarOriginY = toolbarOriginY - dy;
    
    //  attempted to increase origin.Y above topLayoutGuide
    if (newToolbarOriginY <= self.topLayoutGuide.length + self.topContentAdditionalInset) {
        
        dy = toolbarOriginY - (self.topLayoutGuide.length + self.topContentAdditionalInset);
        [self scrollComposerTextViewToBottomAnimated:YES];
    }
    
    [self adjustInputToolbarHeightConstraintByDelta:dy];
    
    if (dy < 0) {
        
        [self scrollComposerTextViewToBottomAnimated:NO];
    }
}

- (void)adjustInputToolbarHeightConstraintByDelta:(CGFloat)dy {
    
    self.toolbarHeightConstraint.constant += dy;
    
    if (self.toolbarHeightConstraint.constant < self.inputToolbar.preferredDefaultHeight) {
        self.toolbarHeightConstraint.constant = self.inputToolbar.preferredDefaultHeight;
    }
    
    [self.view setNeedsUpdateConstraints];
    [self.view layoutIfNeeded];
}

- (void)scrollComposerTextViewToBottomAnimated:(BOOL)animated {
    
    UITextView *textView = self.inputToolbar.contentView.textView;
    CGPoint contentOffsetToShowLastLine = CGPointMake(0.0f, textView.contentSize.height - CGRectGetHeight(textView.bounds));
    
    if (!animated) {
        textView.contentOffset = contentOffsetToShowLastLine;
        return;
    }
    
    [UIView animateWithDuration:0.01 delay:0.01 options:UIViewAnimationOptionCurveLinear animations:^{
        
        textView.contentOffset = contentOffsetToShowLastLine;
    }
                     completion:nil];
}

#pragma mark - Collection view utilities

- (void)updateCollectionViewInsets {
    
    [self setCollectionViewInsetsTopValue:self.topLayoutGuide.length + self.topContentAdditionalInset
                              bottomValue:CGRectGetHeight(self.inputToolbar.frame)];
}

- (void)setCollectionViewInsetsTopValue:(CGFloat)top bottomValue:(CGFloat)bottom {
    
    UIEdgeInsets insets = UIEdgeInsetsMake(bottom, 0.0f, top , 0.0f);
    
    if (UIEdgeInsetsEqualToEdgeInsets(self.collectionView.contentInset, insets)) {
        return;
    }
    
    self.collectionView.contentInset = insets;
    self.collectionView.scrollIndicatorInsets = insets;

    if (self.isLastCellVisible) {
        [self scrollToBottomAnimated:YES];
    }
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
    
    if  ([visibleInxexPathes containsObject:pathToLastMessage]) {
        
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
    [self resetLayoutAndCaches];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    [self resetLayoutAndCaches];
}

- (void)resetLayoutAndCaches
{
    QMCollectionViewFlowLayoutInvalidationContext *context = [QMCollectionViewFlowLayoutInvalidationContext context];
    context.invalidateFlowLayoutMessagesCache = YES;
    [self.collectionView.collectionViewLayout invalidateLayoutWithContext:context];
}

- (UICollectionReusableView *)collectionView:(QMChatCollectionView *)collectionView
                    sectionHeaderAtIndexPath:(NSIndexPath *)indexPath {
    //    QMHeaderCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
    //                                                                                    withReuseIdentifier:[QMHeaderCollectionReusableView cellReuseIdentifier] forIndexPath:indexPath];
    //
    //    QMChatSection *chatSection = [self.chatSectionManager chatSectionAtIndex:indexPath.section];
    //    headerView.headerLabel.text = [self nameForSectionWithDate:[chatSection lastMessageDate]];
    //    headerView.transform = self.collectionView.transform;
    //
    //    return headerView;
    return nil;
}

- (void)checkVisibilityOfCell:(UICollectionViewCell *)cell inScrollView:(UIScrollView *)scrollView {
    
    CGRect visibleRect = CGRectIntersection(self.collectionView.frame, self.collectionView.superview.bounds);
    visibleRect.size.height = visibleRect.size.height - self.collectionView.contentInset.top;
    
    UICollectionViewLayoutAttributes *attributes = [self.collectionView layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    CGRect cellRect = attributes.frame;
    CGRect cellFrameInSuperview = [self.collectionView convertRect:cellRect toView:[self.collectionView superview]];
    
    CGRect intersect = CGRectIntersection(visibleRect, cellFrameInSuperview);
    float visibleHeight = CGRectGetHeight(intersect);
    
    _isLastCellVisible = (visibleHeight > 0);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (![scrollView isKindOfClass:[QMChatCollectionView class]]) {
        return;
    }
    
    [self checkDirectionForScrollView:scrollView];
    
    if (!self.isLastCellVisible && self.isScrollingToBottom) {
        return;
    }
    
    [self checkVisibilityForScrollView:scrollView];
}

- (void)checkDirectionForScrollView:(UIScrollView *)scrollView {
    
    if (self.lastContentOffset > scrollView.contentOffset.y)
    {
        self.isScrollingToBottom = NO;
    }
    else if (self.lastContentOffset < scrollView.contentOffset.y)
    {
        self.isScrollingToBottom = YES;
    }
    
    self.lastContentOffset = scrollView.contentOffset.y;
}

- (void)checkVisibilityForScrollView:(UIScrollView *)scrollView {
    
    NSArray *visibleCells = self.collectionView.visibleCells;
    
    NSUInteger cellCount = [visibleCells count];
    
    if (cellCount == 0) {
        return;
    }
    
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    
    if (![visibleCells containsObject:cell]) {
        _isLastCellVisible = NO;
        return;
    }
    
    // Check the visibility of the first cell
    [self checkVisibilityOfCell:[visibleCells firstObject] inScrollView:scrollView];
    
    if (cellCount == 1) {
        return;
    }
    
    // Check the visibility of the last cell
    [self checkVisibilityOfCell:[visibleCells lastObject] inScrollView:scrollView];
    
    if (cellCount == 2) {
        return;
    }
    
    // All of the rest of the cells are visible: Loop through the 2nd through n-1 cells
    for (NSUInteger i = 1; i < cellCount - 1; i++) {
        UICollectionViewCell *cell = visibleCells[i];
        [self checkVisibilityOfCell:cell inScrollView:scrollView];
    }
}

- (void)beginAppearanceTransition:(BOOL)isAppearing animated:(BOOL)animated {
    
    [super beginAppearanceTransition:isAppearing animated:animated];
    
    self.isPerformingAppereanceTransition = YES;
}


@end
