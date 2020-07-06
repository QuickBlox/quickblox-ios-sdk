//
//  QBToolBar.swift
//  sample-conference-videochat-swift
//
//  Created by Injoit on 04.10.2018.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit

class ToolBar: UIToolbar {
    //MARK: - Properties
    private var buttons: [UIButton] = []
    private var actions: [(_ sender: UIButton?) -> Void] = []
    
    //MARK: - Life Circle
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        setShadowImage(UIImage(), forToolbarPosition: .any)
        //Default Clear
        backgroundColor = .clear
    }
    
    //MARK: - Public Methods
    func removeAllButtons() {
        buttons.removeAll()
        actions.removeAll()
        updateItems()
    }
    
    func updateItems() {
        self.items = [UIBarButtonItem]()
        var items = [UIBarButtonItem]()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        items.append(flexibleSpace)
        for button in buttons {
            let item = UIBarButtonItem(customView: button)
            items.append(item)
            items.append(flexibleSpace)
        }
        self.items = items
    }
    
    func add(_ button: UIButton?, action: @escaping (_ sender: UIButton?) -> Void) {
        button?.addTarget(self, action: #selector(didTap(_:)), for: .touchUpInside)
        if let button = button {
            buttons.append(button)
        }
        actions.append(action)
    }
    
    //MARK: - Actions
    @objc func didTap(_ button: CustomButton) {
        guard let index = buttons.index(of: button) else { return }
        let action: ((_ sender: UIButton?) -> Void)? = actions[index]
        action?(button)
    }
}
