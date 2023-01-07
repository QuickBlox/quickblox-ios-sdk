//
//  ChatViewController.m
//  sample-chat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "ChatViewController.h"
#import "ChatCollectionView.h"
#import "ChatDataSource.h"
#import "InputToolbar.h"
#import "KVOView.h"
#import "HeaderCollectionReusableView.h"
#import "QBChatMessage+Chat.h"
#import "ChatNotificationCell.h"
#import "ChatIncomingCell.h"
#import "ChatOutgoingCell.h"
#import "ChatAttachmentOutgoingCell.h"
#import "ChatAttachmentIncomingCell.h"
#import "AttachmentUploadBar.h"
#import "ChatResources.h"
#import "UIColor+Chat.h"
#import "UIView+Chat.h"
#import "NSString+Chat.h"
#import "NSURL+Chat.h"
#import "UIImage+fixOrientation.h"
#import "DateUtils.h"
#import "AttachmentDownloadManager.h"
#import "ZoomedAttachmentViewController.h"
#import <Photos/Photos.h>
#import "Log.h"
#import "QBUUser+Chat.h"
#import "ChatPrivateTitleView.h"
#import "TypingView.h"
#import "ParentVideoVC.h"
#import "ImageCache.h"
#import "DialogsSelectionViewController.h"
#import "ChatDateCell.h"
#import "SelectAssetsVC.h"
#import "PhotoAsset.h"
#import "UIViewController+ContextMenu.h"
#import "UIViewController+Alert.h"
#import "UINavigationController+Appearance.h"
#import "QBChatMessage+Chat.h"
#import "ProgressView.h"
#import "InfoUsersController.h"
#import "ViewedByViewController.h"
#import "ChatButtonFactory.h"
#import "QBChatAttachment+Chat.h"

typedef NS_ENUM(NSUInteger, MessageStatus) {
    MessageStatusSent = 1,
    MessageStatusSending = 2,
    MessageStatusNotSent = 3,
};

static NSUInteger const kMessagesLimitPerDialog = 30;

static void * kChatKeyValueObservingContext = &kChatKeyValueObservingContext;

const NSUInteger kSystemInputToolbarDebugHeight = 0;
static const CGFloat attachmentBarHeight = 100.0f;
static const NSUInteger maxNumberLetters = 1000;

@interface ChatViewController () <InputToolbarDelegate, UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UIActionSheetDelegate, UIScrollViewDelegate, UITextViewDelegate,
ChatDataSourceDelegate, QBChatDelegate, ChatCellDelegate, ChatCollectionViewDelegateFlowLayout, AttachmentBarDelegate, ChatContextMenuProtocol>


@property (weak, nonatomic) IBOutlet ChatCollectionView *collectionView;
@property (weak, nonatomic) IBOutlet InputToolbar *inputToolbar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionBottomConstraint;
@property (weak, nonatomic) IBOutlet ChatCollectionViewFlowLayout *chatFlowLayout;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolbarHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolbarBottomLayoutGuide;

@property (strong, nonatomic) QBChatDialog *dialog;
@property (strong, nonatomic) NSString *senderDisplayName;
@property (assign, nonatomic) NSUInteger senderID;
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

@property (strong, nonatomic) QBChatMessage *attachmentMessage;
@property (strong, nonatomic) AttachmentUploadBar *attachmentBar;
@property (strong, nonatomic) ChatPrivateTitleView *chatPrivateTitleView;
@property (strong, nonatomic) UIBarButtonItem *infoItem;

@property (assign, nonatomic) NSUInteger inputToolBarStartPosition;
@property (assign, nonatomic) CGFloat collectionBottomConstant;

