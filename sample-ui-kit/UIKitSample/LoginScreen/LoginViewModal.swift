//
//  LoginViewModal.swift
//  UIKitSample
//
//  Created by Injoit on 14.06.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import Combine

final class LoginViewModal: ObservableObject {
    
    enum Regex: String {
        case login = "^[a-zA-Z][a-zA-Z0-9]{2,49}$"
        case email = "^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,49}$"
        case displayName = "^(?=.{3,20}$)(?!.*([\\s])\\1{2})[\\w\\s]+$"
        case password = "^[a-zA-Z][a-zA-Z0-9]{7,11}$"
    }
    
    @Published var login = ""
    @Published var isValidLogin = false
    
    @Published var displayName = ""
    @Published var isValidDisplayName = false
    
    @Published var password = ""
    @Published var isValidPassword = false
    
    @Published var isLoginValidForm = false
    @Published var isSignUpValidForm = false
    
    @Published var isSignUped = true
    
    private var publishers = Set<AnyCancellable>()
    
    private var loginRegexes = [Regex.login, Regex.email]
    private var displayNameRegexes = [Regex.displayName]
    private var passwordRegexes = [Regex.password]
    
    init() {
        isLoginFormValidPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.isLoginValidForm, on: self)
            .store(in: &publishers)
        
        isSignUpFormValidPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.isSignUpValidForm, on: self)
            .store(in: &publishers)
    }
}

// MARK: - Validation
private extension LoginViewModal {
    
    var isLoginValidPublisher: AnyPublisher<Bool, Never> {
        $login
            .map { login in
                self.isValidLogin = login.isValid(regexes: self.loginRegexes.compactMap { "\($0.rawValue)" })
                return self.isValidLogin
            }
            .eraseToAnyPublisher()
    }
    
    var isDisplayNameValidPublisher: AnyPublisher<Bool, Never> {
        $displayName
            .map { displayName in
                self.isValidDisplayName = displayName.isValid(regexes: self.displayNameRegexes.compactMap { "\($0.rawValue)" })
                return self.isValidDisplayName
            }
            .eraseToAnyPublisher()
    }
    
    var isPasswordValidPublisher: AnyPublisher<Bool, Never> {
        $password
            .map { password in
                self.isValidPassword = password.isValid(regexes: self.passwordRegexes.compactMap { "\($0.rawValue)" })
                return self.isValidPassword
            }
            .eraseToAnyPublisher()
    }
    
    var isSignUpFormValidPublisher: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest3(
            isLoginValidPublisher,
            isDisplayNameValidPublisher,
            isPasswordValidPublisher)
            .map { isLoginValid, isDisplayNameValid, isPasswordValid in
                return isLoginValid && isDisplayNameValid && isPasswordValid
            }
            .eraseToAnyPublisher()
    }
    
    var isLoginFormValidPublisher: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest(
            isLoginValidPublisher,
            isPasswordValidPublisher)
            .map { isLoginValid, isPasswordValid in
                return isLoginValid && isPasswordValid
            }
            .eraseToAnyPublisher()
    }
}

extension String {
    func isValid(regexes: [String]) -> Bool {
        for regex in regexes {
            let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
            if predicate.evaluate(with: self) == true {
                return true
            }
        }
        return false
    }
}
