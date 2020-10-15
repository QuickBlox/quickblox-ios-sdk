//
//  AuthViewController.swift
//  sample-chat-swift
//
//  Created by Injoit on 9/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit
import Quickblox

struct LoginConstant {
    static let notSatisfyingDeviceToken = "Invalid parameter not satisfying: deviceToken != nil"
    static let enterToChat = NSLocalizedString("Enter to chat", comment: "")
    static let fullNameDidChange = NSLocalizedString("Full Name Did Change", comment: "")
    static let login = NSLocalizedString("Login", comment: "")
    static let checkInternet = NSLocalizedString("No Internet Connection", comment: "")
    static let checkInternetMessage = NSLocalizedString("Make sure your device is connected to the internet", comment: "")
    static let enterUsername = NSLocalizedString("Enter your login and display name", comment: "")
    static let loginHint = NSLocalizedString("Use your email or alphanumeric characters in a range from 3 to 50. First character must be a letter.", comment: "")
    static let usernameHint = NSLocalizedString("Use alphanumeric characters and spaces in a range from 3 to 20. Cannot contain more than one space in a row.", comment: "")
    static let defaultPassword = "quickblox"
    static let infoSegue = "ShowInfoScreen"
    static let showDialogs = "ShowDialogsViewController"
}

enum ErrorDomain: UInt {
    case signUp
    case logIn
    case logOut
    case chat
}

struct LoginStatusConstant {
    static let signUp = "Signg up ..."
    static let intoChat = "Login into chat ..."
    static let withCurrentUser = "Login with current user ..."
}

struct LoginNameRegularExtention {
    static let username = "^[a-zA-Z][a-zA-Z 0-9]{2,19}$"
    static let usernameChanged = "^[a-zA-Z][a-zA-Z 0-9]{2,19}$"
    static let login = "^[a-zA-Z][a-zA-Z0-9]{2,49}$"
    static let loginEmail = "^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,49}$"
    static let loginChanged = "^[a-zA-Z][a-zA-Z0-9]{2,49}$"
    static let loginEmailChanged = "^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,49}$"
}

class AuthViewController: UITableViewController {
    
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
    
    private var inputedLogin: String?
    private var inputedUsername: String?
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = 80.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.keyboardDismissMode = .onDrag
        tableView.delaysContentTouches = false
        navigationItem.title = LoginConstant.enterToChat
        addInfoButton()
        setupViews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        defaultConfiguration()
        
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK - keyboardWillHideNotification
    @objc func keyboardWillHide(notification: Notification) {
        if userNameTextField.text?.isEmpty == true {
            userNameDescriptionLabel.text = ""
        }
        if loginTextField.text?.isEmpty == true {
            loginDescritptionLabel.text = ""
        }
        tableView.reloadData()
    }
    