@property (strong, nonatomic) TypingView *typingView;
@property (strong, nonatomic) NSMutableSet *onlineUsersIDs;
@property (strong, nonatomic) NSMutableSet *typingUsers;
@property (strong, nonatomic) NSTimer *privateUserIsTypingTimer;
@property (strong, nonatomic) NSTimer *stopTimer;
@property (nonatomic, strong) ProgressView *progressView;

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

    self.chatManager = [ChatManager instance];
    self.dialog =  [self.chatManager.storage dialogWithID:self.dialogID];
    
    if (!self.dialog) {
        [self goBack];
        return;
    }
    
    self.dataSource = [[ChatDataSource alloc] init];
    self.dataSource.delegate = self;
    
    [QBChat.instance addDelegate: self];
    
    [self setupViewMessages];
    self.isDeviceLocked = NO;
    
    self.onlineUsersIDs = [NSMutableSet set];
    self.typingUsers = [NSMutableSet set];
    self.typingView = [[TypingView alloc] init];
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"chevron"]
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(didTapBack:)];
    
    self.navigationItem.leftBarButtonItem = backButtonItem;
    backButtonItem.tintColor = UIColor.whiteColor;
     
    self.progressView = [[NSBundle mainBundle] loadNibNamed:@"ProgressView" owner:nil options:nil].firstObject;
    
    //Customize your toolbar buttons
    self.inputToolbar.contentView.leftBarButtonItem = [ChatButtonFactory accessoryButtonItem];
    self.inputToolbar.contentView.rightBarButtonItem = [ChatButtonFactory sendButtonItem];
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
    self.topContentAdditionalInset = 28.0f;
    self.inputToolBarStartPosition = 0;
    self.collectionBottomConstant = 0.0;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.inputToolbar toggleSendButtonEnabledIsUploaded:self.isUploading];
    
    if (!QBSession.currentSession.currentUser) {
        return;
    }
    
    Profile *currentUser = [[Profile alloc] init];
    if (currentUser.isFull == NO) {
        return;
    }
    self.senderDisplayName = currentUser.fullName;
    self.senderID = currentUser.ID;
    
    [self setupTitleView];
    
    self.inputToolbar.delegate = self;
    if (self.inputToolbar.contentView.textView.isFirstResponder == NO) {
        self.toolbarBottomLayoutGuide.constant = (CGFloat)self.inputToolBarStartPosition;
    }
    
    [self updateCollectionViewInsets];
    self.collectionBottomConstraint.constant = self.collectionBottomConstant;
    
    if (self.dialog.type != QBChatDialogTypePublicGroup) {
        NSString *deleteTitle = @"Delete Chat";
        if (self.dialog.type == QBChatDialogTypeGroup) {
            deleteTitle = @"Leave Chat";
        }
        __weak __typeof(self) weakSelf = self;
        UIAction *leaveChatAction = [UIAction actionWithTitle:deleteTitle
                                                        image:nil
                                                   identifier:nil
                                                      handler:^(__kindof UIAction * _Nonnull action) {
            [weakSelf didTapDelete];
        }];
        
        UIAction *chatInfoAction = [UIAction actionWithTitle:@"Chat info"
                                                       image:nil
                                                  identifier:nil
                                                     handler:^(__kindof UIAction * _Nonnull action) {
            InfoUsersController *usersInfoViewController = [[InfoUsersController alloc] initWithNonDisplayedUsers:@[]];
            usersInfoViewController.dialogID = self.dialogID;
            [self.navigationController pushViewController:usersInfoViewController animated:YES];
        }];
        NSArray *children = @[leaveChatAction];
        if (self.dialog.type == QBChatDialogTypeGroup) {
            children = @[chatInfoAction, leaveChatAction];
        }
        UIMenu *menu = [UIMenu menuWithTitle:@"" children: children];
        self.infoItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"moreInfo"] menu:menu];
        self.navigationItem.rightBarButtonItem = self.infoItem;
        self.infoItem.tintColor = UIColor.whiteColor;
    }
    
    if (QBChat.instance.isConnected == NO) {
        [self showNoInternetAlertWithHandler:nil];
        return;
    }
    [self loadMessagesWithSkip:0];
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    __weak __typeof(self)weakSelf = self;
    self.observerWillResignActive = [defaultCenter addObserverForName: UIApplicationWillResignActiveNotification
                                                               object:nil
                                                                queue:nil
                                                           usingBlock:^(NSNotification * _Nonnull note) {
        __typeof(weakSelf)strongSelf = weakSelf;
        strongSelf.isDeviceLocked = YES;
    }];
    self.observerWillActive = [defaultCenter addObserverForName: UIApplicationDidBecomeActiveNotification
                                                         object:nil
                                                          queue:nil
                                                     usingBlock:^(NSNotification * _Nonnull note) {
        __typeof(weakSelf)strongSelf = weakSelf;
        strongSelf.isDeviceLocked = NO;
        [strongSelf.collectionView reloadData];
    }];
    
    //request Online Users for group and public chats
    if (self.dialog.type != QBChatDialogTypePrivate) {
        [self.dialog requestOnlineUsersWithCompletionBlock:^(NSMutableArray<NSNumber *> * _Nullable onlineUsers, NSError * _Nullable error) {
            if (onlineUsers) {
                for (NSNumber *userID in onlineUsers) {
                    if (userID.unsignedIntValue != self.senderID) {
                        [self.onlineUsersIDs addObject:userID];
                    }
                }
            } else if (error) {
                Log(@"%@ requestOnlineUsers error: %@",NSStringFromClass([ChatViewController class]), error.localizedDescription);
            }
        }];
        
        self.dialog.onJoinOccupant = ^(NSUInteger userID) {
            if (userID == self.senderID) {
                return;
            }
            [weakSelf.onlineUsersIDs addObject:@(userID)];
        };
        
        self.dialog.onLeaveOccupant = ^(NSUInteger userID) {
            if (userID == self.senderID) {
                return;
            }
            [weakSelf.onlineUsersIDs removeObject:@(userID)];
            [weakSelf handlerStopTypingUser:@(userID)];
        };
    }
    
    if (self.dialog.type == QBChatDialogTypePrivate) {
        // handling typing status
        self.dialog.onUserIsTyping = ^(NSUInteger userID) {
            
            if (userID == self.senderID) {
                return;
            }
            [weakSelf.typingUsers addObject:@(userID)];
            [weakSelf.typingView setupTypingViewWithOpponentUsersIDs:weakSelf.typingUsers];
            [weakSelf showTypingView];
            
            if (weakSelf.privateUserIsTypingTimer) {
                [weakSelf.privateUserIsTypingTimer invalidate];
                weakSelf.privateUserIsTypingTimer = nil;
            }
            
            weakSelf.privateUserIsTypingTimer = [NSTimer scheduledTimerWithTimeInterval:10.0f
                                                                                 target:weakSelf
                                                                               selector:@selector(hideTypingView)
                                                                               userInfo:nil
                                                                                repeats:NO];
        };
        
        // Handling user stopped typing.
        self.dialog.onUserStoppedTyping = ^(NSUInteger userID) {
            if (userID == self.senderID) {
                return;
            }
            [weakSelf handlerStopTypingUser:@(userID)];
        };
        
    } else {
        
        // handling typing status for Group
        self.dialog.onUserIsTyping = ^(NSUInteger userID) {
            
            if (userID == self.senderID) {
                return;
            }
            [weakSelf.typingUsers addObject:@(userID)];
            [weakSelf.typingView setupTypingViewWithOpponentUsersIDs:weakSelf.typingUsers];
            [weakSelf showTypingView];
        };
        
        // Handling user stopped typing.
        self.dialog.onUserStoppedTyping = ^(NSUInteger userID) {
            if (userID == self.senderID) {
                return;
            }
            [weakSelf handlerStopTypingUser:@(userID)];
        };
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.progressView stop];
    
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
- (void)showTypingView {
    if ([self.view.subviews containsObject:self.typingView]) { return; }
    [self.view addSubview:self.typingView];
    self.typingView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.typingView.leftAnchor constraintEqualToAnchor:self.inputToolbar.leftAnchor].active = YES;
    [self.typingView.rightAnchor constraintEqualToAnchor:self.inputToolbar.rightAnchor].active = YES;
    [self.typingView.bottomAnchor constraintEqualToAnchor:self.inputToolbar.topAnchor].active = YES;
    [self.typingView.heightAnchor constraintEqualToConstant:self.topContentAdditionalInset].active = YES;
    self.collectionBottomConstraint.constant = self.collectionBottomConstant + self.topContentAdditionalInset;
}

