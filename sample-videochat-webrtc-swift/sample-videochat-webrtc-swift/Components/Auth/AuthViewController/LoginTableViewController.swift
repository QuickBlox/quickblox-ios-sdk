//
//  LoginTableViewController.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 12/7/18.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit
import Quickblox

struct LoginConstant {
    static let notSatisfyingDeviceToken = "Invalid parameter not satisfying: deviceToken != nil"
    static let enterToChat = NSLocalizedString("Enter to Video Chat", comment: "")
    static let fullNameDidChange = NSLocalizedString("Full Name Did Change", comment: "")
    static let login = NSLocalizedString("Login", comment: "")
    static let checkInternet = NSLocalizedString("Please check your Internet connection", comment: "")
    static let enterUsername = NSLocalizedString("Please enter your login and Display Name.", comment: "")
    static let shouldContainAlphanumeric = NSLocalizedString("Field should contain alphanumeric characters only in a range 3 to 20. The first character must be a letter.", comment: "")
    static let shouldContainAlphanumericWithoutSpace = NSLocalizedString("Field should contain alphanumeric characters only in a range 8 to 15, without space. The first character must be a letter.", comment: "")
    static let showUsers = "ShowUsersViewController"
    static let defaultPassword = "quickblox"
    static let infoSegue = "ShowInfoScreen"
    static let chatServiceDomain = "com.q-municate.chatservice"
    static let errorDomaimCode = -1000
}

enum ErrorDomain: UInt {
    case signUp
    case logIn
    case logOut
    case chat
}

struct LoginStatusConstant {
    static let signUp = "Signg up ..."
    static let intoChat = "Login in progress ..."
    static let withCurrentUser = "Login with current user ..."
}

struct LoginNameRegularExtention {
    static let user = "^[^_][\\w\\u00C0-\\u1FFF\\u2C00-\\uD7FF\\s]{2,19}$"
    static let passord = "^[a-zA-Z][a-zA-Z0-9]{7,14}$"
}

class LoginTableViewController: UITableViewController {
    
    //MARK: - IBOutlets
    @IBOutlet private weak var loginInfo: UILabel!
    @IBOutlet private weak var userNameDescriptionLabel: UILabel!
    @IBOutlet private weak var loginDescritptionLabel: UILabel!
    @IBOutlet private weak var userNameTextField: UITextField!
    @IBOutlet private weak var loginTextField: UITextField!
    @IBOutlet private weak var loginButton: LoadingButton!
    
    //MARK: - Properties
    private var inputEnabled = true {
        didSet {
            loginTextField.isEnabled = inputEnabled
            userNameTextField.isEnabled = inputEnabled
        }
    }
    
