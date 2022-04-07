//
//  HeaderCollectionReusableView.swift
//  sample-chat-swift
//
//  Created by Injoit on 1/28/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit

@objc protocol ChatReusableViewProtocol {
    /**
     *  Returns the `UINib` object initialized for the cell.
     *
     *  @return The initialized `UINib` object or `nil` if there were errors during
     *  initialization or the nib file could not be located.
     */
    static func nib() -> UINib?
    /**
     *  Returns the default string used to identify a reusable cell for text message items.
     *
     *  @return The string used to identify a reusable cell.
     */
    static func cellReuseIdentifier() -> String?
}

class HeaderCollectionReusableView: UICollectionReusableView, ChatReusableViewProtocol {

        @IBOutlet weak var containerView: UIView!
        @IBOutlet weak var headerLabel: UILabel!
        
    class func nib() -> UINib? {
        return ChatResources.nib(withNibName: String(describing:HeaderCollectionReusableView.self))
    }
    
    class func cellReuseIdentifier() -> String? {
        return String(describing:HeaderCollectionReusableView.self)
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        let transform = CGAffineTransform(a: 1.0, b: 0.0, c: 0.0, d: -1.0, tx: 0.0, ty: 0.0)
        layoutAttributes.transform = transform
        super.apply(layoutAttributes)
    }
}
