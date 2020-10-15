//
//  ChatCollectionViewDataSource.swift
//  sample-chat-swift
//
//  Created by Injoit on 1/28/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit

/**
 *  An object that adopts the `ChatCollectionViewDataSource` protocol is responsible for providing the data and views
 *  required by a `ChatCollectionView`. The data source object represents your app’s messaging data model
 *  and vends information to the collection view as needed.
 */

protocol ChatCollectionViewDataSource: UICollectionViewDataSource {
    /**
     *  Asks the data source for the current sender's display name, that is, the current user who is sending messages.
     *
     *  @return An initialized string describing the current sender to display in a `ChatCollectionViewCell`.
     *
     *  @warning You must not return `nil` from this method. This value does not need to be unique.
     */
    var senderDisplayName: String { get set }
    
    /**
     *  Asks the data source for the current sender's unique identifier, that is, the current user who is sending messages.
     *
     *  @return An initialized string identifier that uniquely identifies the current sender.
     *
     *  @warning You must not return `0` from this method. This value must be unique.
     */
    var currentUserID: UInt { get set }
    /**
     *  Asks the data source for the message data that corresponds to the specified item at indexPath in the collectionView.
     *
     *  @param collectionView The object representing the collection view requesting this information.
     *  @param indexPath      The index path that specifies the location of the item.
     *
     *  @return An initialized object that conforms to the `ChatMessageData` protocol. You must not return `nil` from this method.
     */

    func collectionView(_ collectionView: ChatCollectionView, itemIdAt indexPath: IndexPath) -> String
}