- (void)hideTypingView {
    [self.typingView removeFromSuperview];
    self.collectionBottomConstant = 0.0f;
    self.collectionBottomConstraint.constant = self.collectionBottomConstant;
    __weak __typeof(self)weakSelf = self;
    [UIView animateWithDuration:0.3f animations:^{
        [weakSelf.view layoutIfNeeded];
    }];
    [self.privateUserIsTypingTimer invalidate];
    self.privateUserIsTypingTimer = nil;
}

- (void)stopTyping {
    [self.stopTimer invalidate];
    self.stopTimer = nil;
    [self.dialog sendUserStoppedTyping];
}

- (void)sendIsTypingStatus {
    [self.dialog sendUserIsTyping];
    [self.stopTimer invalidate];
    self.stopTimer = nil;
    
    self.stopTimer = [NSTimer scheduledTimerWithTimeInterval:6.0f
                                                      target:self
                                                    selector:@selector(stopTyping)
                                                    userInfo:nil
                                                     repeats:NO];
}

- (void)handlerStopTypingUser:(NSNumber *)userId {
    if (![self.typingUsers containsObject:userId]) {
        return;
    }
    [self.typingUsers removeObject:userId];
    if (!self.typingUsers.count) {
        [self hideTypingView];
        return;
    }
    [self.typingView setupTypingViewWithOpponentUsersIDs:self.typingUsers];
}

- (void)cancelUploadFile {
    [self hideAttacnmentBar];
    self.isUploading = NO;
    __weak __typeof(self)weakSelf = self;
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Error"
                                          message:@"Attachment failed to Upload"
                                          preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf.inputToolbar toggleSendButtonEnabledIsUploaded:self.isUploading];
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

#pragma mark - Setup
- (void)setupTitleView {
    if (self.dialog.type == QBChatDialogTypePrivate) {
        NSUInteger userID = 0;
        for (NSNumber *num in self.dialog.occupantIDs) {
            if (num.unsignedIntegerValue != self.senderID) {
                userID = num.unsignedIntegerValue;
            }
        }
        self.chatPrivateTitleView = [[ChatPrivateTitleView alloc] init];
        QBUUser *opponentUser = [self.chatManager.storage userWithID:userID];
        if (opponentUser) {
            [self.chatPrivateTitleView setupPrivateChatTitleViewWithOpponentUser:opponentUser];
            self.navigationItem.titleView = self.chatPrivateTitleView;
        } else {
            [self.chatManager loadUserWithID:userID completion:^(QBUUser * _Nullable opponentUser) {
                if (opponentUser) {
                    [self.chatPrivateTitleView setupPrivateChatTitleViewWithOpponentUser:opponentUser];
                    self.navigationItem.titleView = self.chatPrivateTitleView;
                }
            }];
        }
    } else {
        self.title = self.dialog.name;
    }
}

