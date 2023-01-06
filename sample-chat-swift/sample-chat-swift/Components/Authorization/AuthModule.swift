//
//  AuthModule.swift
//  sample-chat-swift
//
//  Created by Injoit on 22.09.2022.
//  Copyright © 2022 quickBlox. All rights reserved.
//

import Foundation
import Quickblox

class ErrorInfo: NSObject {
    let info: String
    let statusCode: Int
    
    init(info: String, statusCode: Int) {
        self.info = info
        self.statusCode = statusCode
    }
}

@objc protocol AuthModuleDelegate: AnyObject {
    @objc optional func authModule(_ authModule: AuthModule, didSignUpUser user: QBUUser)
    @objc optional func authModule(_ authModule: AuthModule, didLoginUser user: QBUUser)
    @objc optional func authModule(_ authModule: AuthModule, didUpdateUpdateFullNameUser user: QBUUser)
    @objc optional func authModuleDidLogout(_ authModule: AuthModule)
    @objc optional func authModule(_ authModule: AuthModule, didReceivedError error: ErrorInfo)
}

class AuthModule: NSObject {
    //MARK: - Properties
    weak var delegate: AuthModuleDelegate?
    
    //MARK: - Public Methods
    func signUp(fullName: String, login: String) {
        let newUser = QBUUser()
        newUser.login = login
        newUser.fullName = fullName
        newUser.password = LoginConstant.defaultPassword
        QBRequest.signUp(newUser, successBlock: { [weak self] response, user in
            guard let self = self, let delegate = self.delegate else {
                return
            }
            delegate.authModule?(self, didSignUpUser: user)
            
        }, errorBlock: { [weak self] response in
            guard let self = self, let delegate = self.delegate else {
                return
            }
            if response.status == QBResponseStatusCode.validationFailed {
                // The user with existent login was created earlier
                delegate.authModule?(self, didSignUpUser: newUser)
                return
            }
            let error = ErrorInfo(info: response.localizedStatus, statusCode: response.status.rawValue)
            delegate.authModule?(self, didReceivedError: error)
        })
    }
    
    func login(fullName: String, login: String, password: String = LoginConstant.defaultPassword) {
        QBRequest.logIn(withUserLogin: login,
                        password: password,
                        successBlock: { [weak self] response, user in
            guard let self = self, let delegate = self.delegate else {
                return
            }
            delegate.authModule?(self, didLoginUser: user)

        }, errorBlock: { [weak self] response in
            guard let self = self, let delegate = self.delegate else {
                return
            }
            let error = ErrorInfo(info: response.localizedStatus, statusCode: response.status.rawValue)
            delegate.authModule?(self, didReceivedError: error)
        })
    }

    func updateFullName(fullName: String) {
        let updateUserParameter = QBUpdateUserParameters()
        updateUserParameter.fullName = fullName
        QBRequest.updateCurrentUser(updateUserParameter, successBlock: { [weak self] response, user in
            guard let self = self, let delegate = self.delegate else {
                return
            }
            delegate.authModule?(self, didUpdateUpdateFullNameUser: user)

        }, errorBlock: { [weak self] response in
            guard let self = self, let delegate = self.delegate else {
                return
            }
            let error = ErrorInfo(info: response.localizedStatus, statusCode: response.status.rawValue)
            delegate.authModule?(self, didReceivedError: error)
        })
    }

    func logout() {
        QBRequest.logOut(successBlock: { [weak self] response in
            guard let self = self, let delegate = self.delegate else {
                return
            }
            delegate.authModuleDidLogout?(self)
        }) {  [weak self] response in
            guard let self = self, let delegate = self.delegate else {
                return
            }
            let error = ErrorInfo(info: response.localizedStatus, statusCode: response.status.rawValue)
            delegate.authModule?(self, didReceivedError: error)
        }
    }
}
