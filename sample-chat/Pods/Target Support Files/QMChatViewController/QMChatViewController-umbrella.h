#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "QMChatViewController.h"
#import "NSString+QM.h"
#import "UIColor+QM.h"
#import "UIImage+Cropper.h"
#import "UIImage+QM.h"
#import "UIView+QM.h"
#import "QMChatCollectionViewDataSource.h"
#import "QMChatCollectionViewDelegateFlowLayout.h"
#import "NSDate+ChatDataSource.h"
#import "QBChatMessage+QBDateDivider.h"
#import "QMChatDataSource.h"
#import "QMChatLocationSnapshotter.h"
#import "UIImageView+QMLocationSnapshot.h"
#import "QMChatResources.h"
#import "QMDateUtils.h"
#import "QMImageLoader.h"
#import "QMChatAttachmentCell.h"
#import "QMChatAttachmentIncomingCell.h"
#import "QMChatAttachmentOutgoingCell.h"
#import "QMChatCell.h"
#import "QMChatContactRequestCell.h"
#import "QMChatIncomingCell.h"
#import "QMBaseChatLocationCell.h"
#import "QMChatLocationCell.h"
#import "QMChatLocationIncomingCell.h"
#import "QMChatLocationOutgoingCell.h"
#import "QMAudioIncomingCell.h"
#import "QMAudioOutgoingCell.h"
#import "QMBaseMediaCell.h"
#import "QMImageIncomingCell.h"
#import "QMImageOutgoingCell.h"
#import "QMMediaIncomingCell.h"
#import "QMMediaOutgoingCell.h"
#import "QMMediaViewDelegate.h"
#import "QMVideoIncomingCell.h"
#import "QMVideoOutgoingCell.h"
#import "QMChatNotificationCell.h"
#import "QMChatOutgoingCell.h"
#import "QMChatBaseLinkPreviewCell.h"
#import "QMChatIncomingLinkPreviewCell.h"
#import "QMChatOutgoingLinkPreviewCell.h"
#import "QMLinkPreviewDelegate.h"
#import "QMChatCellLayoutAttributes.h"
#import "QMChatCollectionViewFlowLayout.h"
#import "QMCollectionViewFlowLayoutInvalidationContext.h"
#import "QMChatCollectionView.h"
#import "QMInputToolbar.h"
#import "QMToolbarContentView.h"
#import "QMPlaceHolderTextView.h"
#import "QMAudioRecordButton.h"
#import "QMAudioRecordView.h"
#import "QMHeaderCollectionReusableView.h"
#import "QMImageView.h"
#import "QMProgressView.h"
#import "QMChatActionsHandler.h"
#import "QMChatContainerView.h"
#import "QMKVOView.h"

FOUNDATION_EXPORT double QMChatViewControllerVersionNumber;
FOUNDATION_EXPORT const unsigned char QMChatViewControllerVersionString[];