- (Class)viewClassForItem:(QBChatMessage *)item {
    if (item.isNotificationMessage) {
        return [ChatNotificationCell class];
    }
    if (item.isDateDividerMessage) {
        return [ChatDateCell class];
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

- (void)loadMessagesWithSkip:(NSInteger)skip {
    [self.progressView start];
    [self.chatManager messagesWithDialogID:self.dialog.ID
                           extendedRequest:nil
                                      skip:skip
                                     limit:kMessagesLimitPerDialog
                                   success:^(NSArray<QBChatMessage *> * _Nonnull messages, Boolean isLast) {
        self.cancel = isLast;
        [self.dataSource addMessages:messages];
        [self.progressView stop];
    } errorHandler:^(NSString * _Nonnull error) {
        if ([error isEqualToString:@"Dialog has been removed"]) {
            [self.dataSource clear];
            [self.dialog clearTypingStatusBlocks];
            self.inputToolbar.userInteractionEnabled = NO;
            self.collectionView.scrollEnabled = NO;
            [self.collectionView reloadData];
            self.title = @"";
            self.navigationItem.rightBarButtonItem.enabled = NO;
        }
        [self.progressView stop];
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
    [ChatDateCell registerForReuseInView:self.collectionView];
}

#pragma mark - Actions
- (void)didTapBack:(UIButton *)sender {
    [self goBack];
}

- (void)goBack {
    [QBChat.instance removeDelegate:self];
    [self finishSendingMessageAnimated:NO];
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)didTapDelete {
    if (QBChat.instance.isConnected == NO || self.dialog.type == QBChatDialogTypePublicGroup) {
        [self showNoInternetAlertWithHandler:nil];
        return;
    }
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Warning" message:@"Do you really want to leave selected dialog?" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    NSString *deleteMessage = self.dialog.type == QBChatDialogTypeGroup ? @"Leave" : @"Delete";
    UIAlertAction *leaveAction = [UIAlertAction actionWithTitle:deleteMessage style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.progressView start];
        self.infoItem.enabled = NO;
        [self.chatManager leaveDialogWithID:self.dialog.ID completion:^(NSString * _Nullable error) {
            [self.progressView stop];
            [self goBack];
        }];
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:leaveAction];
    [self presentViewController:alertController animated:NO completion:nil];
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
    self.attachmentBar = [[NSBundle mainBundle] loadNibNamed:@"AttachmentUploadBar" owner:nil options:nil].firstObject;
    self.attachmentBar.delegate = self;
    [self.view addSubview:self.attachmentBar];
    self.attachmentBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.attachmentBar.leftAnchor constraintEqualToAnchor:self.inputToolbar.leftAnchor].active = YES;
    [self.attachmentBar.rightAnchor constraintEqualToAnchor:self.inputToolbar.rightAnchor].active = YES;
    [self.attachmentBar.bottomAnchor constraintEqualToAnchor:self.inputToolbar.topAnchor].active = YES;
    [self.attachmentBar.heightAnchor constraintEqualToConstant:attachmentBarHeight].active = YES;
    [self.attachmentBar uploadAttachmentImage:image pickerControllerSourceType:self.pickerController.sourceType];
    self.collectionBottomConstant = attachmentBarHeight;
    self.collectionBottomConstraint.constant = self.collectionBottomConstant;
    self.isUploading = YES;
    [self.inputToolbar toggleSendButtonEnabledIsUploaded:self.isUploading];
}

- (void)hideAttacnmentBar {
    self.isUploading = NO;
    [self.inputToolbar toggleSendButtonEnabledIsUploaded:self.isUploading];
    [self.attachmentBar removeFromSuperview];
    self.attachmentBar.attachmentImageView.image = nil;
    self.collectionBottomConstant = 0.0f;
    self.collectionBottomConstraint.constant = self.collectionBottomConstant;
    __weak typeof(self)weakSelf = self;
    [UIView animateWithDuration:0.03f animations:^{
        __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf.view layoutIfNeeded];
    }];
}

#pragma mark - Send Message
- (void)didPressSendButton:(UIButton *)button {
    [self stopTyping];
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
    if (QBChat.instance.isConnected == NO) {
        [self showNoInternetAlertWithHandler:nil];
        return;
    }
    __weak typeof(self)weakSelf = self;
    void(^sendMessage)(void) = ^(void) {
        [self.chatManager sendMessage:message toDialog:self.dialog completion:^(NSError * _Nullable error) {
            if (error) {
                // Autojoin to the group chat
                Log(@"[%@] dialog join error: %@",
                    NSStringFromClass([ChatViewController class]),
                    error.localizedDescription);
            }
            [weakSelf.dataSource addMessage:message];
            [weakSelf finishSendingMessageAnimated:YES];
        }];
    };
    if (self.dialog.type == QBChatDialogTypePrivate || self.dialog.isJoined) {
        sendMessage();
        return;
    }
    [self.dialog joinWithCompletionBlock:^(NSError *error) {
        if (error) {
            Log(@"[%@] dialog join error: %@",
                NSStringFromClass([ChatViewController class]),
                error.localizedDescription);
            return;
        } else {
            sendMessage();
        }
    }];
}

- (QBChatMessage *)createAttachmentMessageWith:(QBChatAttachment *)attachment {
    QBChatMessage *message = [QBChatMessage new];
    message.senderID = self.senderID;
    message.dialogID = self.dialog.ID;
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
    textView.placeHolder = @"Send message";
    [textView.undoManager removeAllActions];
    
    if (self.attachmentMessage) {
        self.attachmentMessage = nil;
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

#pragma mark - UIScrollViewDelegate
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

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    // disabling scroll to bottom when tapping status bar
    return NO;
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
    !animated ? [UIView performWithoutAnimation:hideKeyboardBlock] : hideKeyboardBlock();
}

- (void)didPressAccessoryButton:(UIButton *)sender {
    if (self.isUploading) {
        [self showAlertWithTitle:@"You can send 1 attachment per message" message:nil handler:nil];
    } else {
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:nil
                                              message:nil
                                              preferredStyle:UIAlertControllerStyleActionSheet];
        
        __weak __typeof(self) weakSelf = self;
        
        void(^handlerWithSourceType)(UIImagePickerControllerSourceType sourceType) = ^(UIImagePickerControllerSourceType sourceType){
            [self checkAuthorizationStatusWithSourceType:sourceType completion:^(BOOL granted) {
                typeof(weakSelf) strongSelf = weakSelf;
                
                if (granted) {
                    if (sourceType == UIImagePickerControllerSourceTypeCamera) {
                        [strongSelf presentViewController:self.pickerController
                                                 animated:YES
                                               completion:nil];
                        
                    } else if (sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
                        [strongSelf showAllAssets];
                    }
                } else {
                    [strongSelf showAlertForAccess];
                }
            }];
        };
        
#if TARGET_OS_SIMULATOR
        Log(@"%@ targetEnvironment simulator");
#else
        [alertController addAction:[UIAlertAction actionWithTitle:@"Camera"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull __unused action) {
            weakSelf.pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            handlerWithSourceType(UIImagePickerControllerSourceTypeCamera);
        }]];
#endif
        [alertController addAction:[UIAlertAction actionWithTitle:@"Photo"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull __unused action) {
            weakSelf.pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            handlerWithSourceType(UIImagePickerControllerSourceTypePhotoLibrary);
        }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                                            style:UIAlertActionStyleCancel
                                                          handler:nil]];
        
        if (alertController.popoverPresentationController) {
            // iPad support
            alertController.popoverPresentationController.sourceView = sender;
            alertController.popoverPresentationController.sourceRect = sender.bounds;
        }
        [self presentViewController:alertController animated:YES completion:NULL];
    }
}

- (void)showAllAssets {
    SelectAssetsVC *selectAssetsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectAssetsVC"];
    selectAssetsVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    __weak __typeof(self) weakSelf = self;
    selectAssetsVC.selectedImage = ^(UIImage *image) {
        if (image) {
            [weakSelf showAttachmentBarWith:image];
        }
    };
    [self presentViewController:selectAssetsVC animated:NO completion:nil];
}

