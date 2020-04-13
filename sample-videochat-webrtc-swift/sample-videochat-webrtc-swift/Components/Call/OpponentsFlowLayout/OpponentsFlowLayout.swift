//
//  OpponentsFlowLayout.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 12/18/18.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit

class OpponentsFlowLayout: UICollectionViewFlowLayout {
    
    private var layoutAttributes = [UICollectionViewLayoutAttributes]()
    
    // MARK: Construction
    override init() {
        super.init()
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        minimumInteritemSpacing = 2
        minimumLineSpacing = 2
    }
    
    // MARK: UISubclassingHooks
    override var collectionViewContentSize: CGSize {
        return collectionView?.frame.size ?? CGSize.zero
    }
    
    override func prepare() {
        layoutAttributes.removeAll()
        guard let collectionView = collectionView else {
            return
        }
        let numberOfItems = collectionView.numberOfItems(inSection: 0)
        for item in 0..<(numberOfItems) {
            let attributes = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: item, section: 0))
            attributes.frame = itemFrame(index: item, count: numberOfItems)
            layoutAttributes.append(attributes)
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return layoutAttributes.filter {
            let intersection = rect.intersection($0.frame)
            return intersection.isNull == false
        }
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    func shiftPosition(itemsCount: Int, isPortrait: Bool) -> Int {
        // ItemsCount : position
        guard isPortrait == true else {
            let map = [5: 3,
                       7: 4,
                       10: 8]
            return map[itemsCount] ?? .max
        }
        
        let map = [3: 0,
                   5: 0,
                   7: 6,
                   8: 6,
                   10: 9,
                   11: 9,
                   13: 12,
                   14: 12]
        
        return map[itemsCount] ?? .max
    }
    
    func itemFrame(index: Int, count: Int) -> CGRect {
        let size = collectionViewContentSize
        let isPortrait = size.width < size.height
        let columnsCount = numberOfColumns(itemsCount: count, isPortrait: isPortrait)
        
        guard count > 1 else {
            return CGRect(origin: .zero, size: size)
        }
        
        let position = shiftPosition(itemsCount: count, isPortrait: isPortrait)
        let shift = index > position ? 1 : 0
        
        let mod = count % columnsCount
        
        let square = Double(count)
        let side = Double(columnsCount)
        
        let rows = (square / side).rounded(.up)
        
        var scale = 1.0 / side
        if position == index {
            if columnsCount == 2 {
                scale = 1.0
            } else if columnsCount == 3 {
                scale = mod == 1 ? 1.0 : Double(mod) / side
            } else if columnsCount == 4 {
                scale = 2.0 / side
            }
        }
        
        let width = Double(size.width) * scale
        let height = Double(size.height) / rows
        let slip = Double(index + shift)
        
        let row = (slip / side).rounded(.down)
        let slipMod = (index + shift) % columnsCount
        
        let originX = width * Double(slipMod).rounded()
        let originY = height * row
        
        return CGRect(x: originX, y: originY, width: width, height: height)
    }
    
    private func numberOfColumns(itemsCount: Int, isPortrait: Bool) -> Int {
        guard isPortrait == true else {
            switch itemsCount {
            case 1: return 1
            case 2, 4: return 2
            case 3, 5, 6, 9: return 3
            default: return 4
            }
        }
        
        switch itemsCount {
        case 1, 2: return 1
        case 3, 4, 5, 6: return 2
        default: return 3
        }
    }
}
