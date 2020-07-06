//
//  RootParentVC.swift
//  sample-conference-videochat-swift
//
//  Created by Injoit on 1/27/20.
//  Copyright © 2020 quickBlox. All rights reserved.
//

import UIKit

class DialogsNavigationController: UINavigationController { }

class RootParentVC: UIViewController {
    var current: UIViewController
    var dialogID: String? {
        didSet {
            handlePush()
        }
    }
    
    init() {
        let storyboard = UIStoryboard(name: "Authorization", bundle: nil)
        current = storyboard.instantiateViewController(withIdentifier: "SplashScreenVC") as! SplashScreenVC
        super.init(nibName:  nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addChild(current)
        current.view.frame = view.bounds
        view.addSubview(current.view)
        current.didMove(toParent: self)
    }
    
    func showLoginScreen() {
        let storyboard = UIStoryboard(name: "Authorization", bundle: nil)
        let authNavVC = storyboard.instantiateViewController(withIdentifier: "AuthNavVC") as! UINavigationController
        
        addChild(authNavVC)
        authNavVC.view.frame = view.bounds
        view.addSubview(authNavVC.view)
        authNavVC.didMove(toParent: self)
        
        current.willMove(toParent: nil)
        current.view.removeFromSuperview()
        current.removeFromParent()
        current = authNavVC
    }
    
    func goToDialogsScreen() {
        let storyboard = UIStoryboard(name: "Dialogs", bundle: nil)
        if let dialogsVC = storyboard.instantiateViewController(withIdentifier: "DialogsViewController") as? DialogsViewController {
            let dialogsScreen = DialogsNavigationController(rootViewController: dialogsVC)
            dialogsScreen.navigationBar.barTintColor = #colorLiteral(red: 0.2216441333, green: 0.4713830948, blue: 0.9869660735, alpha: 1)
            dialogsScreen.navigationBar.barStyle = .black
            dialogsScreen.navigationBar.shadowImage = UIImage()
            dialogsScreen.navigationBar.isTranslucent = false
            dialogsScreen.navigationBar.tintColor = .white
            dialogsScreen.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            
            addChild(dialogsScreen)
            dialogsScreen.view.frame = view.bounds
            view.addSubview(dialogsScreen.view)
            dialogsScreen.didMove(toParent: self)
            
            current.willMove(toParent: nil)
            current.view.removeFromSuperview()
            current.removeFromParent()
            current = dialogsScreen
        }
    }
    
    private func handlePush() {
        if let dialogsNavigationController = current as? DialogsNavigationController, let dialogID = self.dialogID {
            dialogsNavigationController.popToRootViewController(animated: false)
            (dialogsNavigationController.topViewController as? DialogsViewController)?.openChatWithDialogID(dialogID)
            self.dialogID = nil
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
