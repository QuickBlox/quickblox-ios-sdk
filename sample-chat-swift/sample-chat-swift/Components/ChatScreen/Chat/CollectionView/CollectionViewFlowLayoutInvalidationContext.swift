//
//  CollectionViewFlowLayoutInvalidationContext.swift
//  Swift-ChatViewController
//
//  Created by Injoit on 1/28/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit

class CollectionViewFlowLayoutInvalidationContext: UICollectionViewFlowLayoutInvalidationContext {
        /**
         *  A boolean indicating whether to empty the messages layout information cache for items and views in the layout.
         *  The default value is `NO`.
         */
        var invalidateFlowLayoutMessagesCache = false
        /**
         *  Creates and returns a new `CollectionViewFlowLayoutInvalidationContext` object.
         *
         *  @discussion When you need to invalidate the `ChatCollectionViewFlowLayout` object for your
         *  `ChatViewController` subclass, you should use this method to instantiate a new invalidation
         *  context and pass this object to `invalidateLayoutWithContext:`.
         *
         *  @return An initialized invalidation context object if successful, otherwise `nil`.
         */
    
    // MARK: - Initialization
    override init() {
        super.init()
    }

    // MARK: - NSObject
    func description() -> String? {
        return "<\(CollectionViewFlowLayoutInvalidationContext.self): invalidateFlowLayoutDelegateMetrics=\(invalidateFlowLayoutDelegateMetrics), invalidateFlowLayoutAttributes=\(invalidateFlowLayoutAttributes), invalidateDataSourceCounts=\(invalidateDataSourceCounts), invalidateFlowLayoutMessagesCache=\(invalidateFlowLayoutMessagesCache)>"
    }
}
