//
//  SplashScreenVC.swift
//  sample-chat-swift
//
//  Created by Injoit on 1/27/20.
//  Copyright © 2020 quickBlox. All rights reserved.
//

import UIKit
import Quickblox

class SplashScreenViewController: UIViewController {
    var onCompleteAuth: (() -> Void)?
    var onSignIn: (() -> Void)?
    //MARK: - IBOutlets
    @IBOutlet weak var loginInfoLabel: UILabel!
    private var isPresentAlert = false
    
    //MARK: - Properties
    private var infoText = "" {
        didSet {
            loginInfoLabel.text = infoText
        }
    }
    private let profile = Profile()
    
    //MARK: - Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if profile.isFull == false {
            onSignIn?()
            return
        }
        QBChat.instance.addDelegate(self)
        connectToChat(profile.ID)
    }
    
    //MARK: - Internal Methods
    private func connectToChat(_ userID: UInt) {
        infoText = LoginConstant.intoChat
        QBChat.instance.connect(withUserID: userID,
                                password: LoginConstant.defaultPassword,
                                completion: { error in
            if let error = error, error._code == QBResponseStatusCode.unAuthorized.rawValue {
                Profile.clear()
                self.onSignIn?()
                return
            }
            self.onCompleteAuth?()
        })
    }
}

//MARK: - QBChatDelegate
extension SplashScreenViewController: QBChatDelegate {
    func chatDidDisconnectWithError(_ error: Error?) {
        guard isPresentAlert == false, let error = error, error._code == 8  else { return }
        isPresentAlert = true
        showNoInternetAlert(handler: { [weak self] (action) in
            guard let self = self else {
                return
            }
            self.connectToChat(Profile().ID)
            self.isPresentAlert = false
        })
    }
}
