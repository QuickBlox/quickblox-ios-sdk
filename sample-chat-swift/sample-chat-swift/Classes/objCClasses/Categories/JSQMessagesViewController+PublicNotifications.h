//
//  JSQMessagesViewController+PublicNotifications.h
//  sample-chat-swift
//
//  Created by Anton Sokolchenko on 4/22/15.
//  Copyright (c) 2015 quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JSQMessagesViewController.h>

@interface JSQMessagesViewController (PublicNotifications)
@property (strong, nonatomic) NSIndexPath *selectedIndexPathForMenu;
- (void)jsq_didReceiveMenuWillShowNotification:(NSNotification *)notification;
-(void)jsq_didReceiveMenuWillHideNotification:(NSNotification *)notification;
- (BOOL)collectionView:(JSQMessagesCollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath;
@end
