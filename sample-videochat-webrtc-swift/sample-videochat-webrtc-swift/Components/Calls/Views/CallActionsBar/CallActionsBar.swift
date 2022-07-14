//
//  CallActionsBar.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 04.10.2018.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit

enum ActionType: Int {
    case audio
    case video
    case speaker
    case decline
    case share
    case switchCamera
}

typealias CallActionHandler = (_ sender: ActionButton?) -> Void

class CallAction {
    var button = ActionButton()
    var action: CallActionHandler!
}

struct ActionsBarConstants {
    static let rect = CGRect(x: 0.0, y: 0.0, width: 56.0, height: 76.0)
}

class CallActionsBar: UIToolbar {
    //MARK: - Properties
    private var buttons: [CallAction] = []
    
    //MARK: - Life Circle
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        setShadowImage(UIImage(), forToolbarPosition: .any)
        //Default Clear
        backgroundColor = .clear
    }
    
    //MARK: - Public Methods
    func setup(withActions actions: [(type: ActionType, action: (_ sender: ActionButton?) -> Void)]) {
        var oldButtons: [Int: CallAction] = [:]
        if buttons.isEmpty == false {
            for i in 0...buttons.count - 1 {
                oldButtons[buttons[i].button.tag] = buttons[i]
            }
        }
        buttons.removeAll()
        
        self.items = [UIBarButtonItem]()
        var buttonItems:[UIBarButtonItem] = []
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        buttonItems.append(flexibleSpace)
        for actionType in actions {
            let callAction = CallAction()
            
            let button = createButton(withType: actionType.type)
            button.addTarget(self, action: #selector(didTap(_:)), for: .touchUpInside)
            if oldButtons.isEmpty == false,
               let oldButton = oldButtons[actionType.type.rawValue]?.button,
               let oldAction = oldButtons[actionType.type.rawValue]?.action {
                button.pressed = oldButton.pressed
                callAction.action = oldAction
            }  else {
                callAction.action = actionType.action
            }
            callAction.button = button
            let item = UIBarButtonItem(customView: button)
            buttonItems.append(item)
            buttonItems.append(flexibleSpace)
            buttons.append(callAction)
        }
        self.items = buttonItems
    }
    
    private func createButton(withType tag: ActionType) -> ActionButton {
        let button = ActionButton(frame: ActionsBarConstants.rect)
        switch tag {
        case .audio:
            button.selectedTitle = "Unmute"
            button.unSelectedTitle = "Mute"
            button.pushed = false
            button.tag = tag.rawValue
            button.iconView = iconView(withNormalImage: "mute_on_ic", selectedImage: "mic_off")
        case .video:
            button.selectedTitle = "Cam on"
            button.unSelectedTitle = "Cam off"
            button.pushed = false
            button.tag = tag.rawValue
            button.iconView = iconView(withNormalImage: "camera_on_ic", selectedImage: "cam_off")
        case .speaker:
            button.selectedTitle = "Mic"
            button.unSelectedTitle = "Speaker"
            button.pushed = true
            button.tag = tag.rawValue
            button.iconView = iconView(withNormalImage: "speaker", selectedImage: "speaker_off")
        case .decline:
            button.selectedTitle = "End call"
            button.unSelectedTitle = "End call"
            button.pushed = true
            button.tag = tag.rawValue
            button.iconView = iconView(withNormalImage: "decline-ic", selectedImage: "decline-ic")
        case .share:
            button.selectedTitle = "Stop sharing"
            button.unSelectedTitle = "Screen share"
            button.iconView = iconView(withNormalImage: "screensharing_ic", selectedImage: "screenshare_selected")
            button.tag = tag.rawValue
        case .switchCamera:
            button.selectedTitle = "Swap cam"
            button.unSelectedTitle = "Swap cam"
            button.pushed = true
            button.tag = tag.rawValue
            button.iconView = iconView(withNormalImage: "switchCamera", selectedImage: "abort_swap")
        }
        
        return button
    }
    
    //MARK: - Actions
    func select(_ selected: Bool, type: ActionType) {
        guard let callAction = buttons.filter({ $0.button.tag == type.rawValue }).first else {
            return
        }
        callAction.button.pressed = selected
    }
    
    func isSelected(_ type: ActionType) -> Bool? {
        guard let callAction = buttons.filter({ $0.button.tag == type.rawValue }).first else { return nil }
        return callAction.button.pressed
    }
    
    func setUserInteractionEnabled(_ enabled: Bool, type: ActionType) {
        guard let callAction = buttons.filter({ $0.button.tag == type.rawValue }).first else {
            return
        }
        callAction.button.isUserInteractionEnabled = enabled
    }
    
    //MARK: - Private Methods
    @objc private func didTap(_ button: ActionButton) {
        guard let index = buttons.firstIndex(where: { $0.button.tag == button.tag }) else {
            return
        }
        let action: ((_ sender: ActionButton?) -> Void)? = buttons[index].action
        action?(button)
    }
    
    //MARK: - Utils
    private func iconView(withNormalImage normalImage: String, selectedImage: String) -> UIImageView? {
        let icon = UIImage(named: normalImage)
        let selectedIcon = UIImage(named: selectedImage)
        let iconView = UIImageView(image: icon, highlightedImage: selectedIcon)
        iconView.contentMode = .scaleAspectFit
        return iconView
    }
}
