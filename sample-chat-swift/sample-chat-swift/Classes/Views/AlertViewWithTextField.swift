//
//  AlertViewWithTextField.swift
//  sample-chat-swift
//
//  Created by Anton Sokolchenko on 4/7/15.
//  Copyright (c) 2015 quickblox. All rights reserved.
//

import UIKit

class AlertViewWithTextField: NSObject, UIAlertViewDelegate {
    
    // ios 7 support
    private var alertView: UIAlertView?
    private var closureOk: ((text: String?) -> Void)?
    private var closureCancel: (() -> Void)?
    
    
    private var unmanaged : Unmanaged<NSObject>?
    var alert: UIAlertController?
    var alertViewControllerTextField: UITextField?
    
    /**
    @note: cancelButtonTitle cancelButtonTitle has index 0
    */
    init(title: String?,  message: String?, showOver: UIViewController!, didClickOk closureOk:(text: String?) -> Void, didClickCancel closureCancel:() -> Void){
        super.init()
        
        self.closureOk = closureOk
        self.closureCancel = closureCancel
        
        // ios 8
        if objc_getClass("UIAlertController") != nil {
            alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            let ok = UIAlertAction(title: "OK", style: .Default, handler: { [weak self] (action) -> Void in
                if let strongSelf = self {
                    closureOk(text: strongSelf.alertViewControllerTextField?.text)
                    strongSelf.unmanaged?.release()
                }
                })
            let cancel = UIAlertAction(title: "Cancel", style: .Cancel) { (action) -> Void in
                closureCancel();
            }
            
            alert!.addAction(ok)
            alert!.addAction(cancel)
            
            alert!.addTextFieldWithConfigurationHandler {[weak self] (textField) -> Void in
                if let strongSelf = self {
                    strongSelf.alertViewControllerTextField = textField
                    strongSelf.unmanaged?.release()
                }
            }
            
            showOver.presentViewController(alert!, animated: true, completion: nil)
        } // ios 7
        else {
            var alertMessage = message == nil ? "" : message
            var alertTitle = title == nil ? "" : title

            alertView = UIAlertView(title: alertTitle!, message: alertMessage!, delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Ok")
            alertView!.alertViewStyle = UIAlertViewStyle.PlainTextInput
            alertView!.show()
            
        }
        self.unmanaged = Unmanaged.passRetained(self)
    }
    
    internal func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == alertView.cancelButtonIndex {
            if self.closureCancel != nil {
                self.closureCancel!()
            }
        }
        else {
            if self.closureOk != nil {
                self.closureOk!(text: alertView.textFieldAtIndex(0)?.text)
            }
        }
        self.unmanaged?.release()
    }
    
}