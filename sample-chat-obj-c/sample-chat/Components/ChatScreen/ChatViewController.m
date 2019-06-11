//
//  ChatViewController.m
//  samplechat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "ChatViewController.h"
#import "ChatCollectionView.h"
#import "ChatDataSource.h"
#import "InputToolbar.h"
#import "KVOView.h"
#import "ChatManager.h"
#import "Profile.h"
#import "Reachability.h"
#import "HeaderCollectionReusableView.h"
#import "QBChatMessage+QBDateDivider.h"
#import "ChatNotificationCell.h"
#import "ChatIncomingCell.h"
#import "ChatOutgoingCell.h"
#import "ChatAttachmentOutgoingCell.h"
#import "ChatAttachmentIncomingCell.h"
#import "AttachmentBar.h"
#import "ChatResources.h"
#import "UIImage+Chat.h"
#import "UIColor+Chat.h"
#import "NSString+Chat.h"
#import "UIImage+fixOrientation.h"
#import "DateUtils.h"
#import "UsersInfoTableViewController.h"
#import "AttachmentDownloadManager.h"
#import "ZoomedAttachmentViewController.h"

#import <Photos/Photos.h>
#import <TTTAttributedLabel/TTTAttributedLabel.h>
#import <SafariServices/SafariServices.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <CoreTelephony/CTCarrier.h>
#import "Log.h"
#import "QBUUser+Chat.h"

typedef NS_ENUM(NSUInteger, MessageStatus) {
    MessageStatusSent = 1,
    MessageStatusSending = 2,
    MessageStatusNotSent = 3,
};

static void * kChatKeyValueObservingContext = &kChatKeyValueObservingContext;

const NSUInteger kSystemInputToolbarDebugHeight = 0;
static const NSUInteger widthPadding = 40.0f;

@interface ChatViewController () <InputToolbarDelegate, UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UIActionSheetDelegate, UIScrollViewDelegate, UITextViewDelegate,
ChatDataSourceDelegate, ChatManagerDelegate, QBChatDelegate, ChatCellDelegate, ChatCollectionViewDelegateFlowLayout, AttachmentBarDelegate>

@property (strong, nonatomic) QBChatDialog *dialog;

@property (weak, nonatomic) IBOutlet ChatCollectionView *collectionView;
@property (weak, nonatomic) IBOutlet InputToolbar *inputToolbar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionBottomConstraint;
@property (weak, nonatomic) IBOutlet ChatCollectionViewFlowLayout *chatFlowLayout;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolbarHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolbarBottomLayoutGuide;

@property (strong, nonatomic, readonly) UIImagePickerController *pickerController;

@property (strong, nonatomic) NSIndexPath *selectedIndexPathForMenu;

@property (strong, nonatomic) ChatDataSource *dataSource;
@property (nonatomic, strong) ChatManager *chatManager;

@property (assign, nonatomic) NSTextCheckingTypes enableTextCheckingTypes;

@property (strong, nonatomic) KVOView *systemInputToolbar;

@property (assign, nonatomic) CGFloat offsetY;
@property (assign, nonatomic) CGFloat topContentAdditionalInset;
@property (assign, nonatomic) BOOL isUploading;
@property (assign, nonatomic) BOOL automaticallyScrollsToMostRecentMessage;
@property (assign, nonatomic) BOOL cancel;

@property (nonatomic, strong) id observerWillResignActive;
@property (nonatomic, strong) id observerWillActive;
@property (assign, nonatomic) BOOL isDeviceLocked;

@property (strong, nonatomic) QBChatMessage * attachmentMessage;
@property (strong, nonatomic) AttachmentBar * attachmentBar;

