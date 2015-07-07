//
//  DialogTableViewCell.swift
//  sample-chat-swift
//
//  Created by Gleb Ustimenko on 07.07.15.
//  Copyright (c) 2015 quickblox. All rights reserved.
//

import UIKit

class DialogTableViewCell: SWTableViewCell {
    
//    @IBOutlet private weak var colorMarker: CornerView!
    
    @IBOutlet weak var dialogLastMessage: UILabel!
    @IBOutlet weak var dialogName: UILabel!
    @IBOutlet weak var dialogTypeImage: UIImageView!
    
    var dialogID = ""
}