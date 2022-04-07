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
    var current: UIViewController!
    let notificationsProvider = NotificationsProvider()

    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        notificationsProvider.delegate = self
        showSplashScreen()
    }
    
    //MARK: - Internal Methods
    private func showSplashScreen() {
        guard let splashVC = Screen.splashScreenController() else {
            return
        }
        splashVC.onSignIn = { [weak self] in
            self?.showLoginScreen()
        }
        splashVC.onCompleteAuth = { [weak self] in
            self?.showDialogsScreen()
        }
        current = splashVC
        changeCurrentViewController(current)
    }
    
    private func showLoginScreen() {
        guard let authVC = Screen.authViewController() else {
            return
        }
        authVC.onCompleteAuth = { [weak self] in
            self?.showDialogsScreen()
        }
        let authNavVC = AuthNavigationController(rootViewController: authVC)
        authNavVC.navigationTitleColor(.white)
        changeCurrentViewController(authNavVC)
    }
    
    private func showDialogsScreen() {
        guard let dialogsVC = Screen.dialogsViewController() else {
            return
        }
        let dialogsScreen = DialogsNavigationController(rootViewController: dialogsVC)
        dialogsVC.onSignIn = { [weak self] in
            self?.showLoginScreen()
        }
        dialogsScreen.navigationTitleColor(.white)
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
