//
//  Toolbar.swift
//  sample-videochat-webrtc-swift
//
//  Created by Vitaliy Gorbachov on 4/27/18.
//  Copyright © 2018 Quickblox. All rights reserved.
//

import UIKit

class Toolbar: UIToolbar {
    
    var buttons: [UIButton]
    var actions: [(_ sender: UIButton) -> Void]
    
    required init?(coder aDecoder: NSCoder) {
        self.buttons = []
        self.actions = []
        
        super.init(coder: aDecoder)
        
        self.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        self.setShadowImage(UIImage(), forToolbarPosition: .any)
        
        self.backgroundColor = UIColor.white
    }
    
    func updateItems() {
        
        var items: [UIBarButtonItem] = []
        let fs = UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        for button in self.buttons {
            
            let item = UIBarButtonItem.init(customView: button)
            items.append(contentsOf: self.items!)
            items.append(fs)
            items.append(item)
        }
        
        items.append(fs)
        self.setItems(items, animated: false)
    }
    
    func addButton(button: UIButton, action:@escaping (_ sender: UIButton) -> Void) {
        
        button.addTarget(self, action: #selector(Toolbar.pressButton(button:)), for: .touchUpInside)
        self.buttons.append(button)
        self.actions.append(action)
    }
    
    @objc func pressButton(button: ToolbarButton) {
        let idx = self.buttons.index(of: button)
        let action = self.actions[idx!]
        action(button)
    }
}
