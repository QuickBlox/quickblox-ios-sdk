//
//  AuthViewController.swift
//  sample-push-notifications-swift
//
//  Created by Injoit on 9/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit
import Quickblox

struct LoginConstant {
    static let enterToPushes = "Enter to Pushes"
    static let fullNameDidChange = "Full Name Did Change"
    static let login = "Login"
    static let checkInternet = "No Internet Connection"
    static let enterUsername = "Enter your login and display name"
    static let defaultPassword = "quickblox"
    static let signUp = "Signg up ..."
    static let intoPushes = "Login into Pushes ..."
    static let withCurrentUser = "Login with current user ..."
}

enum Title: String {
    case login = "Login"
    case username = "Display Name"
}

enum Hint: String {
    case login = "Use your email or alphanumeric characters in a range from 3 to 50. First character must be a letter."
    case username = "Use alphanumeric characters and spaces in a range from 3 to 20. Cannot contain more than one space in a row."
}

enum Regex: String {
    case login = "^[a-zA-Z][a-zA-Z0-9]{2,49}$"
    case email = "^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,49}$"
    case username = "^(?=.{3,20}$)(?!.*([\\s])\\1{2})[\\w\\s]+$"
}

class AuthViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var loginInfoLabel: UILabel!
    @IBOutlet weak var loginButton: LoadingButton!
    
    lazy var loginInputContainer: InputContainer = {
        let loginInputContainer = InputContainer.loadNib()
        loginInputContainer.setup(title: .login,
                                  hint: .login,
                                  regexes: [.login, .email])
        loginInputContainer.delegate = self
        
        containerView.addSubview(loginInputContainer)
        loginInputContainer.translatesAutoresizingMaskIntoConstraints = false
        loginInputContainer.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        loginInputContainer.topAnchor.constraint(equalTo: loginInfoLabel.bottomAnchor, constant: 28.0).isActive = true
        loginInputContainer.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        
        return loginInputContainer
    }()
    
    lazy var usernameInputContainer: InputContainer = {
        let usernameInputContainer = InputContainer.loadNib()
        usernameInputContainer.setup(title: .username,
                                     hint: .username,
                                     regexes: [.username])
        usernameInputContainer.delegate = self
        
        containerView.addSubview(usernameInputContainer)
        usernameInputContainer.translatesAutoresizingMaskIntoConstraints = false
        usernameInputContainer.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        usernameInputContainer.topAnchor.constraint(equalTo: loginInputContainer.bottomAnchor).isActive = true
        usernameInputContainer.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        
        return usernameInputContainer
    }()
    
    //MARK: - Properties
    var inputContainers:[InputContainer] = []
    private var inputEnabled = true {
        didSet {
            inputContainers.forEach { (container) in
                container.inputTextfield.isEnabled = inputEnabled
            }
        }
    }
    
    private var infoText = "" {
        didSet {
            loginInfoLabel.text = infoText
        }
    }
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inputContainers = [loginInputContainer, usernameInputContainer]
        
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        loginButton.topAnchor.constraint(equalTo: usernameInputContainer.bottomAnchor, constant: 20.0).isActive = true
        loginButton.widthAnchor.constraint(equalToConstant: 215.0).isActive = true
        loginButton.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
        
        navigationItem.title = LoginConstant.enterToPushes
        addInfoButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        defaultConfiguration()
    }
    
    //MARK - Setup
    private func defaultConfiguration() {
        loginButton.hideLoading()
        loginButton.setTitle(LoginConstant.login, for: .normal)
        inputEnabled = true
    }
    
    //MARK: - Actions
    @IBAction func didPressLoginButton(_ sender: LoadingButton) {
        guard let fullName = usernameInputContainer.inputTextfield.text,
              let login = loginInputContainer.inputTextfield.text,
              sender.isAnimating == false else {
            return
        }
        signUp(fullName: fullName, login: login)
    }
    
    //MARK: - Internal Methods
    /**
     *  Signup and login
     */
    private func signUp(fullName: String, login: String) {
        self.infoText = LoginConstant.signUp
        beginConnect()
        let newUser = QBUUser()
        newUser.login = login
        newUser.fullName = fullName
        newUser.password = LoginConstant.defaultPassword
        QBRequest.signUp(newUser, successBlock: { [weak self] response, user in
            guard let self = self else {
                return
            }
            self.login(fullName: fullName, login: login)
            
        }, errorBlock: { [weak self] response in
            
            if response.status == QBResponseStatusCode.validationFailed {
                // The user with existent login was created earlier
                self?.login(fullName: fullName, login: login)
                return
            }
            if let error = response.error?.error {
                self?.handleError(error)
            }
        })
    }
    
    /**
     *  login
     */
    private func login(fullName: String, login: String, password: String = LoginConstant.defaultPassword) {
        self.infoText = LoginConstant.intoPushes
        beginConnect()
        QBRequest.logIn(withUserLogin: login,
                        password: password,
                        successBlock: { [weak self] response, user in
                            guard let self = self else {
                                return
                            }
                            
                            user.password = password
                            Profile.synchronize(withUser: user)
                            
                            if user.fullName != fullName {
                                self.updateFullName(fullName: fullName)
                            } else {
                                AppDelegate.shared.rootViewController.showPushScreen()
                            }
                        }, errorBlock: { [weak self] response in
                            if let error = response.error?.error {
                                self?.handleError(error)
                            }
                        })
    }
    
    /**
     *  Update User Full Name
     */
    private func updateFullName(fullName: String) {
        let profile = Profile()
        if profile.isFull != true{
            return
        }
        self.infoText = LoginConstant.fullNameDidChange
        let updateUserParameter = QBUpdateUserParameters()
        updateUserParameter.fullName = fullName
        QBRequest.updateCurrentUser(updateUserParameter, successBlock: { response, user in
            
            user.password = profile.password
            Profile.synchronize(withUser: user)
            AppDelegate.shared.rootViewController.showPushScreen()
        }, errorBlock: { [weak self] response in
            if let error = response.error?.error {
                self?.handleError(error)
            }
        })
    }
    
    private func beginConnect() {
        isEditing = false
        inputEnabled = false
        loginButton.showLoading()
    }
    
    // MARK: - Handle errors
    private func handleError(_ error: Error) {
        var infoText = error.localizedDescription
        if error._code == QBResponseStatusCode.unAuthorized.rawValue {
            Profile.clear()
            self.defaultConfiguration()
        } else if error._code == NSURLErrorNotConnectedToInternet {
            infoText = LoginConstant.checkInternet
        }
        inputEnabled = true
        loginButton.hideLoading()
        self.infoText = infoText
    }
}

extension AuthViewController: InputContainerDelegate {
    func inputContainer(_ container: InputContainer, didChangeValidState isValid: Bool) {
        if isValid == false {
            loginButton.isEnabled = false
            return
        }
        for container in inputContainers {
            if container.valid == false {
                loginButton.isEnabled = false
                return
            }
        }
        loginButton.isEnabled = true
    }
}