@property (strong, nonatomic) NSString *senderDisplayName;
@property (assign, nonatomic) NSUInteger senderID;
@property (assign, nonatomic) NSUInteger inputToolBarStartPosition;
@property (assign, nonatomic) CGFloat collectionBottomConstant;

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

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.dataSource = [[ChatDataSource alloc] init];
    self.dataSource.delegate = self;
    
    self.chatManager = [ChatManager instance];
    self.chatManager.delegate = self;
    
    [QBChat.instance addDelegate: self];
    [self setupViewMessages];
    self.isDeviceLocked = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    //Customize your toolbar buttons
    self.inputToolbar.contentView.leftBarButtonItem = [self accessoryButtonItem];
    self.inputToolbar.contentView.rightBarButtonItem = [self sendButtonItem];
    [self.inputToolbar setupBarButtonEnabledLeft:YES andRight:NO];
    
    self.systemInputToolbar = [[KVOView alloc] init];
    self.systemInputToolbar.collectionView = self.collectionView;
    self.systemInputToolbar.inputView = self.inputToolbar;
    self.systemInputToolbar.frame = CGRectMake(0, 0, 0, kSystemInputToolbarDebugHeight);
    __weak __typeof(self) weakSelf = self;
    self.systemInputToolbar.hostViewFrameChangeBlock = ^(UIView *view, BOOL animated) {
        CGFloat position = weakSelf.view.frame.size.height - [weakSelf.view.superview convertPoint:view.frame.origin toView:weakSelf.view].y;
        
        if (weakSelf.inputToolbar.contentView.textView.isFirstResponder) {
            if (view.superview.frame.origin.y > 0 && position <= 0) {
                return;
            }
        }
        
        const CGFloat startPosition = weakSelf.inputToolBarStartPosition;
        
        if (position < startPosition || !view) {
            position = startPosition;
        }
        
        [weakSelf setToolbarBottomConstraintValue:position animated:animated];
    };
    
    self.inputToolbar.contentView.textView.inputAccessoryView = self.systemInputToolbar;
    
    self.edgesForExtendedLayout = UIRectEdgeNone; //same UIRectEdgeNone
    self.isUploading = NO;
    self.cancel = NO;
    self.topContentAdditionalInset = 0.0f;
    self.inputToolBarStartPosition = 0;
    self.collectionBottomConstant = 0.0;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [QBChat.instance addDelegate: self];
    if ([QBChat.instance isConnected]) {
        [self loadMessagesWithSkip:0];
    }
    
    self.chatManager.delegate = self;
    
    Profile *currentUser = [[Profile alloc] init];
    if (currentUser.isFull == NO || !self.dialogID) {
        return;
    }
    
    self.senderDisplayName = currentUser.fullName;
    self.senderID = currentUser.ID;
    self.dialog = [self.chatManager.storage dialogWithID:self.dialogID];
    self.title = self.dialog.name;
    
    [self registerForNotifications:YES];
    
    self.inputToolbar.delegate = self;
    if (self.inputToolbar.contentView.textView.isFirstResponder == NO) {
        self.toolbarBottomLayoutGuide.constant = (CGFloat)self.inputToolBarStartPosition;
    }
    
    [self updateCollectionViewInsets];
    self.collectionBottomConstraint.constant = self.collectionBottomConstant;
    
    if (self.dialog.type != QBChatDialogTypePublicGroup ) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Chat Info"
                                                                                  style:UIBarButtonItemStylePlain
                                                                                 target:self
                                                                                 action:@selector(didTapInfo:)];
    }
    
    //MARK: - Reachability
    void (^updateConnectionStatus)(QBNetworkStatus status) = ^(QBNetworkStatus status) {
        
        if (status == QBNetworkStatusNotReachable) {
            [self cancelUploadFile];
        }
    };
    Reachability.instance.networkStatusBlock = ^(QBNetworkStatus status) {
        updateConnectionStatus(status);
    };
    updateConnectionStatus(Reachability.instance.networkStatus);
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    __weak __typeof(self)weakSelf = self;
    self.observerWillResignActive = [defaultCenter addObserverForName: UIApplicationWillResignActiveNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        __typeof(weakSelf)strongSelf = weakSelf;
        strongSelf.isDeviceLocked = YES;
    }];
    self.observerWillActive = [defaultCenter addObserverForName: UIApplicationDidBecomeActiveNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        __typeof(weakSelf)strongSelf = weakSelf;
        strongSelf.isDeviceLocked = NO;
        [strongSelf.collectionView reloadData];
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [QBChat.instance removeDelegate: self];
    
    [self registerForNotifications:NO];
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    if (self.observerWillResignActive) {
        [defaultCenter removeObserver:(self.observerWillResignActive)];
    }
    if (self.observerWillActive) {
        [defaultCenter removeObserver:(self.observerWillActive)];
    }
    [defaultCenter removeObserver:(self)];
    // clearing typing status blocks
    [self.dialog clearTypingStatusBlocks];
}

#pragma mark - Internal Methods
- (void)cancelUploadFile {
    [self hideAttacnmentBar];
    self.isUploading = NO;
    
    if (self.attachmentMessage) {
        self.attachmentMessage = nil;
    }
    __weak __typeof(self)weakSelf = self;
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:NSLocalizedString(@"SA_STR_ERROR", nil)
                                          message:NSLocalizedString(@"SA_STR_FAILED_UPLOAD_ATTACHMENT", nil)
                                          preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"SA_STR_CANCEL", nil)
                                                           style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                                                               [weakSelf.inputToolbar setupBarButtonEnabledLeft:YES andRight:NO];
                                                           }];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:NO completion:nil];
}

- (void)updateCollectionViewInsets {
    CGFloat topValue = 0.0f;
    CGFloat bottomValue = self.topContentAdditionalInset;
    
    [self setCollectionViewInsetsTopValue:topValue
                              bottomValue:bottomValue];
}

- (void)setCollectionViewInsetsTopValue:(CGFloat)top bottomValue:(CGFloat)bottom {
    UIEdgeInsets insets = UIEdgeInsetsZero;
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
        [self.view layoutIfNeeded];
    }
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
    } else {
        [defaultCenter removeObserver:self
                                 name:UIMenuControllerWillShowMenuNotification
                               object:nil];
        
        [defaultCenter removeObserver:self
                                 name:UIMenuControllerWillHideMenuNotification
                               object:nil];
    }
}

- (void)loadMessagesWithSkip:(NSInteger)skip {
    [SVProgressHUD showWithStatus:NSLocalizedString(@"SA_STR_LOADING_MESSAGES", nil)];
    [self.chatManager messagesWithDialogID:self.dialogID
                           extendedRequest:nil
                                      skip:skip
                                   success:^(NSArray<QBChatMessage *> * _Nonnull messages, Boolean isLast) {
                                       self.cancel = isLast;
                                       [self.dataSource addMessages:messages];
                                       [SVProgressHUD dismiss];
                                   } errorHandler:^(NSString * _Nonnull error) {
                                       if (error == NSLocalizedString(@"SA_STR_DIALOG_REMOVED", nil)) {
                                           [self.dataSource clear];
                                           [self.dialog clearTypingStatusBlocks];
                                           self.inputToolbar.userInteractionEnabled = NO;
                                           self.collectionView.scrollEnabled = NO;
                                           [self.collectionView reloadData];
                                           self.title = @"";
                                           self.navigationItem.rightBarButtonItem.enabled = NO;
                                       }
                                       [SVProgressHUD showErrorWithStatus:error];
                                   }];
}

