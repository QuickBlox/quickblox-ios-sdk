//
//  Connect.swift
//  UIKitSample
//
//  Created by Injoit on 14.06.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import Combine
import Quickblox

enum ConnectState {
    case disconnected
    case waiting
    case connected
    case validationFailed
    case unAuthorized
}

enum AuthState {
    case authorized
    case authorization
    case unAuthorized
}

class Connect: ObservableObject {
    
    public let objectWillChange = PassthroughSubject<AuthState, Never>()
    
    @Published var authState: AuthState = .unAuthorized {
        didSet {
            objectWillChange.send(authState)
        }
    }
    
    @Published var isConnected: Bool = false
    
    init(state: ConnectState = .disconnected) {
        
//        Quickblox.initWithApplicationId(0,
//                                        authKey: "",
//                                        authSecret: "",
//                                        accountKey: "")
        
        QBSettings.carbonsEnabled = true
        QBSettings.autoReconnectEnabled = true
    }
    
    func login(withLogin login: String, password: String) {
        authState = .authorization
        QBRequest.logIn(withUserLogin: login.trimmingCharacters(in: .whitespacesAndNewlines),
                        password: password.trimmingCharacters(in: .whitespacesAndNewlines)) { [weak self] response, user in
            guard QBSession.current.sessionDetails?.token != nil else {
                print("Login Error: \(response)")
                DispatchQueue.main.async {
                    self?.authState = .unAuthorized
                }
                return
            }
            DispatchQueue.main.async {
                self?.authState = .authorized
            }
        } errorBlock: { [weak self] response in
            if response.status == QBResponseStatusCode.unAuthorized {
                // The user with existent login was created earlier
                self?.authState = .unAuthorized
                return
            }
            print("Login Error: \(response)")
            DispatchQueue.main.async {
                self?.authState = .unAuthorized
            }
            return
        }
    }
    
    func signUp(withLogin login: String, displayName: String, password: String) {
        authState = .authorization
        let newUser = QBUUser()
        newUser.login = login.trimmingCharacters(in: .whitespacesAndNewlines)
        newUser.fullName = displayName
        newUser.password = password.trimmingCharacters(in: .whitespacesAndNewlines)
        QBRequest.signUp(newUser, successBlock: { [weak self] response, user in
            self?.login(withLogin: login, password: password)
        }, errorBlock: { [weak self] response in
            if response.status == QBResponseStatusCode.validationFailed {
                // The user with existent login was created earlier
                self?.login(withLogin: login, password: password)
                return
            }
            print("Login Error: \(response)")
            DispatchQueue.main.async {
                self?.authState = .unAuthorized
            }
            return
        })
    }
    
    func disconnect() {
        QBChat.instance.disconnect() {_ in
            self.isConnected = false
            QBRequest.logOut { [weak self] response in
                DispatchQueue.main.async {
                    self?.authState = .unAuthorized
                }
                print("Success disconnect")
            }
        }
    }
}
