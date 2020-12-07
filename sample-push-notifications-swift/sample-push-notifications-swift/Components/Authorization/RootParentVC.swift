//
//  RootParentVC.swift
//  sample-push-notifications-swift
//
//  Created by Injoit on 1/27/20.
//  Copyright © 2020 QuickBlox. All rights reserved.
//

import UIKit

class PushesNavigationController: UINavigationController { }

class RootParentVC: UIViewController {
    //MARK: - Properties
    var current: UIViewController
    
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
    
    func showPushScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let pushVC = storyboard.instantiateViewController(withIdentifier: "PushViewController") as? PushViewController {
            let pushScreen = PushesNavigationController(rootViewController: pushVC)
            pushScreen.navigationBar.barTintColor = #colorLiteral(red: 0.2216441333, green: 0.4713830948, blue: 0.9869660735, alpha: 1)
            pushScreen.navigationBar.barStyle = .black
            pushScreen.navigationBar.shadowImage = UIImage()
            pushScreen.navigationBar.isTranslucent = false
            pushScreen.navigationBar.tintColor = .white
            pushScreen.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            
            changeCurrentViewController(pushScreen)
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

    //MARK - Setup
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