- (void)setupViewMessages {
    [self registerCells];
    
    self.collectionView.transform = CGAffineTransformMake(1.0f, 0.0f, 0.0f, -1.0f, 0.0f, 0.0f);
    self.inputToolbar.contentView.textView.delegate = self;
    self.automaticallyScrollsToMostRecentMessage = YES;
}

- (void)registerCells {
    //Register header view
    UINib *headerNib = [HeaderCollectionReusableView nib];
    NSString *headerView = [HeaderCollectionReusableView cellReuseIdentifier];
    [self.collectionView registerNib:headerNib
          forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                 withReuseIdentifier:headerView];
    // Register cells
    [ChatNotificationCell registerForReuseInView:self.collectionView];
    [ChatOutgoingCell registerForReuseInView:self.collectionView];
    [ChatIncomingCell registerForReuseInView:self.collectionView];
    [ChatAttachmentIncomingCell registerForReuseInView:self.collectionView];
    [ChatAttachmentOutgoingCell registerForReuseInView:self.collectionView];
}

#pragma mark - Tool bar
- (UIButton *)accessoryButtonItem {
    UIImage *accessoryImage = [ChatResources imageNamed:@"attachment_ic"];
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

- (void)didTapInfo:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:NSLocalizedString(@"SA_STR_SEGUE_GO_TO_INFO", nil) sender:nil];
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
    
    ChatCell *selectedCell = (ChatCell *)[self.collectionView cellForItemAtIndexPath:self.selectedIndexPathForMenu];
    CGRect selectedCellMessageBubbleFrame = [selectedCell convertRect:selectedCell.containerView.frame
                                                               toView:self.view];
    
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
    //    ChatCollectionViewCell *selectedCell = (id)[self.collectionView cellForItemAtIndexPath:self.selectedIndexPathForMenu];
    //    selectedCell.textView.selectable = YES;
    self.selectedIndexPathForMenu = nil;
}

#pragma mark - Collection view delegate
- (BOOL)collectionView:(ChatCollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndexPathForMenu = indexPath;
    
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView
      canPerformAction:(SEL)action
    forItemAtIndexPath:(NSIndexPath *)indexPath
            withSender:(id)sender {
    QBChatMessage *item = [self.dataSource messageWithIndexPath:indexPath];
    Class viewClass = [self viewClassForItem:item];
    
    if (viewClass == [ChatNotificationCell class]){
        return NO;
    }
    
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView
         performAction:(SEL)action
    forItemAtIndexPath:(NSIndexPath *)indexPath
            withSender:(id)sender {
    
    if (action != @selector(copy:)) {
        return;
    }
    
    QBChatMessage *message = [self.dataSource messageWithIndexPath:indexPath];
    if (message.attachments.count > 0) {
        return;
    }
    
    [[UIPasteboard generalPasteboard] setString:message.text];
}

- (Class)viewClassForItem:(QBChatMessage *)item {
    
    if (item.customParameters[@"notification_type"] != nil || item.isDateDividerMessage) {
        return [ChatNotificationCell class];
    }
    
    if (item.senderID != self.senderID) {
        if (item.attachments.count > 0) {
            return [ChatAttachmentIncomingCell class];
        } else {
            return [ChatIncomingCell class];
        }
    } else {
        if (item.attachments.count > 0) {
            return [ChatAttachmentOutgoingCell class];
        } else {
            return [ChatOutgoingCell class];
        }
    }
}

#pragma mark - Strings builder
- (NSAttributedString *)attributedStringForItem:(QBChatMessage *)messageItem {
    
    UIColor *textColor = [messageItem senderID] == self.senderID ? [UIColor whiteColor] : [UIColor blackColor];
    if (messageItem.customParameters[@"notification_type"] != nil || messageItem.isDateDividerMessage) {
        textColor =  [UIColor blackColor];
    }
    
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:17.0f] ;
    NSDictionary *attributes = @{ NSForegroundColorAttributeName:textColor,
                                  NSFontAttributeName:font};
    
    NSString *text = messageItem.text.length ? messageItem.text : @"";
    if (messageItem.customParameters[@"notification_type"] != nil) {
        text = [NSString stringWithFormat:@"%@\n%@", (messageItem.dateSent ? [self timeStampWithDate:messageItem.dateSent] : @""), text];
    }
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:text
                                                                               attributes:attributes];
    return string;
}

- (NSAttributedString *)topLabelAttributedStringForItem:(QBChatMessage *)messageItem {
    
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:17.0f];
    
    if ([messageItem senderID] == self.senderID || self.dialog.type == QBChatDialogTypePrivate) {
        return nil;
    }
    
    NSString *senderFullName = [self.chatManager.storage userWithID: messageItem.senderID].fullName;
    NSString *senderID = [NSString stringWithFormat:@"@%lu", (unsigned long)messageItem.senderID];
    NSString *topLabelText = senderFullName ? senderFullName : senderID;
    
    // setting the paragraph style lineBreakMode to NSLineBreakByTruncatingTail in order to TTTAttributedLabel
    // cut the line in a correct way
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    UIColor *color = [UIColor colorWithRed:0 green:122.0f / 255.0f blue:1.0f alpha:1.000];
    NSDictionary *attributes = @{ NSForegroundColorAttributeName:color,
                                  NSFontAttributeName:font,
                                  NSParagraphStyleAttributeName: paragraphStyle};
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:topLabelText attributes:attributes];
    
    return string;
}

- (NSAttributedString *)bottomLabelAttributedStringForItem:(QBChatMessage *)messageItem {
    
    UIColor *textColor = [UIColor colorWithWhite:0.0f alpha:0.7f];
    if ([messageItem senderID] == self.senderID) {
        [UIColor colorWithWhite:1.0f alpha:0.7f];
    }
    
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
        text = [NSString stringWithFormat:@"%@\n%@", text, [self statusStringFromMessage:messageItem]];
    }
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:text
                                                                               attributes:attributes];
    
    return string;
}

