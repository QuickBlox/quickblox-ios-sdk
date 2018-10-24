//
//  DialogTableViewCell.swift
//  sample-conference-videochat-swift
//
//  Created by Vladimir Nybozhinsky on 12.10.2018.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit

protocol DialogTableViewCellDelegate: class {
    func dialogCellDidListenerButton(_ dialogCell: DialogTableViewCell?)
    
    func dialogCellDidAudioButton(_ dialogCell: DialogTableViewCell?)
    
    func dialogCellDidVideoButton(_ dialogCell: DialogTableViewCell?)
}

class DialogTableViewCell: UITableViewCell {
    weak var delegate: DialogTableViewCellDelegate?
    
    @IBOutlet private weak var titleLabel: UILabel!
    
     var title: String? {
        didSet {
            setTitle(title)
        }
    }
    
    func setTitle(_ title: String?) {
            titleLabel.text = self.title
    }
    
    // MARK: - Overrides
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    // MARK: - Actions
    @IBAction func didTapListenerButton() {
        delegate?.dialogCellDidListenerButton(self)
    }
    
    @IBAction func didTapAudioButton() {
        delegate?.dialogCellDidAudioButton(self)
    }
    
    @IBAction func didTapVideoButton() {
        delegate?.dialogCellDidVideoButton(self)
    }
}
