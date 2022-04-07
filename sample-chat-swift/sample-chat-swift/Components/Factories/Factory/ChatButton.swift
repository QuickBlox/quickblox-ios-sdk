//
//  ChatButton.swift
//  sample-chat-swift
//
//  Created by Injoit on 15.03.2022.
//  Copyright © 2022 quickBlox. All rights reserved.
//

import UIKit

final class ChatButton {
     func accessoryButton() -> UIButton {
         let image = #imageLiteral(resourceName: "attachment_ic")
        return chatButton(with: image, size: CGSize(width: 32.0, height: 32.0))
    }
    
     func accessorySendButton() -> UIButton {
         let image = #imageLiteral(resourceName: "send")
         return chatButton(with: image, size: CGSize(width: 32.0, height: 28.0))
    }
    
    private func chatButton(with image: UIImage, size: CGSize) -> UIButton {
        let accessoryImage = image.withTintColor(#colorLiteral(red: 0.2216441333, green: 0.4713830948, blue: 0.9869660735, alpha: 1))
        let accessoryButton = UIButton(frame: CGRect(origin: .zero, size: size))
        accessoryButton.setImage(accessoryImage, for: .normal)
        accessoryButton.setImage(accessoryImage, for: .highlighted)
        accessoryButton.contentMode = .scaleAspectFit
        accessoryButton.backgroundColor = .clear
        accessoryButton.tintColor = #colorLiteral(red: 0.2216441333, green: 0.4713830948, blue: 0.9869660735, alpha: 1)
        return accessoryButton
    }
}