- (NSString *)statusStringFromMessage:(QBChatMessage *)message {
    
    NSMutableArray* readIDs = [message.readIDs mutableCopy];
    [readIDs removeObject:@(self.senderID)];
    NSMutableArray* deliveredIDs = [message.deliveredIDs mutableCopy];
    [deliveredIDs removeObject:@(self.senderID)];
    
    [deliveredIDs removeObjectsInArray:readIDs];
    
    if (readIDs.count > 0 || deliveredIDs.count > 0) {
        NSMutableString* statusString = [NSMutableString string];
        
        NSMutableArray* readLogins = [NSMutableArray array];
        for (NSNumber* readID in readIDs) {
            QBUUser *user = [self.chatManager.storage userWithID: [readID unsignedIntegerValue]];
            if (user.name.length) {
                if ([readLogins containsObject:user.name]) {
                    continue;
                }
                [readLogins addObject:user.name];
            } else {
                NSString *unkownUserLogin = [@"@%@" stringByAppendingString:[readID stringValue]];
                [readLogins addObject:unkownUserLogin];
            }
        }
        
        if (readLogins.count) {
            NSString *status = NSLocalizedString(@"SA_STR_READ_STATUS", nil);
            if (message.attachments.count > 0) {
                status = NSLocalizedString(@"SA_STR_SEEN_STATUS", nil);
            }
            [statusString appendFormat:@"%@: %@", status, [readLogins componentsJoinedByString:@", "]];
        }
        
        NSMutableArray* deliveredLogins = [NSMutableArray array];
        for (NSNumber* deliveredID in deliveredIDs) {
            QBUUser *user = [self.chatManager.storage userWithID: [deliveredID unsignedIntegerValue]];
            if (user.name.length) {
                if ([deliveredLogins containsObject:user.name] || [readLogins containsObject:user.name]) {
                    continue;
                }
                [deliveredLogins addObject:user.name];
            } else {
                NSString *unkownUserLogin = [@"@%@" stringByAppendingString:[deliveredID stringValue]];
                [deliveredLogins addObject:unkownUserLogin];
            }
        }
        
        if (deliveredLogins.count) {
            if (readLogins.count) {
                [statusString appendString:@"\n"];
            }
            NSString *status = NSLocalizedString(@"SA_STR_DELIVERED_STATUS", nil);
            [statusString appendFormat:@"%@: %@", status, [deliveredLogins componentsJoinedByString:@", "]];
        }
        NSString *string = [statusString copy];
        return string.length > 0 ? string :  NSLocalizedString(@"SA_STR_SENT_STATUS", nil);
    }
    return NSLocalizedString(@"SA_STR_SENT_STATUS", nil);
}

#pragma mark - UIImagePickerController
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info {
    
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    [self showAttachmentBarWith:image];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - AttachmentBar
- (void)showAttachmentBarWith:(UIImage *)image {
    self.attachmentBar = [[AttachmentBar alloc] init];
    self.attachmentBar.delegate = self;
    [self.view addSubview:self.attachmentBar];
    
    self.attachmentBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.attachmentBar.leftAnchor constraintEqualToAnchor:self.inputToolbar.leftAnchor].active = YES;
    [self.attachmentBar.rightAnchor constraintEqualToAnchor:self.inputToolbar.rightAnchor].active = YES;
    [self.attachmentBar.bottomAnchor constraintEqualToAnchor:self.inputToolbar.topAnchor].active = YES;
    [self.attachmentBar.heightAnchor constraintEqualToConstant:100.0f].active = YES;
    
    self.attachmentBar.contentMode = UIViewContentModeScaleAspectFill;
    self.attachmentBar.layer.borderWidth = 0.5f;
    self.attachmentBar.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.attachmentBar.layer.masksToBounds = YES;
    self.attachmentBar.clipsToBounds = YES;
    [self.attachmentBar uploadAttachmentImage:image pickerControllerSourceType:self.pickerController.sourceType];
    
    self.collectionBottomConstant = 100.0f;
    self.isUploading = YES;
    [self.inputToolbar setupBarButtonEnabledLeft:NO andRight:NO];
}

- (void)hideAttacnmentBar {
    [self.attachmentBar removeFromSuperview];
    self.attachmentBar = nil;
    
    self.collectionBottomConstant = 0.0f;
    self.collectionBottomConstraint.constant = self.collectionBottomConstant;
    __weak typeof(self)weakSelf = self;
    [UIView animateWithDuration:0.03f animations:^{
        __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf.view layoutIfNeeded];
    }];
}

#pragma mark - AttachmentMessage
- (void)didPressSendButton:(UIButton *)button {
    if (self.attachmentMessage) {
        [self hideAttacnmentBar];
        
        [self sendMessage:self.attachmentMessage];
    }
    
    if ([self currentlyComposedMessageText].length) {
        QBChatMessage *message = [[QBChatMessage alloc] init];
        message.text = [self currentlyComposedMessageText];
        message.senderID = self.senderID;
        message.deliveredIDs = @[@(self.senderID)];
        message.readIDs = @[@(self.senderID)];
        message.markable = YES;
        message.dateSent = [NSDate date];
        message.customParameters[@"save_to_history"] = @"1";
        
        [self sendMessage:message];
    }
}

