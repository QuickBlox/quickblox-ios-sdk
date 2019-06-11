//
//  ChatCollectionViewDataSource.h
//  samplechat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ChatCollectionView;

/**
 *  An object that adopts the `ChatCollectionViewDataSource` protocol is responsible for providing the data and views
 *  required by a `ChatCollectionView`. The data source object represents your app’s messaging data model
 *  and vends information to the collection view as needed.
 */
@protocol ChatCollectionViewDataSource <UICollectionViewDataSource>

@required

/**
 *  Asks the data source for the current sender's display name, that is, the current user who is sending messages.
 *
 *  @return An initialized string describing the current sender to display in a `ChatCollectionViewCell`.
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

- (NSString *)collectionView:(ChatCollectionView *)collectionView itemIdAtIndexPath:(NSIndexPath *)indexPath;

@end


NS_ASSUME_NONNULL_END