- (void)checkAuthorizationStatusWithSourceType:(UIImagePickerControllerSourceType)sourceType completion:(void (^)(BOOL granted))completion {
    BOOL granted = NO;
    
    if (sourceType == UIImagePickerControllerSourceTypeCamera) {
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
    } else if (sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        switch (status) {
            case PHAuthorizationStatusAuthorized: {
                granted = YES;
                break;
            }
            case PHAuthorizationStatusLimited: {
                granted = YES;
                break;
            }
            case PHAuthorizationStatusRestricted: {
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
        title = @"Camera Access Disabled";
        message = @"You can allow access to Camera in Settings";
    }
    else if (self.pickerController.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        title = @"Photos Access Disabled";
        message = @"You can allow access to Photos in Settings";
    }
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:title
                                          message:message
                                          preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Open Settings"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull __unused action)
                                {
        [[UIApplication sharedApplication]
         openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]
         options:@{}
         completionHandler:nil];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel"
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
    toolbar.sendButtonOnRight ? [self didPressAccessoryButton:sender] : [self didPressSendButton:sender];
}

- (void)messagesInputToolbar:(InputToolbar *)toolbar didPressRightBarButton:(UIButton *)sender {
    toolbar.sendButtonOnRight ? [self didPressSendButton:sender] : [self didPressAccessoryButton:sender];
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
    QBChatMessage *message = [self.dataSource messageWithIndexPath:indexPath];
    if (message.senderID != self.senderID && ![message.readIDs containsObject:@(self.senderID)]) {
        if (![QBChat.instance isConnected]) {
            [self.dataSource addMessageForRead:message];
        } else {
            [self.chatManager readMessage:message dialog:self.dialog completion:^(NSError * _Nullable error) {
                if (!error) {
                    NSMutableArray *readIDs = [message.readIDs mutableCopy];
                    [readIDs addObject:@(self.senderID)];
                    [message setReadIDs: [readIDs copy]];
                    [self.dataSource updateMessage:message];
                    [self.dataSource removeMessageForRead:message];
                }
            }];
        }
    }
    if ([cell isKindOfClass:[ChatDateCell class]])  {
        ChatDateCell *dateCell = (ChatDateCell *)cell;
        dateCell.userInteractionEnabled = NO;
        dateCell.dateLabel.text = message.messageText.string;
        return;
    }
    if ([cell isKindOfClass:[ChatNotificationCell class]]) {
        [(ChatNotificationCell *)cell notificationLabel].text = message.messageText.string;
        cell.userInteractionEnabled = NO;
        return;
    }
    if ([cell isKindOfClass:[ChatCell class]]) {
        ChatCell *chatCell = (ChatCell *)cell;
        NSAttributedString *userNameAttributedString = message.topLabelText;
        NSString *userName = userNameAttributedString.string;
        NSCharacterSet *characterSet = [NSCharacterSet whitespaceCharacterSet];
        NSString *name = [userName stringByTrimmingCharactersInSet:characterSet];
        if ([cell isKindOfClass:[ChatIncomingCell class]] && self.dialog.type != QBChatDialogTypePrivate) {
            NSString *firstLetter = [name substringToIndex:1];
            chatCell.avatarLabel.text = [firstLetter uppercaseString];
            chatCell.avatarLabel.backgroundColor = [UIColor colorWithHexString:[NSString stringWithFormat:@"#%lX",
                                                                                (unsigned long)message.senderID]];
        }
        chatCell.topLabel.text = name;
        chatCell.timeLabel.attributedText = message.timeLabelText;
        if ([cell isKindOfClass:[ChatOutgoingCell class]]) {
            ChatOutgoingCell *chatOutgoingCell = (ChatOutgoingCell *)cell;
            UIImage *image = self.dialog.type == QBChatDialogTypePublicGroup ? UIImage.new : message.statusImage;
            chatOutgoingCell.statusImageView.image = image;
        }
        if (chatCell.textView ) {
            chatCell.textView.attributedText = message.messageText;
        }
        chatCell.delegate = self;
    }
    if ([cell isKindOfClass:[ChatAttachmentCell class]]) {
        ChatAttachmentCell *attachmentCell = (ChatAttachmentCell *)cell;
        cell.userInteractionEnabled = YES;
        QBChatAttachment *attachment = message.attachments.firstObject;
        if ([attachmentCell isKindOfClass:[ChatAttachmentIncomingCell class]] && self.dialog.type != QBChatDialogTypePrivate) {
            ChatAttachmentIncomingCell *attachmentIncomingCell  = (ChatAttachmentIncomingCell *)cell;
            NSAttributedString *userNameAttributedString = message.topLabelText;
            NSString *userName = userNameAttributedString.string;
            attachmentIncomingCell.avatarLabel.text = [userName.firstLetter uppercaseString];
            attachmentIncomingCell.avatarLabel.backgroundColor = [UIColor colorWithHexString:[NSString stringWithFormat:@"#%lX",
                                                                                              (unsigned long)message.senderID]];
        }
        NSString *originForwardName = message.customParameters[@"origin_sender_name"];
        if (originForwardName) {
            attachmentCell.forwardInfoHeightConstraint.constant = 35.0f;
            attachmentCell.forwardedLabel.attributedText = message.forwardedText;
        } else {
            attachmentCell.forwardInfoHeightConstraint.constant = 0.0f;
        }
        if ([attachmentCell isKindOfClass:[ChatAttachmentOutgoingCell class]]) {
            ChatAttachmentOutgoingCell *attachmentOutgoingCell  = (ChatAttachmentOutgoingCell *)cell;
            attachmentOutgoingCell.statusImageView.image = message.statusImage;
        }
        [attachmentCell setupAttachment:attachment];
    }
}

- (void)collectionView:(ChatCollectionView *)collectionView
       willDisplayCell:(nonnull UICollectionViewCell *)cell
    forItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (self.isDeviceLocked) {
        return;
    }
    if (self.dialog.type == QBChatDialogTypePrivate) {
        return;
    }
    QBChatMessage *message = [self.dataSource messageWithIndexPath:indexPath];
    if ([self.chatManager.storage userWithID:message.senderID]) {
        return;
    }
    if ([cell isKindOfClass:[ChatIncomingCell class]] || [cell isKindOfClass:[ChatAttachmentIncomingCell class]]) {
        [self.chatManager loadUserWithID:message.senderID completion:^(QBUUser * _Nullable user) {
            ChatCell *chatCell = (ChatCell *)cell;
            NSAttributedString *userNameAttributedString = message.topLabelText;
            NSString *userName = userNameAttributedString.string;
            NSCharacterSet *characterSet = [NSCharacterSet whitespaceCharacterSet];
            NSString *name = [userName stringByTrimmingCharactersInSet:characterSet];
            dispatch_async(dispatch_get_main_queue(), ^{
                chatCell.avatarLabel.text = name.firstLetter;
                chatCell.avatarLabel.backgroundColor = [UIColor colorWithHexString:[NSString stringWithFormat:@"#%lX",
                                                                                    (unsigned long)message.senderID]];
                chatCell.topLabel.text = name;
            });
        }];
    }
}

- (void)collectionView:(ChatCollectionView *)collectionView
  didEndDisplayingCell:(nonnull UICollectionViewCell *)cell
    forItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[ChatAttachmentCell class]]) {
        QBChatMessage *item = [self.dataSource messageWithIndexPath:indexPath];
        if (!item) {
            return;
        }
        QBChatAttachment *attachment = item.attachments.firstObject;
        if (!attachment) {
            return;
        }
        NSString *attachmentID = attachment.ID;
        AttachmentDownloadManager *attachmentDownloadManager = [[AttachmentDownloadManager alloc] init];
        [attachmentDownloadManager slowDownloadAttachmentWithID:attachmentID];
    }
}