- (void)sendMessage:(QBChatMessage *)message {
    __weak typeof(self)weakSelf = self;
    
    [self.chatManager sendMessage:message toDialog:self.dialog completion:^(NSError * _Nullable error) {
        __typeof(weakSelf)strongSelf = weakSelf;
        if (error) {
            Log(@"%@ sendMessage error: %@",NSStringFromClass([ChatViewController class]),
                error.localizedDescription);
            return;
        }
        [strongSelf.dataSource addMessage:message];
        [strongSelf.chatManager updateDialogWith:message.dialogID withMessage:message];
        [strongSelf finishSendingMessageAnimated:YES];
    }];
}

- (QBChatMessage *)createAttachmentMessageWith:(QBChatAttachment *)attachment {
    QBChatMessage *message = [QBChatMessage new];
    message.senderID = self.senderID;
    message.dialogID = self.dialogID;
    message.dateSent = [NSDate date];
    message.text = @"[Attachment]";
    message.deliveredIDs = @[@(self.senderID)];
    message.readIDs = @[@(self.senderID)];
    message.customParameters[@"save_to_history"] = @"1";
    message.attachments = @[attachment];
    message.markable = YES;
    return message;
}

- (void)finishSendingMessageAnimated:(BOOL)animated {
    PlaceHolderTextView *textView = self.inputToolbar.contentView.textView;
    [textView setDefaultSettings];
    
    textView.text = nil;
    textView.attributedText = nil;
    [textView.undoManager removeAllActions];
    
    if (self.attachmentMessage) {
        self.attachmentMessage = nil;
    }
    
    if (self.isUploading) {
        [self.inputToolbar setupBarButtonEnabledLeft:NO andRight:NO];
    } else {
        [self.inputToolbar setupBarButtonEnabledLeft:YES andRight:NO];
    }
    
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UITextViewTextDidChangeNotification object:textView];
    
    if (self.automaticallyScrollsToMostRecentMessage) {
        [self scrollToBottomAnimated:animated];
    }
}

- (void)finishReceivingMessageAnimated:(BOOL)animated {
    if (self.automaticallyScrollsToMostRecentMessage && ![self isMenuVisible]) {
        [self scrollToBottomAnimated:animated];
    }
}

- (void)scrollToBottomAnimated:(BOOL)animated {
    if ([self.collectionView numberOfItemsInSection:0] == 0) {
        return;
    }
    
    CGPoint contentOffset = self.collectionView.contentOffset;
    if (contentOffset.y > 0.0f) {
        contentOffset.y = 0.0f;
        [self.collectionView setContentOffset:contentOffset
                                     animated:animated];
    }
}

#pragma mark - UIScrollViewDelegate
- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    // disabling scroll to bottom when tapping status bar
    return NO;
}

- (BOOL)canMakeACall {
    BOOL canMakeACall = NO;
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
            canMakeACall = YES;
        }
    } else {
        // iOS Device is not capable for making calls
    }
    return canMakeACall;
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
    } else {
        hideKeyboardBlock();
    }
}

- (void)didPressAccessoryButton:(UIButton *)sender {
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:nil
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
            } else {
                [strongSelf showAlertForAccess];
            }
        }];
        
    };
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Camera", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull __unused action) {
                                                          weakSelf.pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                                                          handler();
                                                      }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Photo Library", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull __unused action) {
                                                          weakSelf.pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                                          handler();
                                                      }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                        style:UIAlertActionStyleCancel
                                                      handler:nil]];
    
    if (alertController.popoverPresentationController) {
        // iPad support
        alertController.popoverPresentationController.sourceView = sender;
        alertController.popoverPresentationController.sourceRect = sender.bounds;
    }
    
    [self presentViewController:alertController animated:YES completion:NULL];
}

- (void)checkAuthorizationStatusWithCompletion:(void (^)(BOOL granted))completion {
    BOOL granted = NO;
    
    if (self.pickerController.sourceType == UIImagePickerControllerSourceTypeCamera) {
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        switch (status) {
            case AVAuthorizationStatusNotDetermined: {
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo
                                         completionHandler:^(BOOL granted) {
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 if (completion) {
                                                     completion(granted);
                                                 }
                                             });
                                         }];
                return;
            }
            case AVAuthorizationStatusRestricted:
            case AVAuthorizationStatusDenied:
                break;
            case AVAuthorizationStatusAuthorized: {
                granted = YES;
                break;
            }
        }
    } else if (self.pickerController.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        switch (status) {
            case PHAuthorizationStatusAuthorized: {
                granted = YES;
                break;
            }
            case PHAuthorizationStatusNotDetermined: {
                [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus authorizationStatus) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (completion) {
                            completion(authorizationStatus == PHAuthorizationStatusAuthorized);
                        }
                    });
                }];
                return;
            }
            default: break;
        }
    }
    
    if (completion) {
        completion(granted);
    }
}

- (void)showAlertForAccess {
    
    NSString *title = @"";
    NSString *message = @"";
    
    if (self.pickerController.sourceType == UIImagePickerControllerSourceTypeCamera) {
        title = NSLocalizedString(@"Camera Access Disabled", nil);
        message = NSLocalizedString(@"You can allow access to Camera in Settings", nil);
    }
    else if (self.pickerController.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        title = NSLocalizedString(@"Photos Access Disabled", nil);
        message = NSLocalizedString(@"You can allow access to Photos in Settings", nil);
    }
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:title
                                          message:message
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Open Settings", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull __unused action)
                                {
                                    [[UIApplication sharedApplication]
                                     openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]
                                     options:@{}
                                     completionHandler:nil];
                                }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                        style:UIAlertActionStyleCancel
                                                      handler:nil]];
    
    [self presentViewController:alertController animated:YES completion:nil];
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:NSLocalizedString(@"SA_STR_SEGUE_GO_TO_INFO", nil)]) {
        UsersInfoTableViewController *usersInfoViewController = segue.destinationViewController;
        usersInfoViewController.dialogID = self.dialogID;
    }
}

