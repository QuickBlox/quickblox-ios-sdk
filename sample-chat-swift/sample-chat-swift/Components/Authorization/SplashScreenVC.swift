//
//  SplashScreenVC.swift
//  sample-chat-swift
//
//  Created by Injoit on 1/27/20.
//  Copyright © 2020 quickBlox. All rights reserved.
//

import UIKit
//import UserNotifications

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
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let profile = Profile()
        if profile.isFull == false {
            DispatchQueue.main.async {
                AppDelegate.shared.rootViewController.showLoginScreen()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //MARK: - Reachability
        let updateLoginInfo: ((_ status: NetworkConnectionStatus) -> Void)? = { [weak self] status in
            let notConnection = status == .notConnection
            let loginInfo = notConnection ? LoginConstant.checkInternet : LoginStatusConstant.intoChat
            let profile = Profile()
            if profile.isFull == true, notConnection == false {
                self?.login(fullName: profile.fullName, login: profile.login)
            }
            self?.infoText = loginInfo
        }
        
        Reachability.instance.networkStatusBlock = { status in
            updateLoginInfo?(status)
        }
        updateLoginInfo?(Reachability.instance.networkConnectionStatus())
    }
    
    //MARK: - Internal Methods
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
                            Profile.synchronize(user)
                            self.connectToChat(user: user)
                            
                        }, errorBlock: { [weak self] response in
                            self?.handleError(response.error?.error, domain: ErrorDomain.logIn)
                            if response.status == QBResponseStatusCode.unAuthorized {
                                // Clean profile
                                Profile.clearProfile()
                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
                                    AppDelegate.shared.rootViewController.showLoginScreen()
                                }
                            }
                            
                        })
    }
    
    /**
     *  connectToChat
     */
    private func connectToChat(user: QBUUser) {
        infoText = LoginStatusConstant.intoChat
        if QBChat.instance.isConnected == true {
            //did Login action
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
                AppDelegate.shared.rootViewController.goToDialogsScreen()
            }
        } else {
            QBChat.instance.connect(withUserID: user.id,
                                    password: LoginConstant.defaultPassword,
                                    completion: { [weak self] error in
                                        guard self != nil else { return }
                                        if let error = error {
                                            if error._code == QBResponseStatusCode.unAuthorized.rawValue {
                                                // Clean profile
                                                Profile.clearProfile()
                                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) { AppDelegate.shared.rootViewController.showLoginScreen()
                                                }
                                            }
                                            
                                        } else {
                                            //did Login action
                                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
                                                AppDelegate.shared.rootViewController.goToDialogsScreen()
                                            }
                                        }
                                    })
        }
    }
    
    // MARK: - Handle errors
    private func handleError(_ error: Error?, domain: ErrorDomain) {
        guard let error = error else {
            return
        }
        var infoText = error.localizedDescription
        if error._code == NSURLErrorNotConnectedToInternet {
            infoText = LoginConstant.checkInternet
        }
        self.infoText = infoText
    }
}
