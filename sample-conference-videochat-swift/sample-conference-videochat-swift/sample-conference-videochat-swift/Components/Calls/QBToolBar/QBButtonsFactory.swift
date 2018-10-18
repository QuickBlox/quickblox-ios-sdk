//
//  QBButtonsFactory.swift
//  sample-conference-videochat-swift
//
//  Created by Vladimir Nybozhinsky on 04.10.2018.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit

struct QBButtonsFactoryConstants {
    static let kDefRect: CGRect = CGRect(x: 0, y: 0, width: 44, height: 44)
    static let kDefDeclineRect: CGRect = CGRect(x: 0, y: 0, width: 96, height: 44)
    static let kDefCircleDeclineRect: CGRect = CGRect(x: 0, y: 0, width: 44, height: 44)
    
    static let kDefBackgroundColor = UIColor(red: 0.8118, green: 0.8118, blue: 0.8118, alpha: 1.0)
    static let kDefSelectedColor = UIColor(red: 0.3843, green: 0.3843, blue: 0.3843, alpha: 1.0)
    static let kDefDeclineColor = UIColor(red: 0.8118, green: 0.0, blue: 0.0784, alpha: 1.0)
    static let kDefAnswerColor = UIColor(red: 0.1434, green: 0.7587, blue: 0.1851, alpha: 1.0)
}

class QBButtonsFactory {
    // MARK: - Private
    class func button(withFrame frame: CGRect, backgroundColor: UIColor?, selectedColor: UIColor?) -> QBButton? {
        
        let button = QBButton(frame: frame)
        button.backgroundColor = backgroundColor
        button.selectedColor = selectedColor
        
        return button
    }
    
    class func iconView(withNormalImage normalImage: String?, selectedImage: String?) -> UIImageView? {
        
        let icon = UIImage(named: normalImage ?? "")
        let selectedIcon = UIImage(named: selectedImage ?? "")
        
        let iconView = UIImageView(image: icon, highlightedImage: selectedIcon)
        
        iconView.contentMode = .scaleAspectFit
        
        return iconView
    }
    
    // MARK: - Public
    class func videoEnable() -> QBButton? {
        
        let button: QBButton? = self.button(withFrame: QBButtonsFactoryConstants.kDefRect, backgroundColor:QBButtonsFactoryConstants.kDefBackgroundColor, selectedColor: QBButtonsFactoryConstants.kDefSelectedColor)
        button?.pushed = true
        
        button?.iconView = self.iconView(withNormalImage: "camera_on_ic", selectedImage: "camera_off_ic")
        return button
    }
    
    class func auidoEnable() -> QBButton? {
        
        let button: QBButton? = self.button(withFrame: QBButtonsFactoryConstants.kDefRect, backgroundColor: QBButtonsFactoryConstants.kDefBackgroundColor, selectedColor: QBButtonsFactoryConstants.kDefSelectedColor)
        
        button?.pushed = true
        
        button?.iconView = self.iconView(withNormalImage: "mute_on_ic", selectedImage: "mute_off_ic")
        return button
    }
    
    class func dynamicEnable() -> QBButton? {
        
        let button: QBButton? = self.button(withFrame: QBButtonsFactoryConstants.kDefRect, backgroundColor: QBButtonsFactoryConstants.kDefBackgroundColor, selectedColor: QBButtonsFactoryConstants.kDefSelectedColor)
        
        button?.pushed = true
        
        button?.iconView = self.iconView(withNormalImage: "dynamic_on_ic", selectedImage: "dynamic_off_ic")
        return button
    }
    
    class func screenShare() -> QBButton? {
        
        let button: QBButton? = self.button(withFrame: QBButtonsFactoryConstants.kDefRect, backgroundColor: QBButtonsFactoryConstants.kDefBackgroundColor, selectedColor: QBButtonsFactoryConstants.kDefSelectedColor)
        
        button?.iconView = self.iconView(withNormalImage: "screensharing_ic", selectedImage: "screensharing_ic")
        return button
    }
    
    class func answer() -> QBButton? {
        
        let button: QBButton? = self.button(withFrame: QBButtonsFactoryConstants.kDefRect, backgroundColor: QBButtonsFactoryConstants.kDefAnswerColor, selectedColor: QBButtonsFactoryConstants.kDefSelectedColor)
        
        button?.iconView = self.iconView(withNormalImage: "answer", selectedImage: "answer")
        return button
    }
    
    class func decline() -> QBButton? {
        
        let button: QBButton? = self.button(withFrame: QBButtonsFactoryConstants.kDefDeclineRect, backgroundColor: QBButtonsFactoryConstants.kDefDeclineColor, selectedColor: QBButtonsFactoryConstants.kDefSelectedColor)
        
        button?.iconView = self.iconView(withNormalImage: "decline-ic", selectedImage: "decline-ic")
        return button
    }
    
    class func circleDecline() -> QBButton? {
        
        let button: QBButton? = self.button(withFrame: QBButtonsFactoryConstants.kDefCircleDeclineRect, backgroundColor: QBButtonsFactoryConstants.kDefDeclineColor, selectedColor: QBButtonsFactoryConstants.kDefSelectedColor)
        
        button?.iconView = self.iconView(withNormalImage: "decline-ic", selectedImage: "decline-ic")
        return button
    }
}
