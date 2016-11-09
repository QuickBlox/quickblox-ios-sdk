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
    private var closureOk: ((_ text: String?) -> Void)?
    private var closureCancel: (() -> Void)?
    
    
    private var unmanaged : Unmanaged<NSObject>?
    var alert: AnyObject?
    var alertViewControllerTextField: UITextField?
    
    /**
     @note: cancelButtonTitle cancelButtonTitle has index 0
     */
    init(title: String?,  message: String?, showOver: UIViewController!, didClickOk closureOk:@escaping (_ text: String?) -> Void, didClickCancel closureCancel:@escaping () -> Void){
        super.init()
        
        self.closureOk = closureOk
        self.closureCancel = closureCancel
        
        // ios 8
        if #available(iOS 8.0, *) {
            alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let ok = UIAlertAction(title: "SA_STR_OK".localized, style: .default, handler: { [weak self] (action) -> Void in
                if let strongSelf = self {
                    closureOk(strongSelf.alertViewControllerTextField?.text)
                    strongSelf.unmanaged?.release()
                }
                })
            let cancel = UIAlertAction(title: "SA_STR_CANCEL".localized, style: .cancel) { (action) -> Void in
                closureCancel();
            }
            
            alert!.addAction(ok)
            alert!.addAction(cancel)
            
            alert!.addTextField(configurationHandler: { [weak self] (textField) in
                
                if let strongSelf = self {
                    strongSelf.alertViewControllerTextField = textField
                    strongSelf.unmanaged?.release()
                }
                })
            
            showOver.present(alert! as! UIAlertController, animated: true, completion: nil)
            
        }
        else {
            
            let alertMessage = message == nil ? "" : message
            let alertTitle = title == nil ? "" : title
            
            alertView = UIAlertView(title: alertTitle!, message: alertMessage!, delegate: self, cancelButtonTitle: "SA_STR_CANCEL".localized, otherButtonTitles: "SA_STR_OK".localized)
            alertView!.alertViewStyle = UIAlertViewStyle.plainTextInput
            alertView!.show()
            
        }
        
        self.unmanaged = Unmanaged.passRetained(self)
    }
    
    internal func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        
        if buttonIndex == alertView.cancelButtonIndex {
            
            self.closureCancel?()
        }
        else {
            
            self.closureOk?(alertView.textField(at: 0)?.text)
        }
        
        self.unmanaged?.release()
    }
}
