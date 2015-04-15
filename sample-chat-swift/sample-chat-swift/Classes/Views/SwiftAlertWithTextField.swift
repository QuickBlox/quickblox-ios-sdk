//
//  SwiftAlert.swift
//  sample-chat-swift
//
//  Created by Anton Sokolchenko on 4/7/15.
//  Copyright (c) 2015 quickblox. All rights reserved.
//

import UIKit

class SwiftAlertWithTextField: NSObject, UIAlertViewDelegate {
    
    private var callBack : ((Int) -> (Void))?
    private var unmanaged : Unmanaged<NSObject>?
    var alert: UIAlertController
    var alertViewControllerTextField: UITextField?
    /**
    @note: to present this alert use presentViewController(thisAlertView, animated: true, completion: nil)
    :param: cancelButtonTitle cancelButtonTitle has index 0
    */
    init(title: String?,  message: String?, showOver: UIViewController!, didClickOk closureOk:(text: String?) -> Void, didClickCancel closureCancel:() -> Void){
        alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        super.init()
        
        
        let ok = UIAlertAction(title: "OK", style: .Default, handler: { [weak self] (action) -> Void in
            if let strongSelf = self {
                closureOk(text: strongSelf.alertViewControllerTextField?.text)
            }
            })
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel) { (action) -> Void in
            closureCancel();
        }
        
        alert.addAction(ok)
        alert.addAction(cancel)
        
        alert.addTextFieldWithConfigurationHandler {[weak self] (textField) -> Void in
            if let strongSelf = self {
                strongSelf.alertViewControllerTextField = textField
            }
        }
        
        showOver.presentViewController(alert, animated: true, completion: nil)
        
        self.unmanaged = Unmanaged.passRetained(self)
    }
    
}