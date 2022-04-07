//
//  UICollectionView+Extension.swift
//  sample-chat-swift
//
//  Created by Injoit on 02.12.2021.
//  Copyright © 2021 QuickBlox. All rights reserved.
//

import UIKit

extension UICollectionView {
    func indexPathsForElements(in rect: CGRect) -> [IndexPath] {
        let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect)!
        return allLayoutAttributes.map { $0.indexPath }
    }
}
