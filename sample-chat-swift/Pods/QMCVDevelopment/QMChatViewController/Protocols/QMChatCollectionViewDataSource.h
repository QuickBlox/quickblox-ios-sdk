//
//  QMChatCollectionViewDataSource.h
//  QMChatViewController
//
//  Created by Andrey Ivanov on 20.04.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class QMChatCollectionView;

/**
 *  An object that adopts the `QMChatCollectionViewDataSource` protocol is responsible for providing the data and views
 *  required by a `QMChatCollectionView`. The data source object represents your app’s messaging data model
 *  and vends information to the collection view as needed.
 */
@protocol QMChatCollectionViewDataSource <UICollectionViewDataSource>

@required

/**
 *  Asks the data source for the current sender's display name, that is, the current user who is sending messages.
 *
 *  @return An initialized string describing the current sender to display in a `QMChatCollectionViewCell`.
 *
 *  @warning You must not return `nil` from this method. This value does not need to be unique.
 */
- (NSString *)senderDisplayName;

/**
 *  Asks the data source for the current sender's unique identifier, that is, the current user who is sending messages.
 *
 *  @return An initialized string identifier that uniquely identifies the current sender.
 *
 *  @warning You must not return `0` from this method. This value must be unique.
 */
- (NSUInteger)senderID;

/**
 *  Height for section header.
 *
 *  @return height for header that used as section header
 */
- (CGFloat)heightForSectionHeader;

/**
 *  Asks the data source for the message data that corresponds to the specified item at indexPath in the collectionView.
 *
 *  @param collectionView The object representing the collection view requesting this information.
 *  @param indexPath      The index path that specifies the location of the item.
 *
 *  @return An initialized object that conforms to the `QMChatMessageData` protocol. You must not return `nil` from this method.
 */
//- (id<QMChatMessageData>)collectionView:(QMChatCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath;

- (NSString *)collectionView:(QMChatCollectionView *)collectionView itemIdAtIndexPath:(NSIndexPath *)indexPath;

@end
