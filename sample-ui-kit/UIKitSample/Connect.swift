//
//  Connect.swift
//  UIKitSample
//
//  Created by Injoit on 14.06.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import Quickblox

enum ConnectState {
    case disconnected
    case waiting
    case connected
    case validationFailed
    case unAuthorized
}

class Connect: ObservableObject {
    @Published var state: ConnectState = .waiting
    
    init(state: ConnectState = .disconnected) {
        self.state = state
        Quickblox.initWithApplicationId(0,
                                        authKey: "",
                                        authSecret: "",
                                        accountKey: "")
        
        QBSettings.carbonsEnabled = true
        QBSettings.autoReconnectEnabled = true
    }
    
    func login(withLogin login: String, password: String) {
        state = .waiting
        QBRequest.logIn(withUserLogin: login,
                        password: password) { [weak self] response, user in
            guard QBSession.current.sessionDetails?.token != nil else {
                print("Login Error: \(response)")
                self?.state = .disconnected
                return
            }
            self?.connect(withUserID: user.id)
        } errorBlock: { [weak self] response in
            if response.status == QBResponseStatusCode.unAuthorized {
                // The user with existent login was created earlier
                self?.state = .unAuthorized
                return
            }
            print("Login Error: \(response)")
            self?.state = .disconnected
            return
        }
    }
    
    func signUp(withLogin login: String, displayName: String, password: String) {
        state = .waiting
        let newUser = QBUUser()
        newUser.login = login
        newUser.fullName = displayName
        newUser.password = password
        QBRequest.signUp(newUser, successBlock: { [weak self] response, user in
            self?.login(withLogin: login, password: password)
        }, errorBlock: { [weak self] response in
            if response.status == QBResponseStatusCode.validationFailed {
                // The user with existent login was created earlier
                self?.login(withLogin: login, password: password)
                self?.state = .waiting
                return
            }
            print("Login Error: \(response)")
            self?.state = .disconnected
            return
        })
    }
    
    func connect(withUserID userId: UInt) {
        state = .waiting
        guard let token = QBSession.current.sessionDetails?.token else {
            self.state = .disconnected
            return
        }
        QBChat.instance.connect(withUserID: userId, password: token) { [weak self] _ in
            self?.state = .connected
            print("Success connect")
        }
    }
    
    func disconnect() {
        state = .waiting
        QBChat.instance.disconnect() {_ in
            QBRequest.logOut { [weak self] response in
                self?.state = .disconnected
                print("Success disconnect")
            }
        }
    }
}
