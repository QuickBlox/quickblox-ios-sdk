//
//  RootParentVC.swift
//  sample-chat-swift
//
//  Created by Injoit on 1/27/20.
//  Copyright © 2020 quickBlox. All rights reserved.
//

import UIKit

class DialogsNavigationController: UINavigationController { }

class RootParentVC: UIViewController {
    //MARK: - Properties
    var current: UIViewController
    var dialogID: String? {
        didSet {
            handlePush()
        }
    }
    
    //MARK: - Life Cycle
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
        
        changeCurrentViewController(current)
    }
    
    // MARK: - Public Methods
    func showLoginScreen() {
        let storyboard = UIStoryboard(name: "Authorization", bundle: nil)
        let authNavVC = storyboard.instantiateViewController(withIdentifier: "AuthNavVC") as! UINavigationController
        
        changeCurrentViewController(authNavVC)
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
            
            changeCurrentViewController(dialogsScreen)

            handlePush()
        }
    }
    
    //MARK: - Internal Methods
    private func changeCurrentViewController(_ newCurrentViewController: UIViewController) {
            addChild(newCurrentViewController)
            newCurrentViewController.view.frame = view.bounds
            view.addSubview(newCurrentViewController.view)
            newCurrentViewController.didMove(toParent: self)
            
            if current == newCurrentViewController {
                return
            }
            current.willMove(toParent: nil)
            current.view.removeFromSuperview()
            current.removeFromParent()
            current = newCurrentViewController
        }
    
    private func handlePush() {
        if let dialogsNavigationController = current as? DialogsNavigationController, let dialogID = dialogID {
            if let dialog = ChatManager.instance.storage.dialog(withID: dialogID) {
                // Autojoin to the group chat
                if dialog.type != .private, dialog.isJoined() == false {
                    dialog.join(completionBlock: { error in
                        guard let error = error else {
                            return
                        }
                        debugPrint("[RootParentVC] dialog.join error: \(error.localizedDescription)")
                    })
                }
                dialogsNavigationController.popToRootViewController(animated: false)
                (dialogsNavigationController.topViewController as? DialogsViewController)?.openChatWithDialogID(dialogID)
                self.dialogID = nil
            }
        }
    }
    
    //MARK - Setup
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
