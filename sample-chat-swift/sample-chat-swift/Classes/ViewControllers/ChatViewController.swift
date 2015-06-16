//
//  ChatViewController.swift
//  sample-chat-swift
//
//  Created by Anton Sokolchenko on 4/1/15.
//  Copyright (c) 2015 quickblox. All rights reserved.
//

class ChatViewController: QMChatViewController, QMChatServiceDelegate {
    var dialog: QBChatDialog?
    var shouldFixViewControllersStack = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.shouldFixViewControllersStack {
            
            var viewControllers: [UIViewController] = []
            
            if let loginViewControllers = self.navigationController?.viewControllers[0] as? LoginTableViewController {
                viewControllers.append(loginViewControllers)
            }
            
            if let dialogsViewControllers = self.navigationController?.viewControllers[1] as? DialogsViewController {
                viewControllers.append(dialogsViewControllers)
            }
            
            if let chatViewControllers = self.navigationController?.viewControllers.last as? ChatViewController {
                viewControllers.append(chatViewControllers)
            }
            
            self.navigationController?.viewControllers = viewControllers
        }
        
//        self.inputToolbar.contentView.leftBarButtonItem = self.accessoryButtonItem;
//        self.inputToolbar.contentView.rightBarButtonItem = self.sendButtonItem;
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        ServicesManager.instance.chatService.addDelegate(self)
    }
	
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        SVProgressHUD.dismiss()
        
        ServicesManager.instance.chatService.removeDelegate(self);
    }
    
    // MARK: Strings builder
    
    override func attributedStringForItem(messageItem: QBChatMessage!) -> NSAttributedString! {
        
        var textColor : UIColor?
        
        if messageItem.senderID == self.senderID {
            textColor = UIColor.whiteColor()
        } else {
            textColor = UIColor(white: 0.29, alpha: 1)
        }
        
        var attributes = Dictionary<String, AnyObject>()
        attributes[NSForegroundColorAttributeName] = textColor
        attributes[NSFontAttributeName] = UIFont(name: "Helvetica", size: 15)
        
        var attributedString = NSAttributedString(string: messageItem.text, attributes: attributes)
        
        return attributedString
    }
    
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func topLabelAttributedStringForItem(messageItem: QBChatMessage!) -> NSAttributedString? {

        if messageItem.senderID == self.senderID {
            return nil
        }
        
        var attributes = Dictionary<String, AnyObject>()
        attributes[NSForegroundColorAttributeName] = UIColor(red: 0.184, green: 0.467, blue: 0.733, alpha: 1)
        attributes[NSFontAttributeName] = UIFont(name: "Helvetica", size: 14)
        
        var topLabelText = messageItem.senderNick ?? String(messageItem.senderID)
        
        var topLabelAttributedString = NSAttributedString(string: topLabelText, attributes: attributes)
        
        return topLabelAttributedString
    }
    
    func bottomLabelAttributedStringForItem(messageItem: QBChatMessage!) -> NSAttributedString! {
        
    }
}