    private var infoText = "" {
        didSet {
            loginInfo.text = infoText
            tableView.reloadData()
        }
    }
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 80.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.keyboardDismissMode = .onDrag
        tableView.delaysContentTouches = false
        navigationItem.title = LoginConstant.enterToChat
        showInfoButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        defaultConfiguration()
        let profile = Profile()
        if profile.isFull == true {
            userNameTextField.text = profile.fullName
            loginTextField.text = profile.login
            login(fullName: profile.fullName, login: profile.login)
        }
    }
    
    //MARK - Setup
    private func defaultConfiguration() {
        loginButton.hideLoading()
        loginButton.setTitle(LoginConstant.login, for: .normal)
        loginButton.isEnabled = false
        userNameTextField.text = ""
        loginTextField.text = ""
        inputEnabled = true
        
        //MARK: - Reachability
        let updateLoginInfo: ((_ status: NetworkConnectionStatus) -> Void)? = { [weak self] status in
            let notConnection = status == .notConnection
            let loginInfo = notConnection ? LoginConstant.checkInternet : LoginConstant.enterUsername
            self?.infoText = loginInfo
        }
        
        Reachability.instance.networkStatusBlock = { status in
            updateLoginInfo?(status)
        }
        updateLoginInfo?(Reachability.instance.networkConnectionStatus())
    }
    
    //MARK: - Actions
    @IBAction func didPressLoginButton(_ sender: LoadingButton) {
        if let fullName = userNameTextField.text,
            let login = loginTextField.text {
            if sender.isAnimating == false {
                signUp(fullName: fullName, login: login)
            }
        }
    }
    
    @IBAction func editingChanged(_ sender: UITextField) {
        validate(sender)
        loginButton.isEnabled = isValid(userName: userNameTextField.text) && isValid(login: loginTextField.text)
    }
    
    @objc func didTapInfoScreen(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: LoginConstant.infoSegue, sender: sender)
    }
    
    //MARK: - Overrides
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    //MARK: - Internal Methods
    /**
     *  Signup and login
     */
    private func signUp(fullName: String, login: String) {
        beginConnect()
        let newUser = QBUUser()
        newUser.login = login
        newUser.fullName = fullName
        newUser.password = LoginConstant.defaultPassword
        infoText = LoginStatusConstant.signUp
        QBRequest.signUp(newUser, successBlock: { [weak self] response, user in
            
            self?.login(fullName: fullName, login: login)
            
            }, errorBlock: { [weak self] response in
                
                if response.status == QBResponseStatusCode.validationFailed {
                    // The user with existent login was created earlier
                    self?.login(fullName: fullName, login: login)
                    return
                }
                self?.handleError(response.error?.error, domain: ErrorDomain.signUp)
        })
    }
    
    /**
     *  login
     */
    private func login(fullName: String, login: String, password: String = LoginConstant.defaultPassword) {
        beginConnect()
        
        QBRequest.logIn(withUserLogin: login,
                        password: password,
                        successBlock: { [weak self] response, user in

                            user.password = password
                            user.updatedAt = Date()
                            Profile.synchronize(user)
                            
                            if user.fullName != fullName {
                                self?.updateFullName(fullName: fullName, login: login)
                            } else {
                                self?.connectToChat(user: user)
                            }
                            
            }, errorBlock: { [weak self] response in
                self?.handleError(response.error?.error, domain: ErrorDomain.logIn)
                if response.status == QBResponseStatusCode.unAuthorized {
                    // Clean profile
                    Profile.clearProfile()
                    self?.defaultConfiguration()
                }
        })
    }
    
    /**
     *  Update User Full Name
     */
    private func updateFullName(fullName: String, login: String) {
        let updateUserParameter = QBUpdateUserParameters()
        updateUserParameter.fullName = fullName
        QBRequest.updateCurrentUser(updateUserParameter, successBlock: {  [weak self] response, user in

            user.updatedAt = Date()
            
            self?.infoText = LoginConstant.fullNameDidChange
            Profile.update(user)
            self?.connectToChat(user: user)
            
            }, errorBlock: { [weak self] response in
                self?.handleError(response.error?.error, domain: ErrorDomain.signUp)
        })
    }
    
    /**
     *  connectToChat
     */
    private func connectToChat(user: QBUUser) {
        infoText = LoginStatusConstant.intoChat
        QBChat.instance.connect(withUserID: user.id,
                                password: LoginConstant.defaultPassword,
                                completion: { [weak self] error in
                                    if let error = error {
                                        if error._code == QBResponseStatusCode.unAuthorized.rawValue {
                                            // Clean profile
                                            Profile.clearProfile()
                                            self?.defaultConfiguration()
                                        } else {
                                            self?.handleError(error, domain: ErrorDomain.logIn)
                                        }
                                    } else {
                                        //did Login action
                                        self?.performSegue(withIdentifier: LoginConstant.showUsers, sender: nil)
                                    }
        })
    }
    
    private func beginConnect() {
        isEditing = false
        inputEnabled = false
        loginButton.showLoading()
    }
    
    private func connectUser(_ user: QBUUser) {
        Profile.synchronize(user)
        connectToChat(user: user)
    }
    
    private func validate(_ textField: UITextField?) {
        if textField == userNameTextField, isValid(userName: userNameTextField.text) == false {
            loginDescritptionLabel.text = ""
            userNameDescriptionLabel.text = LoginConstant.shouldContainAlphanumeric
        } else if textField == loginTextField, isValid(login: loginTextField.text) == false {
            userNameDescriptionLabel.text = ""
            loginDescritptionLabel.text = LoginConstant.shouldContainAlphanumericWithoutSpace
        } else {
            userNameDescriptionLabel.text = ""
            loginDescritptionLabel.text = userNameDescriptionLabel.text
        }
        tableView.beginUpdates()
        tableView.endUpdates()
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
        inputEnabled = true
        loginButton.hideLoading()
        validate(userNameTextField)
        validate(loginTextField)
        loginButton.isEnabled = isValid(userName: userNameTextField.text) && isValid(login: loginTextField.text)
        self.infoText = infoText
    }
    
    //MARK: - Validation helpers
    private func isValid(userName: String?) -> Bool {
        let characterSet = CharacterSet.whitespaces
        let trimmedText = userName?.trimmingCharacters(in: characterSet)
        let regularExtension = LoginNameRegularExtention.user
        let predicate = NSPredicate(format: "SELF MATCHES %@", regularExtension)
        let isValid = predicate.evaluate(with: trimmedText)
        return isValid
    }
    
    private func isValid(login: String?) -> Bool {
        let characterSet = CharacterSet.whitespaces
        let trimmedText = login?.trimmingCharacters(in: characterSet)
        let regularExtension = LoginNameRegularExtention.passord
        let predicate = NSPredicate(format: "SELF MATCHES %@", regularExtension)
        let isValid: Bool = predicate.evaluate(with: trimmedText)
        return isValid
    }
}

//MARK: - UITextFieldDelegate
extension LoginTableViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        validate(textField)
    }
}
