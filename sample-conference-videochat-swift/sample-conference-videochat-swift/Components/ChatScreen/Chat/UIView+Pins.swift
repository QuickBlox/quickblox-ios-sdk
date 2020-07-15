//
//  UIView+Pins.swift
//  sample-conference-videochat-swift
//
//  Created by Injoit on 1/28/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit

extension UIView {
    /**
     *  Pins the subview of the receiver to the edge of its frame, as specified by the given attribute, by adding a layout constraint.
     *
     *  @param subview   The subview to which the receiver will be pinned.
     *  @param attribute The layout constraint attribute specifying one of `NSLayoutAttributeBottom`, `NSLayoutAttributeTop`, `NSLayoutAttributeLeading`, `NSLayoutAttributeTrailing`.
     */
    func pinSubview(_ subview: UIView?, toEdge attribute: NSLayoutConstraint.Attribute) {
        addConstraint(NSLayoutConstraint(item: self,
                                         attribute: attribute,
                                         relatedBy: .equal,
                                         toItem: subview,
                                         attribute: attribute,
                                         multiplier: 1.0,
                                         constant: 0.0))
    }
    
    /**
    *  Pins all edges of the specified subview to the receiver.
    *
    *  @param subview The subview to which the receiver will be pinned.
    */
    func pinAllEdges(ofSubview subview: UIView?) {
        pinSubview(subview, toEdge: .bottom)
        pinSubview(subview, toEdge: .top)
        pinSubview(subview, toEdge: .leading)
        pinSubview(subview, toEdge: .trailing)
    }
}
