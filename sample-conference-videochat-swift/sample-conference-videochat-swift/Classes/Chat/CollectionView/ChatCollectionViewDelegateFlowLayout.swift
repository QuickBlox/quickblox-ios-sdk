//
//  ChatCollectionViewDelegateFlowLayout.swift
//  sample-conference-videochat-swift
//
//  Created by Injoit on 1/28/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit
/**
 *  The `ChatCollectionViewDelegateFlowLayout` protocol defines methods that allow you to
 *  manage additional layout information for the collection view and respond to additional actions on its items.
 */
protocol ChatCollectionViewDelegateFlowLayout: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: ChatCollectionView,
                        layoutModelAt indexPath: IndexPath) -> ChatCellLayoutModel
    
    func collectionView(_ collectionView: ChatCollectionView,
                        dynamicSizeAt indexPath: IndexPath,
                        maxWidth: CGFloat) -> CGSize
    
    func collectionView(_ collectionView: ChatCollectionView,
                        minWidthAt indexPath: IndexPath) -> CGFloat
}
