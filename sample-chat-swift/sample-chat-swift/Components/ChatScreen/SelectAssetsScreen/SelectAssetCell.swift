//
//  SelectAssetCell.swift
//  sample-chat-swift
//
//  Created by Injoit on 12/9/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit

class SelectAssetCell: UICollectionViewCell {
    @IBOutlet weak var durationVideoLabel: UILabel!
    @IBOutlet weak var videoTypeView: UIView!
    @IBOutlet weak var assetTypeImageView: UIImageView!
    @IBOutlet weak var assetImageView: UIImageView!
    @IBOutlet weak var checkBoxImageView: UIImageView!
    @IBOutlet weak var checkBoxView: UIView!
    
    var representedAssetIdentifier: String!
    
    //MARK: - Overrides
    override func awakeFromNib() {
        checkBoxView.backgroundColor = UIColor.white.withAlphaComponent(0.35)
        checkBoxView.setRoundBorderEdgeColorView(cornerRadius: 4.0,
                                            borderWidth: 1.0,
                                            borderColor: UIColor.white)
        videoTypeView.rounded(cornerRadius: 3)
        videoTypeView.isHidden = true
        assetImageView.contentMode = .scaleAspectFill
    }
    
    override func prepareForReuse() {
        assetTypeImageView.image = nil
        checkBoxView.backgroundColor = UIColor.white.withAlphaComponent(0.35)
        checkBoxView.setRoundBorderEdgeColorView(cornerRadius: 4.0,
                                            borderWidth: 1.0,
                                            borderColor: UIColor.white)
        videoTypeView.isHidden = true
        checkBoxImageView.isHidden = true
    }
    
    override var isHighlighted: Bool {
        willSet {
            onSelectedCell(newValue)
        }
    }
    
    override var isSelected: Bool {
        willSet {
            onSelectedCell(newValue)
        }
    }
    
    func onSelectedCell(_ newValue: Bool) {
        if newValue == true {
            checkBoxImageView.isHidden = false
            contentView.backgroundColor = UIColor(red:0.85, green:0.89, blue:0.97, alpha:1)
            checkBoxView.setRoundBorderEdgeColorView(cornerRadius: 4.0,
                                                     borderWidth: 1.0,
                                                     color: UIColor(red:0.22, green:0.47, blue:0.99, alpha:1),
                                                     borderColor: UIColor(red:0.22, green:0.47, blue:0.99, alpha:1))
        } else {
            checkBoxImageView.isHidden = true
            contentView.backgroundColor = .clear
            checkBoxView.setRoundBorderEdgeColorView(cornerRadius: 4.0,
                                                     borderWidth: 1.0,
                                                     color: UIColor.white.withAlphaComponent(0.35),
                                                     borderColor: UIColor.white)
        }
    }
}