#pragma mark - Collection view delegate flow layout
- (CGSize)collectionView:(ChatCollectionView *)collectionView
                  layout:(ChatCollectionViewFlowLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [collectionViewLayout sizeForItemAtIndexPath:indexPath];
}

- (ChatCellLayoutModel)collectionView:(ChatCollectionView *)collectionView
               layoutModelAtIndexPath:(NSIndexPath *)indexPath {
    QBChatMessage *item = [self.dataSource messageWithIndexPath:indexPath];
    Class cellClass = [self viewClassForItem:item];
    ChatCellLayoutModel layoutModel = [cellClass layoutModel];
    layoutModel.avatarSize = CGSizeZero;
    layoutModel.maxWidthMarginSpace = 20.0f;
    if (cellClass == ChatIncomingCell.self || cellClass == ChatAttachmentIncomingCell.self) {
        if (self.dialog.type != QBChatDialogTypePrivate) {
            layoutModel.avatarSize = CGSizeMake(40.0f, 40.0f);
        } else {
            layoutModel.avatarSize = CGSizeZero;
            CGFloat left = cellClass == ChatIncomingCell.self ? 10.0f : 0.0f;
            layoutModel.containerInsets = UIEdgeInsetsMake(0.0f, left, 16.0f, 16.0f);
        }
    }
    layoutModel.spaceBetweenTopLabelAndTextView = 12.0f;
    return layoutModel;
}

- (CGFloat)collectionView:(ChatCollectionView *)collectionView minWidthAtIndexPath:(NSIndexPath *)indexPath {
    QBChatMessage *item = [self.dataSource messageWithIndexPath:indexPath];
    CGFloat dateLabelWidth = item.timeLabelText.string.stringWidth;
    CGFloat topLabelWidth = item.topLabelText.string.stringWidth;
    if (item.senderID == self.senderID) {
        CGFloat statusWidth = 46.0f;
        return topLabelWidth + dateLabelWidth + statusWidth;
    }
    topLabelWidth = topLabelWidth + dateLabelWidth + 6.0f;
    return topLabelWidth > 86.0f ? topLabelWidth : 86.0f;
}

- (CGSize)collectionView:(ChatCollectionView *)collectionView
  dynamicSizeAtIndexPath:(NSIndexPath *)indexPath
                maxWidth:(CGFloat)maxWidth {
    QBChatMessage *item = [self.dataSource messageWithIndexPath:indexPath];
    Class viewClass = [self viewClassForItem:item];
    CGSize size = CGSizeZero;
    if (viewClass == [ChatAttachmentIncomingCell class] || viewClass == [ChatAttachmentOutgoingCell class]) {
        size = CGSizeMake(MIN(260, maxWidth), 180);
    } else {
        CGSize constraintsSize = CGSizeMake(MIN(260, maxWidth), CGFLOAT_MAX);
        size = [item estimateFrameWithConstraintsSize:constraintsSize];
    }
    return size;
}

- (NSString *)collectionView:(ChatCollectionView *)collectionView
           itemIdAtIndexPath:(nonnull NSIndexPath *)indexPath {
    QBChatMessage *item = [self.dataSource messageWithIndexPath:indexPath];
    return item.ID;
}

