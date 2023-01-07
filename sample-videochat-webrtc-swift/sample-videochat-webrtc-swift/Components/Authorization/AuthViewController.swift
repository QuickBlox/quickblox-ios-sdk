//
//  AuthViewController.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 9/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit
import Quickblox

struct LoginConstant {
    static let notSatisfyingDeviceToken = "Invalid parameter not satisfying: deviceToken != nil"
    static let enterToVideochat = "Enter to Video Chat"
    static let fullNameDidChange = "Full Name Did Change"
    static let login = "Login"
    static let checkInternet = "No Internet Connection"
    static let checkInternetMessage = "Make sure your device is connected to the internet"
    static let enterUsername = "Enter your login and display name"
    static let defaultPassword = "quickblox"
    static let signUp = "Signg up ..."
    static let intoVideoChat = "Login into Video Chat ..."
    static let withCurrentUser = "Login with current user ..."
    static let chatServiceDomain = "com.q-municate.chatservice"
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
    case username = "^(?=.{3,20}$)(?!.*([\\s])\\1{1})[\\w\\s]+$"
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
    var onCompleteAuth: (() -> Void)?
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
    
    private let authModule = AuthModule()
    private var connection = ConnectionModule()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inputContainers = [loginInputContainer, usernameInputContainer]

        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        loginButton.topAnchor.constraint(equalTo: usernameInputContainer.bottomAnchor, constant: 20.0).isActive = true
        loginButton.widthAnchor.constraint(equalToConstant: 215.0).isActive = true
        loginButton.heightAnchor.constraint(equalToConstant: 44.0).isActive = true

        navigationItem.title = LoginConstant.enterToVideochat
        addInfoButton()
        
        authModule.delegate = self
        connection.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        defaultConfiguration()
    }
    
    //MARK - Setup
    private func defaultConfiguration() {
        infoText = LoginConstant.enterUsername
        loginButton.hideLoading()
        loginButton.setTitle(LoginConstant.login, for: .normal)
        loginButton.isEnabled = false
        inputEnabled = true
    }
    
    //MARK: - Actions
    @IBAction func didPressLoginButton(_ sender: LoadingButton) {
        guard let fullName = usernameInputContainer.inputTextfield.text,
              let login = loginInputContainer.inputTextfield.text,
              sender.isAnimating == false else {
            return
        }
        beginConnect()
        authModule.signUp(fullName: fullName, login: login)
    }
    
    //MARK: - Internal Methods
    private func beginConnect() {
        isEditing = false
        inputEnabled = false
        loginButton.showLoading()
    }
    
    // MARK: - Handle errors
    private func handleError(_ info: ErrorInfo) {
        infoText = info.description
        if info.statusCode == QBResponseStatusCode.unAuthorized.rawValue {
            Profile.clear()
            defaultConfiguration()
        } else if info.statusCode.isNetworkError == true  {
            infoText = ConnectionConstant.noInternetConnection
        }
        inputEnabled = true
        loginButton.hideLoading()
    }
}

// MARK: - AuthModuleDelegate
extension AuthViewController: AuthModuleDelegate {
    func authModule(_ authModule: AuthModule, didSignUpUser user: QBUUser) {
        guard let fullName = user.fullName, let login = user.login else { return }
        Profile.synchronize(withUser: user)
        authModule.login(fullName: fullName, login: login)
    }
    
    func authModule(_ authModule: AuthModule, didLoginUser user: QBUUser) {
        infoText = LoginConstant.intoVideoChat
        let fullName = Profile().fullName
        if user.fullName != fullName {
            infoText = LoginConstant.fullNameDidChange
            authModule.updateFullName(fullName: fullName)
            return
        }
        Profile.synchronize(withUser: user)
        connection.establish()
    }
    
    func authModule(_ authModule: AuthModule, didUpdateUpdateFullNameUser user: QBUUser) {
        Profile.synchronize(withUser: user)
        connection.establish()
    }
    
    func authModule(_ authModule: AuthModule, didReceivedError error: ErrorInfo) {
        handleError(error)
    }
}

// MARK: - ConnectionModuleDelegate
extension AuthViewController: ConnectionModuleDelegate {
    func connectionModuleDidConnect(_ connectionModule: ConnectionModule) {
        onCompleteAuth?()
    }
    
    func connectionModuleDidNotConnect(_ connectionModule: ConnectionModule, error: Error) {
        let error = ErrorInfo(info: error.localizedDescription, statusCode: error._code)
        handleError(error)
    }
}

//MARK: - InputContainerDelegate
extension AuthViewController: InputContainerDelegate {
    func inputContainer(_ container: InputContainer, didChangeValidState isValid: Bool) {
        if isValid == false {
            loginButton.isEnabled = false
            return
        }
        for inputContainer in inputContainers {
            if let text = inputContainer.inputTextfield.text, text.isEmpty
                || inputContainer.valid == false {
                loginButton.isEnabled = false
                return
            }
        }
        loginButton.isEnabled = true
    }
}