    //MARK - Setup
    private func setupViews() {
        loginTextField.setPadding(left: 12.0)
        loginTextField.addShadowToTextField(color: #colorLiteral(red: 0.8755381703, green: 0.9203008413, blue: 1, alpha: 1), cornerRadius: 4.0)
        userNameTextField.setPadding(left: 12.0)
        userNameTextField.addShadowToTextField(color: #colorLiteral(red: 0.8755381703, green: 0.9203008413, blue: 1, alpha: 1), cornerRadius: 4.0)
    }
    
    private func defaultConfiguration() {
        loginButton.hideLoading()
        loginButton.setTitle(LoginConstant.login, for: .normal)
        userNameTextField.text = inputedUsername ?? ""
        loginTextField.text = inputedLogin ?? ""
        loginButton.isEnabled = isValid(userName: userNameTextField.text) && isValid(login: loginTextField.text)
        inputEnabled = true
        loginDescritptionLabel.text = ""
        userNameDescriptionLabel.text = ""
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
    
    @IBAction func editingDidBegin(_ sender: UITextField) {
        sender.addShadowToTextField(color: #colorLiteral(red: 0.6745098039, green: 0.7490196078, blue: 0.8862745098, alpha: 1), cornerRadius: 4.0)
    }
    
    @IBAction func editingDidEnd(_ sender: UITextField) {
        sender.addShadowToTextField(color: #colorLiteral(red: 0.8745098039, green: 0.9215686275, blue: 1, alpha: 1), cornerRadius: 4.0)
    }
    
    @IBAction func editingChanged(_ sender: UITextField) {
        
        guard let inputText = sender.text else {
            return
        }
        
        if userNameTextField.isFirstResponder {
            if inputText.count > 1, inputText.last?.isWhitespace == true {
                if inputText.hasSuffix("  ") {
                    sender.text = inputedUsername
                }
            }
        }

        validate(sender)
        loginButton.isEnabled = isValid(userName: userNameTextField.text) && isValid(login: loginTextField.text)
        if let fullName = userNameTextField.text {
            inputedUsername = fullName
        }
        if  let login = loginTextField.text {
            inputedLogin = login
        }
    }
    
    @objc func didTapInfoScreen(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: LoginConstant.infoSegue, sender: sender)
    }
    
    //MARK: - Overrides
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if loginDescritptionLabel.text?.isEmpty == true, indexPath.row == 2 ||
            userNameDescriptionLabel.text?.isEmpty == true, indexPath.row == 4 {
            return 6
        }
        
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
                            guard let self = self else {
                                return
                            }
                            
                            user.password = password
                            Profile.synchronize(user)
                            
                            if user.fullName != fullName {
                                self.updateFullName(fullName: fullName, login: login)
                            } else {
                                self.connectToChat(user: user)
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
        QBRequest.updateCurrentUser(updateUserParameter, successBlock: { [weak self] response, user in
            guard let self = self else {
                return
            }
            self.infoText = LoginConstant.fullNameDidChange
            Profile.update(user)
            self.connectToChat(user: user)
            
            }, errorBlock: { [weak self] response in
                self?.handleError(response.error?.error, domain: ErrorDomain.signUp)
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
                self.inputedUsername = nil
                self.inputedLogin = nil
            }
        } else {
            QBChat.instance.connect(withUserID: user.id,
                                    password: LoginConstant.defaultPassword,
                                    completion: { [weak self] error in
                                        guard let self = self else { return }
                                        if let error = error {
                                            if error._code == QBResponseStatusCode.unAuthorized.rawValue {
                                                // Clean profile
                                                Profile.clearProfile()
                                                self.defaultConfiguration()
                                            } else {
                                                self.showAlertView(LoginConstant.checkInternet, message: LoginConstant.checkInternetMessage)
                                                self.handleError(error, domain: ErrorDomain.logIn)
                                            }
                                        } else {
                                            //did Login action
                                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
                                                AppDelegate.shared.rootViewController.goToDialogsScreen()
                                                self.inputedUsername = nil
                                                self.inputedLogin = nil
                                            }
                                        }
                                    })
            
        }
    }
    
    private func beginConnect() {
        isEditing = false
        inputEnabled = false
        loginButton.showLoading()
    }
    
    private func validate(_ textField: UITextField?) {
        if textField == loginTextField {
            if isValidChanged(login: loginTextField.text) == false {
                loginDescritptionLabel.text = LoginConstant.loginHint
            } else {
                loginDescritptionLabel.text = ""
            }
            
            if userNameTextField.text?.isEmpty == true {
                userNameDescriptionLabel.text = ""
            } else if isValidChanged(userName: userNameTextField.text) == false {
                userNameDescriptionLabel.text = LoginConstant.usernameHint
            } else {
                userNameDescriptionLabel.text = ""
            }
        }
        if textField == userNameTextField {
            if isValidChanged(userName: userNameTextField.text) == false {
                userNameDescriptionLabel.text = LoginConstant.usernameHint
            } else {
                userNameDescriptionLabel.text = ""
            }
            
            if loginTextField.text?.isEmpty == true {
                loginDescritptionLabel.text = ""
            } else if isValidChanged(login: loginTextField.text) == false {
                loginDescritptionLabel.text = LoginConstant.loginHint
            } else {
                loginDescritptionLabel.text = ""
            }
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
        let regularExtension = LoginNameRegularExtention.username
        let predicate = NSPredicate(format: "SELF MATCHES %@", regularExtension)
        let isValid: Bool = predicate.evaluate(with: userName)
        return isValid == true
    }
    
    private func isValidChanged(userName: String?) -> Bool {
        let regularExtension = LoginNameRegularExtention.usernameChanged
        let predicate = NSPredicate(format: "SELF MATCHES %@", regularExtension)
        let isValid: Bool = predicate.evaluate(with: userName)
        return isValid == true
    }

    private func isValid(login: String?) -> Bool {
        let regularExtension = LoginNameRegularExtention.login
        let regularExtensionEmail = LoginNameRegularExtention.loginEmail
        let predicate = NSPredicate(format: "SELF MATCHES %@", regularExtension)
        let predicateEmail = NSPredicate(format: "SELF MATCHES %@", regularExtensionEmail)
        let isValid: Bool = predicate.evaluate(with: login)
        let isValidEmail: Bool = predicateEmail.evaluate(with: login)
        return isValid == true || isValidEmail == true
    }
    
    private func isValidChanged(login: String?) -> Bool {
        let regularExtension = LoginNameRegularExtention.loginChanged
        let regularExtensionEmail = LoginNameRegularExtention.loginEmailChanged
        let predicate = NSPredicate(format: "SELF MATCHES %@", regularExtension)
        let predicateEmail = NSPredicate(format: "SELF MATCHES %@", regularExtensionEmail)
        let isValid: Bool = predicate.evaluate(with: login)
        let isValidEmail: Bool = predicateEmail.evaluate(with: login)
        return isValid == true || isValidEmail == true
    }
}

//MARK: - UITextFieldDelegate
extension AuthViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        validate(textField)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
        return true
    }
}
