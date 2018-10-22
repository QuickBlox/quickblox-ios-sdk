//
//  OpponentsFlowLayout.swift
//  sample-conference-videochat-swift
//
//  Created by Vladimir Nybozhinsky on 04.10.2018.
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
    
    override func prepare() {
        layoutAttributes.removeAll()
        
        let numberOfItems: Int? = collectionView?.numberOfItems(inSection: 0)
        for i in 0..<(numberOfItems ?? 0) {
            let attributes = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: i, section: 0))
            attributes.frame = itemFrame(withItemIndex: i, itemsCount: numberOfItems!)
            layoutAttributes.append(attributes)
        }
    }
    
    override var collectionViewContentSize: CGSize {
        
        return collectionView?.frame.size ?? CGSize.zero
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var array: [UICollectionViewLayoutAttributes] = []
        for attributes in layoutAttributes {
            if !rect.intersection((attributes.frame)).isNull {
    
                    array.append(attributes)

            }
        }
        return array
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    func shiftPosition(itemsCount: Int, isPortrait: Bool) -> Int {
        // ItemsCount : position
        var map: [Int: Int]? = nil
        if isPortrait {
            map = [3: 0, 5: 0, 7: 6, 8: 6, 10: 9, 11: 9, 13: 12, 14: 12]
        } else {
            map = [5: 3, 7: 4, 10: 8]
        }
        
        if let position = map?[itemsCount] {
            return position
        }

        return -1
    }
    
    func itemFrame(withItemIndex itemIndex: Int, itemsCount: Int) -> CGRect {
        
        let contentSize: CGSize = collectionViewContentSize
        let isPortrait: Bool = contentSize.width < contentSize.height
        let columns = numberOfColumns(numberOfItems: itemsCount, isPortrait: isPortrait)
        
        if itemsCount > 1 {
            
            let shiftPos = shiftPosition(itemsCount: itemsCount, isPortrait: isPortrait)
            let shift = itemIndex > shiftPos ? 1 : 0
            
            let rows: CGFloat = CGFloat(ceilf(Float(itemsCount/columns)))
            let mod: Int = itemsCount % columns
            
            var scale: CGFloat = 1.0 / CGFloat(columns)
            if shiftPos == itemIndex {
                if columns == 2 {
                    scale = 1.0
                } else if columns == 3 {
                    scale = mod == 1 ? 1.0 : CGFloat(mod) / CGFloat(columns)
                } else if columns == 4 {
                    scale = 2.0 / CGFloat(columns)
                }
            }
            
            let w: CGFloat = contentSize.width * scale
            let h: CGFloat = contentSize.height / rows
            let i = CGFloat((itemIndex + shift))
            
            let row = CGFloat(floorf(Float(i / CGFloat(columns))))
            let col: Int = (itemIndex + shift) % columns
            
            return CGRect(x: w * CGFloat(col), y: h * row, width: w, height: h)
        } else {
            
            return CGRect(x: 0, y: 0, width: contentSize.width, height: contentSize.height)
        }
    }
    
    private func numberOfColumns(numberOfItems: Int, isPortrait: Bool) -> Int {
        
        var countOfColumns: Int
        if isPortrait {
            switch numberOfItems {
            case 1, 2:
                countOfColumns = 1
            case 3, 4, 5, 6:
                countOfColumns = 2
            default:
                countOfColumns = 3
            }
        } else {
            switch numberOfItems {
            case 1:
                countOfColumns = 1
            case 2, 4:
                countOfColumns = 2
            case 3, 5, 6, 9:
                countOfColumns = 3
            default:
                countOfColumns = 4
            }
        }
        return countOfColumns
    }
}
