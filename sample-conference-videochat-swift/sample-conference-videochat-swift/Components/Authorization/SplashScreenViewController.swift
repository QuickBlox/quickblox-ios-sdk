//
//  SplashScreenViewController.swift
//  sample-conference-videochat-swift
//
//  Created by Injoit on 1/27/20.
//  Copyright © 2020 quickBlox. All rights reserved.
//

import UIKit
import Quickblox

class SplashScreenViewController: UIViewController, SplashScreen {
    var onCompleteAuth: (() -> Void)?
    var onSignIn: (() -> Void)?
    
    @IBOutlet weak var loginInfoLabel: UILabel!
    private var infoText = "" {
        didSet {
            loginInfoLabel.text = infoText
        }
    }
    
    private let profile = Profile()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if profile.isFull == false {
            onSignIn?()
        }
        
        //MARK: - Reachability
        let updateLoginInfo: ((_ status: NetworkConnectionStatus) -> Void)? = { [weak self] status in
            guard let self = self else {
                return
            }
            let notConnection = status == .notConnection
            let loginInfo = notConnection ? LoginConstant.checkInternet : LoginConstant.intoConference
            if self.profile.isFull == true, notConnection == false {
                self.login(fullName: self.profile.fullName, login: self.profile.login)
            }
            self.infoText = loginInfo
        }
        
        Reachability.instance.networkStatusBlock = { status in
            updateLoginInfo?(status)
        }
        updateLoginInfo?(Reachability.instance.networkConnectionStatus())
    }
    
    /**
     *  login
     */
    private func login(fullName: String, login: String, password: String = LoginConstant.defaultPassword) {
        QBRequest.logIn(withUserLogin: login,
                        password: password,
                        successBlock: { [weak self] response, user in
                            guard let self = self else {
                                return
                            }
                            
                            user.password = password
                            Profile.synchronize(withUser: user)
                            self.connectToChat(user: user)
                            
                        }, errorBlock: { [weak self] response in
                            Profile.clear()
                            self?.onSignIn?()
                        })
    }
    
    /**
     *  connectToChat
     */
    private func connectToChat(user: QBUUser) {
        infoText = LoginConstant.intoConference
        QBChat.instance.connect(withUserID: user.id,
                                password: LoginConstant.defaultPassword,
                                completion: { error in
                                    if error != nil {
                                        Profile.clear()
                                        self.onSignIn?()
                                    } else {
                                        //did Login action
                                        self.onCompleteAuth?()
                                    }
                                })
    }
}
