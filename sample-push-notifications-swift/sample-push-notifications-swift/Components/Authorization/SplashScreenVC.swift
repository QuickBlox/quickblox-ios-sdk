//
//  SplashScreenVC.swift
//  sample-push-notifications-swift
//
//  Created by Injoit on 1/27/20.
//  Copyright © 2020 QuickBlox. All rights reserved.
//

import UIKit
import Quickblox

class SplashScreenVC: UIViewController {
    //MARK: - IBOutlets
    @IBOutlet weak var loginInfoLabel: UILabel!
    
    //MARK: - Properties
    private var infoText = "" {
        didSet {
            loginInfoLabel.text = infoText
        }
    }
    
    //MARK: - Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let profile = Profile()
        if profile.isFull == false {
            //Show Login screen
            AppDelegate.shared.rootViewController.showLoginScreen()
        } else {
            login(fullName: profile.fullName, login: profile.login)
        }
    }
    
    //MARK: - Internal Methods
    /**
     *  login
     */
    private func login(fullName: String, login: String, password: String = LoginConstant.defaultPassword) {
        infoText = LoginConstant.intoPushes
        QBRequest.logIn(withUserLogin: login,
                        password: password,
                        successBlock: { response, user in
                            
                            user.password = password
                            Profile.synchronize(withUser: user)
                            AppDelegate.shared.rootViewController.showPushScreen()
                        }, errorBlock: { response in
                            //Show Login screen
                            AppDelegate.shared.rootViewController.showLoginScreen()
                        })
    }
}
