//
//  PresenterViewController.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 1/27/20.
//  Copyright © 2020 quickBlox. All rights reserved.
//

import UIKit

class AuthNavigationController: UINavigationController { }
class UsersNavigationController: UINavigationController { }

class PresenterViewController: UIViewController {
    //MARK: - Properties
    private var current: UIViewController!
    private let profile = Profile()
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profile.isFull == false ? showLoginScreen() : showUsersScreen()
    }
    
    //MARK: - Internal Methods
    private func showLoginScreen() {
        guard let authVC = Screen.authViewController() else {
            return
        }
        authVC.onCompleteAuth = { [weak self] in
            self?.showUsersScreen()
        }
        let authNavVC = AuthNavigationController(rootViewController: authVC)
        authNavVC.navigationTitleColor(.white)
        if current == nil {
            current = authNavVC
        }
        changeCurrentViewController(authNavVC)
    }
    
    private func showUsersScreen() {
        guard let usersVC = Screen.usersViewController() else {
            return
        }
        let usersScreen = UsersNavigationController(rootViewController: usersVC)
        usersVC.onSignOut = { [weak self] in
            self?.showLoginScreen()
        }
        usersScreen.navigationTitleColor(.white)
        if current == nil {
            current = usersScreen
        }
        changeCurrentViewController(usersScreen)
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
