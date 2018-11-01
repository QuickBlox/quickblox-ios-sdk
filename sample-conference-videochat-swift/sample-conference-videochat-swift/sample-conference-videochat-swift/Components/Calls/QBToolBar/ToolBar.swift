//
//  QBToolBar.swift
//  sample-conference-videochat-swift
//
//  Created by Vladimir Nybozhinsky on 04.10.2018.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit

class ToolBar: UIToolbar {
    
    private var buttons: [UIButton] = []
    private var actions: [(_ sender: UIButton?) -> Void] = []
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        setShadowImage(UIImage(), forToolbarPosition: .any)
        //Default Gray
        backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3)
        
    }
    
    func updateItems() {
        var items = [UIBarButtonItem]()
        let fs = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        for button in buttons {
            var item: UIBarButtonItem? = nil
                item = UIBarButtonItem(customView: button)
            guard let itemsCount = self.items?.count else { return }
            if itemsCount > 0 {
                items = items + self.items!
            }
            items.append(fs)
            if let anItem = item {
                items.append(anItem)
            }
        }
        items.append(fs)
        self.items = items
    }
    
    func add(_ button: UIButton?, action: @escaping (_ sender: UIButton?) -> Void) {
        button?.addTarget(self, action: #selector(self.press(_:)), for: .touchUpInside)
        if let button = button {
            buttons.append(button)
        }
        actions.append(action)
    }
    
    @objc func press(_ button: CustomButton) {
        guard let idx = buttons.index(of: button) else { return }
        let action: ((_ sender: UIButton?) -> Void)? = actions[idx]
        action?(button)
    }
}