#pragma mark - Collection view delegate - ContextMenu
- (UITargetedPreview *)targetedPreviewForConfiguration:(UIContextMenuConfiguration *)configuration {
    ChatCell *selectedCell = (ChatCell *)[self.collectionView cellForItemAtIndexPath:self.selectedIndexPathForMenu];
    UIPreviewParameters *parameters = [[UIPreviewParameters alloc] init];
    parameters.backgroundColor = [UIColor clearColor];
    CGFloat cornerRadius = [selectedCell isKindOfClass:[ChatAttachmentCell class]] ? 6.0f : 20.0f;
    UIRectCorner roundingCorners = UIRectCornerBottomLeft | UIRectCornerTopLeft | UIRectCornerTopRight;;
    QBChatMessage *message = [self.dataSource messageWithIndexPath:self.selectedIndexPathForMenu];
    if (message.senderID != self.senderID) {
        roundingCorners = UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomRight;
    }
    parameters.visiblePath = [UIBezierPath bezierPathWithRoundedRect:selectedCell.previewContainer.bounds
                                                   byRoundingCorners:roundingCorners
                                                         cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
    UITargetedPreview *targetedPreview = [[UITargetedPreview alloc] initWithView:selectedCell.previewContainer parameters:parameters];
    return targetedPreview;
}

- (UITargetedPreview *)collectionView:(UICollectionView *)collectionView previewForHighlightingContextMenuWithConfiguration:(UIContextMenuConfiguration *)configuration {
    return [self targetedPreviewForConfiguration:configuration];
}

- (UITargetedPreview *)collectionView:(UICollectionView *)collectionView previewForDismissingContextMenuWithConfiguration:(UIContextMenuConfiguration *)configuration {
    return [self targetedPreviewForConfiguration:configuration];
}

- (UIContextMenuConfiguration *)collectionView:(UICollectionView *)collectionView contextMenuConfigurationForItemAtIndexPath:(NSIndexPath *)indexPath point:(CGPoint)point {
    [self hideKeyboard:YES];
    self.selectedIndexPathForMenu = indexPath;
    QBChatMessage *message = [self.dataSource messageWithIndexPath:self.selectedIndexPathForMenu];
    if (message.isDateDividerMessage || message.isNotificationMessage) {
        return nil;
    }
    return [UIContextMenuConfiguration configurationWithIdentifier:nil previewProvider:nil actionProvider:^UIMenu * _Nullable(NSArray<UIMenuElement *> * _Nonnull suggestedActions) {
        ChatCell *cell = (ChatCell *)[self.collectionView cellForItemAtIndexPath:self.selectedIndexPathForMenu];
        if ([cell isKindOfClass:[ChatAttachmentCell class]]) {
            ChatAttachmentCell *chatAttachmentCell = (ChatAttachmentCell *)cell;
            QBChatMessage *item = [self.dataSource messageWithIndexPath:self.selectedIndexPathForMenu];
            QBChatAttachment *attachment = item.attachments.firstObject;
            
            if (attachment && attachment.ID && [attachment.type isEqualToString:@"file"]) {
                return [self chatContextMenuOutgoing:YES forCell:chatAttachmentCell];
            }
        }
        if (self.dialog.type == QBChatDialogTypePrivate || message.senderID != self.senderID) {
            return [self chatContextMenuOutgoing:NO forCell:nil];
        } else {
            return [self chatContextMenuOutgoing:YES forCell:nil];
        }
    }];
}

#pragma mark - ChatConextMenuProtocol
- (void)forwardAction {
    if (!self.selectedIndexPathForMenu) {
        return;
    }
    QBChatMessage *message = [self.dataSource messageWithIndexPath:self.selectedIndexPathForMenu];
    if (message) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Dialogs" bundle:nil];
        DialogsSelectionViewController *dialogsSelectionVC = [storyboard instantiateViewControllerWithIdentifier:@"DialogsSelectionVC"];
        dialogsSelectionVC.action = ChatActionForward;
        dialogsSelectionVC.message = message;
        UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:dialogsSelectionVC];
        [navVC setupAppearanceWithColor:nil titleColor:UIColor.whiteColor];
        [self.navigationController pushViewController:dialogsSelectionVC animated:NO];
    }
}

- (void)deliveredToAction {
    [self showViewedByWithAction:ChatActionDeliveredTo];
}

- (void)viewedByAction {
    [self showViewedByWithAction:ChatActionViewedBy];
}

- (void)showViewedByWithAction:(ChatAction)action {
    ViewedByViewController *viewedByViewController = [[ViewedByViewController alloc] initWithNonDisplayedUsers:@[@(self.senderID)]];
    viewedByViewController.dialogID = self.dialog.ID;
    viewedByViewController.action = action;
    if (self.selectedIndexPathForMenu) {
        QBChatMessage *message = [self.dataSource messageWithIndexPath:self.selectedIndexPathForMenu];
        if (message) {
            viewedByViewController.messageID = message.ID;
            viewedByViewController.dataSource = self.dataSource;
        }
    }
    [self.navigationController pushViewController:viewedByViewController animated:NO];
}

#pragma mark - Text view delegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (textView != self.inputToolbar.contentView.textView) {
        return;
    }
    if (self.automaticallyScrollsToMostRecentMessage) {
        self.collectionBottomConstraint.constant = self.collectionBottomConstant;
        [self scrollToBottomAnimated:YES];
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    if (textView != self.inputToolbar.contentView.textView) {
        return;
    }
    if ([textView.text hasPrefix:@" "]) {
        textView.text = [textView.text substringFromIndex:1];
    }
    if (textView.text.length > maxNumberLetters) {
        textView.text = [textView.text substringToIndex:NSMaxRange([textView.text rangeOfComposedCharacterSequenceAtIndex:maxNumberLetters - 1])];
    }
    [self sendIsTypingStatus];
    [self.inputToolbar toggleSendButtonEnabledIsUploaded:self.isUploading];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (textView != self.inputToolbar.contentView.textView) {
        return;
    }
    [self stopTyping];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (textView != self.inputToolbar.contentView.textView) {
        return NO;
    }
    return YES;
}

#pragma mark - ChatCellDelegate
- (void)chatCellDidTapContainer:(ChatCell *)cell {
    if (![cell isKindOfClass:[ChatAttachmentCell class]]) {
        return;
    }
    ChatAttachmentCell *chatAttachmentCell = (ChatAttachmentCell *)cell;
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:chatAttachmentCell];
    QBChatMessage *item = [self.dataSource messageWithIndexPath:indexPath];
    QBChatAttachment *attachment = item.attachments.firstObject;
    
    if (attachment && attachment.ID && [attachment.type isEqualToString:@"image"]) {
        UIImage *attachmentImage = chatAttachmentCell.attachmentImageView.image;
        if (attachmentImage) {
            ZoomedAttachmentViewController *zoomedVC = [[ZoomedAttachmentViewController alloc] initWithImage:attachmentImage];
            UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:zoomedVC];
            [navVC setupAppearanceWithColor:UIColor.blackColor titleColor:UIColor.whiteColor];
            navVC.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:navVC animated:NO completion:nil];
        }
    } else if (attachment && attachment.ID && [attachment.type isEqualToString:@"video"]) {
        NSURL *videoURL = [attachment cachedURL];
        if ([NSFileManager.defaultManager fileExistsAtPath:videoURL.path]) {
            ParentVideoVC *parentVideoVC = [[ParentVideoVC alloc] initWithVideoUrl:videoURL];
            parentVideoVC.title = attachment.name;
            UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:parentVideoVC];
            navVC.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:navVC animated:NO completion:nil];
        }
    }
}

- (void)saveFileAttachmentFromChatAttachmentCell:(ChatAttachmentCell *)chatAttachmentCell {
    NSString *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *destinationPath = [NSString stringWithFormat:@"%@/%@", documentsPath, chatAttachmentCell.attachmentUrl.lastPathComponent];
    
    if ([NSFileManager.defaultManager fileExistsAtPath:destinationPath]) {
        [NSFileManager.defaultManager removeItemAtPath:destinationPath error:nil];
    }
    
    NSError *error = nil;
    [NSFileManager.defaultManager copyItemAtPath:chatAttachmentCell.attachmentUrl.path toPath:destinationPath error:&error];
    NSString *errorMessage = error ? @"Save error" : @"Saved!";
    [self showAnimatedAlertWithTitle:nil message:errorMessage];
}