#pragma mark - ChatDataSourceDelegate
- (void)chatDataSource:(ChatDataSource *)chatDataSource willBeChangedWithMessageIDs:(NSArray *)messagesIDs {
    for (NSString *messageID in messagesIDs) {
        [self.collectionView.collectionViewLayout removeSizeFromCacheForItemID:messageID];
    }
}

- (void)chatDataSource:(ChatDataSource *)dataSource
    changeWithMessages:(NSArray *)messages
                action:(DataSourceActionType)action {
    if (messages.count == 0 ) {
        return;
    }
    
    dispatch_block_t batchUpdatesBlock = ^{
        NSArray *indexPaths = [self.dataSource performChangesWithMessages:messages updateType:action];
        switch (action) {
            case DataSourceActionTypeAdd:
                [self.collectionView insertItemsAtIndexPaths:indexPaths];
                break;
            case DataSourceActionTypeUpdate:
                [self.collectionView reloadItemsAtIndexPaths:indexPaths];
                break;
            case DataSourceActionTypeRemove:
                [self.collectionView deleteItemsAtIndexPaths:indexPaths];
                break;
        }
    };
    
    [self.collectionView performBatchUpdates:batchUpdatesBlock completion:nil];
}

#pragma mark - Input toolbar delegate
- (void)messagesInputToolbar:(InputToolbar *)toolbar didPressLeftBarButton:(UIButton *)sender {
    if (toolbar.sendButtonOnRight) {
        [self didPressAccessoryButton:sender];
    } else {
        [self didPressSendButton:sender];
    }
}

- (void)messagesInputToolbar:(InputToolbar *)toolbar didPressRightBarButton:(UIButton *)sender {
    if (toolbar.sendButtonOnRight) {
        [self didPressSendButton:sender];
    } else {
        [self didPressAccessoryButton:sender];
    }
}

- (NSString *)currentlyComposedMessageText {
    //  auto-accept any auto-correct suggestions
    [self.inputToolbar.contentView.textView.inputDelegate selectionWillChange:self.inputToolbar.contentView.textView];
    [self.inputToolbar.contentView.textView.inputDelegate selectionDidChange:self.inputToolbar.contentView.textView];
    
    return [self.inputToolbar.contentView.textView.text stringByTrimingWhitespace];
}

#pragma mark - Collection view data source
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.dataSource messagesCount];
}

- (UICollectionViewCell *)collectionView:(ChatCollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    QBChatMessage *messageItem = [self.dataSource messageWithIndexPath:indexPath];
    
    Class class = [self viewClassForItem:messageItem];
    NSString *itemIdentifier = [class cellReuseIdentifier];
    
    ChatCell *cell =
    [collectionView dequeueReusableCellWithReuseIdentifier:itemIdentifier
                                              forIndexPath:indexPath];
    
    [self collectionView:collectionView configureCell:cell forIndexPath:indexPath];
    
    NSInteger lastSection = collectionView.numberOfSections - 1;
    BOOL isLastItem = indexPath.item == [collectionView numberOfItemsInSection:lastSection] - 1;
    if (isLastItem && self.cancel == NO)  {
        [self loadMessagesWithSkip: [self.dataSource loadMessagesCount]];
    }
    
    return cell;
}

- (void)collectionView:(ChatCollectionView *)collectionView
         configureCell:(UICollectionViewCell *)cell
          forIndexPath:(NSIndexPath *)indexPath {
    
    QBChatMessage *messageItem = [self.dataSource messageWithIndexPath:indexPath];
    
    if ([cell isKindOfClass:[ChatNotificationCell class]]) {
        [(ChatNotificationCell *)cell notificationLabel].attributedText = [self attributedStringForItem:messageItem];
        cell.userInteractionEnabled = NO;
        cell.backgroundColor = [UIColor clearColor];
        return;
    }
    
    if ([cell isKindOfClass:[ChatCell class]]) {
        ChatCell *chatCell = (ChatCell *)cell;
        if ([cell isKindOfClass:[ChatIncomingCell class]] || [cell isKindOfClass:[ChatOutgoingCell class]]) {
            chatCell.textView.enabledTextCheckingTypes = self.enableTextCheckingTypes;
        }
        
        chatCell.delegate = self;
        chatCell.topLabel.text = [self topLabelAttributedStringForItem:messageItem];
        chatCell.textView.text = [self attributedStringForItem:messageItem];
        chatCell.bottomLabel.text = [self bottomLabelAttributedStringForItem:messageItem];
    }
    
    if ([cell isKindOfClass:[ChatAttachmentCell class]]) {
        ChatAttachmentCell *chatAttachmentCell = (ChatAttachmentCell *)cell;
        cell.userInteractionEnabled = YES;
        QBChatAttachment *attachment = messageItem.attachments.firstObject;
        chatAttachmentCell.attachmentID = attachment.ID;
        if (attachment && attachment.ID && [attachment.type isEqualToString:@"image"]) {
            [chatAttachmentCell setupAttachmentImageWithID:attachment.ID];
        }
    }
}

- (void)collectionView:(ChatCollectionView *)collectionView
       willDisplayCell:(nonnull UICollectionViewCell *)cell
    forItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    if (self.isDeviceLocked) {
        return;
    }
    
    QBChatMessage *message = [self.dataSource messageWithIndexPath:indexPath];
    
    if (![message.readIDs containsObject:@(self.senderID)]) {
        [self.chatManager readMessages:@[message] dialog:self.dialog completion:^(NSError * _Nullable error) {
            if (error != nil) {
                Log(@"%@ readMessages error: %@",NSStringFromClass([ChatViewController class]),
                    error.localizedDescription);
            }
        }];
    }
}

