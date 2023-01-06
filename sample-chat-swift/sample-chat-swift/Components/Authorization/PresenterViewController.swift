//
//  PresenterViewController.swift
//  sample-chat-swift
//
//  Created by Injoit on 1/27/20.
//  Copyright © 2020 quickBlox. All rights reserved.
//

import UIKit

class AuthNavigationController: UINavigationController { }
class DialogsNavigationController: UINavigationController { }

class PresenterViewController: UIViewController {
    //MARK: - Properties
    private var current: UIViewController!
    private var dialogsScreen: DialogsNavigationController!
    private let notificationsProvider = NotificationsProvider()
    private let profile = Profile()
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profile.isFull == false ? showLoginScreen() : showDialogsScreen()
        notificationsProvider.delegate = self
    }
    
    //MARK: - Internal Methods
    private func showLoginScreen() {
        guard let authVC = Screen.authViewController() else {
            return
        }
        authVC.onCompleteAuth = { [weak self] in
            self?.showDialogsScreen()
        }
        let authNavVC = AuthNavigationController(rootViewController: authVC)
        authNavVC.navigationTitleColor(.white)
        if current == nil {
            current = authNavVC
        }
        changeCurrentViewController(authNavVC)
    }
    
    private func showDialogsScreen() {
        if dialogsScreen == nil {
            guard let dialogsVC = Screen.dialogsViewController() else {
                return
            }
            dialogsVC.onSignOut = { [weak self] in
                self?.showLoginScreen()
                self?.dialogsScreen = nil
            }
            dialogsScreen = DialogsNavigationController(rootViewController: dialogsVC)
        }
        dialogsScreen.navigationTitleColor(.white)
        if current == nil {
            current = dialogsScreen
        }
        changeCurrentViewController(dialogsScreen)
        notificationsProvider.registerForRemoteNotifications()
    }
    
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
    
    //MARK - Setup
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension PresenterViewController: NotificationsProviderDelegate {
    func notificationsProvider(_ notificationsProvider: NotificationsProvider, didReceive dialogID: String) {
        if dialogID.isEmpty {
            return
        }
        showDialogsScreen()
    }
}
