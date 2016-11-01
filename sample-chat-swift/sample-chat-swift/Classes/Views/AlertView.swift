//
//  AlertView.swift
//  sample-chat-swift
//
//  Created by Anton Sokolchenko on 4/7/15.
//  Copyright (c) 2015 quickblox. All rights reserved.
//

import UIKit

class AlertView: NSObject, UIAlertViewDelegate {
    
    fileprivate var callBack : ((Int) -> (Void))?
    fileprivate var unmanaged : Unmanaged<NSObject>?
    var alert: UIAlertView
    
    /**
    - parameter cancelButtonTitle: cancelButtonTitle has index 0
    */
    init(title: String?, message: String?, cancelButtonTitle: String?, otherButtonTitle:[String], didClick closure:@escaping (_ buttonIndex:Int) -> Void) {
        alert = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: cancelButtonTitle)
        super.init() // To set the delegate as self we need to call its super.init() first.
        alert.delegate = self
        
        //Add buttons from otherButtonTitle
        for (_, title) in otherButtonTitle.enumerated() {
            alert.addButton(withTitle: title)
        }
        
        self.callBack = closure
        self.unmanaged = Unmanaged.passRetained(self)
        
        alert.show()
    }
    
    internal func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        
        alertView.delegate = nil;
        
        if let action = self.callBack {
            action(buttonIndex)
        }
        self.unmanaged?.release()
    }
}
