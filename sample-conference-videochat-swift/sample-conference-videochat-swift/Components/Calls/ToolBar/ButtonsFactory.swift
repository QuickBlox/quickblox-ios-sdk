//
//  ButtonsFactory.swift
//  sample-conference-videochat-swift
//
//  Created by Injoit on 04.10.2018.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit

struct ButtonsFactoryConstants {
    static let rect = CGRect(x: 0.0, y: 0.0, width: 56.0, height: 76.0)
    static let oldScreenRect = CGRect(x: 0.0, y: 0.0, width: 44.0, height: 44.0)
    
    static let backgroundColor = #colorLiteral(red: 0.8495520949, green: 0.8889414668, blue: 0.9678996205, alpha: 1)
    static let selectedColor = #colorLiteral(red: 0.4293757677, green: 0.4846315384, blue: 0.5802181363, alpha: 1)
    static let declineColor = #colorLiteral(red: 0.9356774688, green: 0.1954192817, blue: 0.2812524736, alpha: 1)
}

class ButtonsFactory {
    // MARK: - Class Methods
    class func button(withFrame frame: CGRect, backgroundColor: UIColor, selectedColor: UIColor, selectedTitle: String, unSelectedTitle: String) -> CustomButton {
        let button = CustomButton(frame: frame)
        button.selectedColor = selectedColor
        button.unSelectedColor = backgroundColor
        button.selectedTitle = selectedTitle
        button.unSelectedTitle = unSelectedTitle
        return button
    }
    
    class func iconView(withNormalImage normalImage: String, selectedImage: String) -> UIImageView? {
        let icon = UIImage(named: normalImage)
        let selectedIcon = UIImage(named: selectedImage)
        let iconView = UIImageView(image: icon, highlightedImage: selectedIcon)
        iconView.contentMode = .scaleAspectFit
        return iconView
    }
    
    class func videoEnable() -> CustomButton {
        let button: CustomButton = self.button(withFrame: ButtonsFactoryConstants.rect, backgroundColor:ButtonsFactoryConstants.backgroundColor, selectedColor: ButtonsFactoryConstants.selectedColor, selectedTitle: "Cam on", unSelectedTitle: "Cam off")
        button.pushed = true
        button.iconView = self.iconView(withNormalImage: "camera_on_ic", selectedImage: "cam_off")
        return button
    }
    
    class func audioEnable() -> CustomButton {
        let button: CustomButton = self.button(withFrame: ButtonsFactoryConstants.rect, backgroundColor: ButtonsFactoryConstants.backgroundColor, selectedColor: ButtonsFactoryConstants.selectedColor, selectedTitle: "Unmute", unSelectedTitle: "Mute")
        button.pushed = true
        button.iconView = self.iconView(withNormalImage: "mute_on_ic", selectedImage: "mic_off")
        return button
    }
    
    class func screenShare() -> CustomButton {
        let button: CustomButton = self.button(withFrame: ButtonsFactoryConstants.rect, backgroundColor: ButtonsFactoryConstants.backgroundColor, selectedColor: ButtonsFactoryConstants.selectedColor, selectedTitle: "Stop sharing", unSelectedTitle: "Screen share")
        button.iconView = self.iconView(withNormalImage: "screensharing_ic", selectedImage: "screenshare_selected")
        return button
    }
    
    class func swapCam() -> CustomButton {
        let button: CustomButton = self.button(withFrame: ButtonsFactoryConstants.rect, backgroundColor: ButtonsFactoryConstants.backgroundColor, selectedColor: ButtonsFactoryConstants.selectedColor, selectedTitle: "Swap cam", unSelectedTitle: "Swap cam")
        button.pushed = true
        button.iconView = self.iconView(withNormalImage: "switchCamera", selectedImage: "abort_swap")
        return button
    }
 
    class func decline() -> CustomButton {
        let button: CustomButton = self.button(withFrame: ButtonsFactoryConstants.rect, backgroundColor: ButtonsFactoryConstants.declineColor, selectedColor: ButtonsFactoryConstants.selectedColor, selectedTitle: "End call", unSelectedTitle: "End call")
        button.pushed = true
        button.iconView = self.iconView(withNormalImage: "decline-ic", selectedImage: "decline-ic")
        return button
    }
}