- (void)openAttachmentImage:(UIImage *)image {
    ZoomedAttachmentViewController *zoomedVC = [[ZoomedAttachmentViewController alloc] initWithImage:image];
    zoomedVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    zoomedVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:zoomedVC animated:YES completion:nil];
}

#pragma mark - QBChatDelegate
- (void)chatDidReadMessageWithID:(NSString *)messageID
                        dialogID:(NSString *)dialogID
                        readerID:(NSUInteger)readerID {
    if (self.senderID == readerID || ![dialogID isEqualToString:self.dialog.ID]) {
        return;
    }
    QBChatMessage *currentMessage = [self.dataSource messageWithID:messageID];
    if (currentMessage) {
        NSMutableArray *readIDs = [currentMessage.readIDs mutableCopy];
        if ([readIDs containsObject:@(readerID)]) {
            return;
        }
        [readIDs addObject:@(readerID)];
        [currentMessage setReadIDs: [readIDs copy]];
        [self.dataSource updateMessage:currentMessage];
    }
}

- (void)chatDidDeliverMessageWithID:(NSString *)messageID dialogID:(NSString *)dialogID toUserID:(NSUInteger)userID {
    if (self.senderID == userID || ![dialogID isEqualToString:self.dialog.ID]) {
        return;
    }
    QBChatMessage *currentMessage = [self.dataSource messageWithID:messageID];
    if (currentMessage) {
        QBChatMessage *currentMessage = [self.dataSource messageWithID:messageID];
        NSMutableArray *deliveredIDs = [currentMessage.deliveredIDs mutableCopy];
        if ([deliveredIDs containsObject:@(userID)]) {
            return;
        }
        [deliveredIDs addObject:@(userID)];
        [currentMessage setDeliveredIDs: [deliveredIDs copy]];
        [self.dataSource updateMessage:currentMessage];
    }
}

- (void)chatDidReceiveMessage:(QBChatMessage *)message {
    if (![message.dialogID isEqualToString: self.dialog.ID]) { return; }
    if (message.isNotificationMessageTypeLeave) {
        [self.chatManager updateDialogWith:message.dialogID withMessage:message];
        if (message.senderID == self.senderID) {
            [self.navigationController popToRootViewControllerAnimated:NO];
            return;
        }
    }
    if (message.isNotificationMessageTypeCreate && message.senderID != self.senderID) {
        return;
    }
    [self handlerStopTypingUser:@(message.senderID)];
    [self.dataSource addMessage:message];
}

- (void)chatRoomDidReceiveMessage:(QBChatMessage *)message fromDialogID:(NSString *)dialogID {
    if (![dialogID isEqualToString: self.dialog.ID]) { return; }
    if (message.isNotificationMessageTypeAdding) {
        [self.chatManager updateDialogWith:dialogID withMessage:message];
    }
    if (message.isNotificationMessageTypeLeave) {
        [self.chatManager updateDialogWith:dialogID withMessage:message];
        if (message.senderID == self.senderID) {
            [QBChat.instance removeDelegate:self];
            [self.navigationController popToRootViewControllerAnimated:NO];
            return;
        }
    }
    [self handlerStopTypingUser:@(message.senderID)];
    [self.dataSource addMessage:message];
}

- (void)chatDidConnect {
    [self refreshAndReadMessages];
}

- (void)chatDidReconnect {
    [self refreshAndReadMessages];
}

- (void)refreshAndReadMessages {
    // Handling unread messages
    if ([self.dataSource messagesForReadCount] > 0) {
        NSArray *messages = [self.dataSource allMessagesForRead];
        __weak typeof(self)weakSelf = self;
        for (QBChatMessage *message in messages) {
            [self.chatManager readMessage:message dialog:self.dialog completion:^(NSError * _Nullable error) {
                __typeof(weakSelf)strongSelf = weakSelf;
                if (!error) {
                    NSMutableArray *readIDs = [message.readIDs mutableCopy];
                    [readIDs addObject:@(QBChat.instance.currentUser.ID)];
                    [message setReadIDs: [readIDs copy]];
                    [strongSelf.dataSource updateMessage:message];
                    [strongSelf.dataSource removeMessageForRead:message];
                }
            }];
        }
    }
    // Handling unsent messages
    if ([self.dataSource draftMessagesCount] > 0) {
        NSArray *messages = [self.dataSource allDraftMessages];
        __weak typeof(self)weakSelf = self;
        for (QBChatMessage *message in messages) {
            [self.dialog sendMessage:message completionBlock:^(NSError * _Nullable error) {
                __typeof(weakSelf)strongSelf = weakSelf;
                if (error) {
                    Log(error.localizedDescription);
                    return;
                }
                [strongSelf.dataSource removeDraftMessage:message];
                [strongSelf.dataSource addMessage:message];
            }];
        }
    }
    
    [self loadMessagesWithSkip:0];
    [self.inputToolbar toggleSendButtonEnabledIsUploaded:self.isUploading];
}

#pragma mark - AttachmentBarDelegate
- (void)attachmentBarFailedUpLoadImage:(AttachmentUploadBar *)attachmentBar {
    [self cancelUploadFile];
}

- (void)attachmentBar:(AttachmentUploadBar *)attachmentBar didUpLoadAttachment:(QBChatAttachment *)attachment {
    self.attachmentMessage = [self createAttachmentMessageWith:attachment];
    [self.inputToolbar toggleSendButtonEnabledIsUploaded:self.isUploading];
}

- (void)attachmentBar:(AttachmentUploadBar *)attachmentBar didTapCancelButton:(UIButton *)sender {
    self.attachmentMessage = nil;
    [self hideAttacnmentBar];
}

@end