- (void)collectionView:(ChatCollectionView *)collectionView
  didEndDisplayingCell:(nonnull UICollectionViewCell *)cell
    forItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[ChatAttachmentCell class]]) {
        ChatAttachmentCell *chatAttachmentCell = (ChatAttachmentCell *)cell;
        if (chatAttachmentCell.attachmentID) {
            AttachmentDownloadManager *attachmentDownloadManager = [[AttachmentDownloadManager alloc] init];
            [attachmentDownloadManager slowDownloadAttachmentWithID:chatAttachmentCell.attachmentID];
        }
    }
}

#pragma mark - Collection view delegate flow layout
- (CGSize)collectionView:(ChatCollectionView *)collectionView
  dynamicSizeAtIndexPath:(NSIndexPath *)indexPath
                maxWidth:(CGFloat)maxWidth {
    QBChatMessage *item = [self.dataSource messageWithIndexPath:indexPath];
    Class viewClass = [self viewClassForItem:item];
    
    CGSize size = CGSizeZero;
    if (viewClass == [ChatAttachmentIncomingCell class]) {
        size = CGSizeMake(MIN(200, maxWidth), 200);
    } else if (viewClass == [ChatAttachmentOutgoingCell class]) {
        NSAttributedString *attributedString = [self bottomLabelAttributedStringForItem:item];
        CGSize bottomLabelSize = [TTTAttributedLabel sizeThatFitsAttributedString:attributedString
                                                                  withConstraints:CGSizeMake(MIN(200, maxWidth), CGFLOAT_MAX)
                                                           limitedToNumberOfLines:0];
        size = CGSizeMake(MIN(200, maxWidth), 200 + ceilf(bottomLabelSize.height));
    } else if (viewClass == [ChatNotificationCell class]) {
        NSAttributedString *attributedString = [self attributedStringForItem:item];
        size = [TTTAttributedLabel sizeThatFitsAttributedString:attributedString
                                                withConstraints:CGSizeMake(maxWidth, CGFLOAT_MAX)
                                         limitedToNumberOfLines:0];
    } else {
        NSAttributedString *attributedString = [self attributedStringForItem:item];
        size = [TTTAttributedLabel sizeThatFitsAttributedString:attributedString
                                                withConstraints:CGSizeMake(maxWidth, CGFLOAT_MAX)
                                         limitedToNumberOfLines:0];
    }
    return size;
}

- (CGFloat)collectionView:(ChatCollectionView *)collectionView minWidthAtIndexPath:(NSIndexPath *)indexPath {
    
    QBChatMessage *item = [self.dataSource messageWithIndexPath:indexPath];
    
    CGSize size = CGSizeZero;
    size = [TTTAttributedLabel sizeThatFitsAttributedString:[self bottomLabelAttributedStringForItem:item]
                                            withConstraints:CGSizeMake(CGRectGetWidth(self.collectionView.frame) - widthPadding, CGFLOAT_MAX)
                                     limitedToNumberOfLines:0];
    
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

- (NSString *)collectionView:(ChatCollectionView *)collectionView
           itemIdAtIndexPath:(nonnull NSIndexPath *)indexPath {
    QBChatMessage *item = [self.dataSource messageWithIndexPath:indexPath];
    return item.ID;
}

- (CGSize)collectionView:(ChatCollectionView *)collectionView
                  layout:(ChatCollectionViewFlowLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [collectionViewLayout sizeForItemAtIndexPath:indexPath];
}

- (ChatCellLayoutModel)collectionView:(ChatCollectionView *)collectionView
               layoutModelAtIndexPath:(NSIndexPath *)indexPath {
    QBChatMessage *item = [self.dataSource messageWithIndexPath:indexPath];
    Class class = [self viewClassForItem:item];
    ChatCellLayoutModel layoutModel = [class layoutModel];
    CGSize constraintsSize = CGSizeMake(self.collectionView.frame.size.width - widthPadding, CGFLOAT_MAX);
    CGSize size = [TTTAttributedLabel sizeThatFitsAttributedString:[self bottomLabelAttributedStringForItem:item]
                                                   withConstraints:constraintsSize
                                            limitedToNumberOfLines:0];
    layoutModel.bottomLabelHeight = floorf(size.height);
    layoutModel.topLabelHeight = 22.0f;
    
    if (self.dialog.type == QBChatDialogTypePrivate ||
        class == ChatOutgoingCell.self ||
        class == ChatAttachmentOutgoingCell.self ) {
        layoutModel.avatarSize = CGSizeZero;
        layoutModel.topLabelHeight = 0.0f;
    }
    
    return layoutModel;
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
    if (self.isUploading || self.attachmentMessage) {
        [self.inputToolbar setupBarButtonEnabledLeft:NO andRight:YES];
    } else {
        [self.inputToolbar setupBarButtonEnabledLeft:YES andRight:YES];
    }
}

#pragma mark - ChatCellDelegate
- (void)chatCellDidTapContainer:(ChatCell *)cell {
    if ([cell isKindOfClass:[ChatAttachmentCell class]]) {
        ChatAttachmentCell *chatAttachmentCell = (ChatAttachmentCell *)cell;
        UIImage *attachmentImage = chatAttachmentCell.attachmentImageView.image;
        if (attachmentImage) {
            [self openAttachmentImage:attachmentImage];
        }
    }
}

- (void)openAttachmentImage:(UIImage *)image {
    ZoomedAttachmentViewController *zoomedVC = [[ZoomedAttachmentViewController alloc] initWithImage:image];
    zoomedVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    zoomedVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:zoomedVC animated:YES completion:nil];
}

