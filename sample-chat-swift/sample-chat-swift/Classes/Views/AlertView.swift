//
//  AlertView.swift
//  sample-chat-swift
//
//  Created by Anton Sokolchenko on 4/7/15.
//  Copyright (c) 2015 quickblox. All rights reserved.
//

import UIKit

class AlertView: NSObject, UIAlertViewDelegate {
    
    private var callBack : ((Int) -> (Void))?
    private var unmanaged : Unmanaged<NSObject>?
    var alert: UIAlertView
    
    /**
    - parameter cancelButtonTitle: cancelButtonTitle has index 0
    */
    init(title: String?, message: String?, cancelButtonTitle: String?, otherButtonTitle:[String], didClick closure:(buttonIndex:Int) -> Void) {
        alert = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: cancelButtonTitle)
        super.init() // To set the delegate as self we need to call its super.init() first.
        alert.delegate = self
        
        //Add buttons from otherButtonTitle
        for (_, title) in otherButtonTitle.enumerate() {
            alert.addButtonWithTitle(title)
        }
        
        self.callBack = closure
        self.unmanaged = Unmanaged.passRetained(self)
        
        alert.show()
    }
    
    internal func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if let action = self.callBack {
            action(buttonIndex)
        }
        self.unmanaged?.release()
    }
}