- (void)chatCell:(ChatCell *)__unused cell
didTapOnTextCheckingResult:(NSTextCheckingResult *)textCheckingResult {
    
    switch (textCheckingResult.resultType) {
        case NSTextCheckingTypeLink: {
            if ([SFSafariViewController class] != nil &&
                // SFSafariViewController supporting only http and https schemes
                ([textCheckingResult.URL.scheme.lowercaseString isEqualToString:@"http"] ||
                 [textCheckingResult.URL.scheme.lowercaseString isEqualToString:@"https"])) {
                    SFSafariViewController *controller = [[SFSafariViewController alloc]
                                                          initWithURL:textCheckingResult.URL
                                                          entersReaderIfAvailable:NO];
                    
                    [self presentViewController:controller animated:YES completion:nil];
                } else if ([[UIApplication sharedApplication] canOpenURL:textCheckingResult.URL]) {
                    [[UIApplication sharedApplication] openURL:textCheckingResult.URL
                                                       options:@{}
                                             completionHandler:nil];
                }
            break;
        }
        case NSTextCheckingTypePhoneNumber: {
            if ([self canMakeACall] == NO) {
                [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"Your Device can't make a phone call", nil)
                                         maskType:SVProgressHUDMaskTypeNone];
                break;
            }
            
            NSString *urlString = [NSString stringWithFormat:@"tel:%@", textCheckingResult.phoneNumber];
            NSURL *url = [NSURL URLWithString:urlString];
            
            [self.view endEditing:YES];
            
            UIAlertController *alertController = [UIAlertController
                                                  alertControllerWithTitle:nil
                                                  message:textCheckingResult.phoneNumber
                                                  preferredStyle:UIAlertControllerStyleAlert];
            
            [alertController addAction:[UIAlertAction
                                        actionWithTitle:NSLocalizedString(@"SA_STR_CANCEL", nil)
                                        style:UIAlertActionStyleCancel
                                        handler:nil]];
            
            [alertController addAction:[UIAlertAction
                                        actionWithTitle:NSLocalizedString(@"SA_STR_CALL", nil)
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * _Nonnull __unused action) {
                                            [[UIApplication sharedApplication] openURL:url
                                                                               options:@{}
                                                                     completionHandler:nil];
                                        }]];
            
            [self presentViewController:alertController animated:YES completion:nil];
            
            break;
        }
            
        default: break;
    }
}

#pragma mark - QBChatDelegate
- (void)chatDidReadMessageWithID:(NSString *)messageID
                        dialogID:(NSString *)dialogID
                        readerID:(NSUInteger)readerID {
    if (self.senderID == readerID || ![dialogID isEqualToString:self.dialogID]) {
        return;
    }
    QBChatMessage *currentMessage = [self.dataSource messageWithID:messageID];
    if (currentMessage) {
        NSMutableArray *readIDs = [currentMessage.readIDs mutableCopy];
        [readIDs addObject:@(readerID)];
        [currentMessage setReadIDs: [readIDs copy]];
        [self.dataSource updateMessage:currentMessage];
    }
}

- (void)chatDidDeliverMessageWithID:(NSString *)messageID dialogID:(NSString *)dialogID toUserID:(NSUInteger)userID {
    if (self.senderID == userID || ![dialogID isEqualToString:self.dialogID]) {
        return;
    }
    QBChatMessage *currentMessage = [self.dataSource messageWithID:messageID];
    if (currentMessage) {
        QBChatMessage *currentMessage = [self.dataSource messageWithID:messageID];
        NSMutableArray *deliveredIDs = [currentMessage.deliveredIDs mutableCopy];
        [deliveredIDs addObject:@(userID)];
        [currentMessage setDeliveredIDs: [deliveredIDs copy]];
        [self.dataSource updateMessage:currentMessage];
    }
}

- (void)chatDidReceiveMessage:(QBChatMessage *)message {
    if ([message.dialogID isEqualToString: self.dialogID]) {
        [self.dataSource addMessage:message];
    }
}

- (void)chatRoomDidReceiveMessage:(QBChatMessage *)message fromDialogID:(NSString *)dialogID {
    if ([dialogID isEqualToString: self.dialogID]) {
        [self.dataSource addMessage:message];
    }
}

- (void)chatDidConnect {
    if ([QBChat.instance isConnected]) {
        [self refreshAndReadMessages];
    }
}

- (void)chatDidReconnect {
    if ([QBChat.instance isConnected]) {
        [self refreshAndReadMessages];
    }
}

- (void)refreshAndReadMessages {
    [self loadMessagesWithSkip:0];
}

#pragma mark - AttachmentBarDelegate
- (void)attachmentBar:(AttachmentBar *)attachmentBar didUpLoadAttachment:(QBChatAttachment *)attachment {
    self.attachmentMessage = [self createAttachmentMessageWith:attachment];
    self.isUploading = NO;
    [self.inputToolbar setupBarButtonEnabledLeft:NO andRight:YES];
}

- (void)attachmentBar:(AttachmentBar *)attachmentBar didTapCancelButton:(UIButton *)sender {
    self.attachmentMessage = nil;
    [self.inputToolbar setupBarButtonEnabledLeft:YES andRight:NO];
    [self hideAttacnmentBar];
}

- (void)attachmentBarFailedUpLoadImage:(AttachmentBar *)attachmentBar {
    [self cancelUploadFile];
}

@end
