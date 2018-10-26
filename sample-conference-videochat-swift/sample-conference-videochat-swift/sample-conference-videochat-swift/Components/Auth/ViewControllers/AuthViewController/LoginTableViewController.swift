//
//  LoginTableViewController.swift
//  sample-conference-videochat-swift
//
//  Created by Vladimir Nybozhinsky on 04.10.2018.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit

struct LoginConstant {
    static let enterToChat = NSLocalizedString("Enter to chat", comment: "")
    static let login = NSLocalizedString("Login", comment: "")
    static let checkInternet = NSLocalizedString("Please check your Internet connection", comment: "")
    static let enterUsername = NSLocalizedString("Please enter your username and group name. You can join existent group.", comment: "")
    
    static let shouldContainAlphanumeric = NSLocalizedString("Field should contain alphanumeric characters only in a range 3 to 20. The first character must be a letter.", comment: "")
    static let shouldContainAlphanumericWithoutSpace = NSLocalizedString("Field should contain alphanumeric characters only in a range 3 to 15, without space. The first character must be a letter.", comment: "")
    
    static let showUsers = "ShowUsersViewController"
}

class LoginTableViewController: UITableViewController, UITextFieldDelegate, QBCoreDelegate {
    
// MARK: IBOutlets
    @IBOutlet private weak var loginInfo: UILabel!
    @IBOutlet private weak var userNameDescriptionLabel: UILabel!
    @IBOutlet private weak var chatRoomDescritptionLabel: UILabel!
    @IBOutlet private weak var userNameTextField: UITextField!
    @IBOutlet private weak var chatRoomNameTextField: UITextField!
    @IBOutlet private weak var loginButton: QBLoadingButton!

// MARK: Variables
    let core = QBCore.instance
    var needReconnect = false
    
// MARK: Life Cicles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        core.addDelegate(self)
        
        self.tableView.estimatedRowHeight = 80
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.keyboardDismissMode = .onDrag
        self.tableView.delaysContentTouches = false
        self.navigationItem.title = LoginConstant.enterToChat
        
        self.defaultConfiguration()
        
        if let currentUser = core.currentUser {
            self.userNameTextField.text = currentUser.fullName;
            self.chatRoomNameTextField.text = currentUser.tags?.first
            self.login()
        }
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
    
    private func defaultConfiguration() {
        loginButton.hideLoading()
        loginButton.setTitle(LoginConstant.login, for: .normal)
        loginButton.isEnabled = false
        userNameTextField.text = ""
        chatRoomNameTextField.text = ""
        
        setInputEnabled(enabled: true)
        
        // Reachability
        let updateLoginInfo: ((_ status: NetworkConnectionStatus) -> Void)? = { status in
            let loginInfo = (status == NetworkConnectionStatus.notConnection) ?
                LoginConstant.checkInternet : LoginConstant.enterUsername
            self.setLoginInfoText(loginInfo)
        }
        
        core.networkStatusBlock = { status in
            if self.needReconnect == true && status != NetworkConnectionStatus.notConnection {
                self.needReconnect = false
                self.login()
            } else {
                updateLoginInfo?(status)
            }
        }
        updateLoginInfo?(core.networkConnectionStatus())
    }
    
// MARK: - QBCoreDelegate metods
    func coreDidLogin(_ core: QBCore) {
        performSegue(withIdentifier: LoginConstant.showUsers, sender: nil)
    }
    
    func coreDidLogout(_ core: QBCore) {
        defaultConfiguration()
    }
    
    func core(_ core: QBCore, _ loginStatus: String) {
        setLoginInfoText(loginStatus)
    }
    
    func core(_ core: QBCore, _ error: Error, _ domain: ErrorDomain) {
        var infoText = error.localizedDescription
        if error._code == NSURLErrorNotConnectedToInternet {
            infoText = LoginConstant.checkInternet
            needReconnect = true
        } else if core.networkConnectionStatus() != NetworkConnectionStatus.notConnection {
            if domain == ErrorDomain.ErrorDomainSignUp || domain == ErrorDomain.ErrorDomainLogIn {
                login()
            }
        }
        setLoginInfoText(infoText)
    }
    
// MARK: - Disable / Enable inputs
    private func setInputEnabled(enabled: Bool) {
            chatRoomNameTextField.isEnabled = enabled
            userNameTextField.isEnabled = enabled
    }
    
// MARK: UIControl Actions
    @IBAction func didPressLoginButton(_ sender: QBLoadingButton) {
        login()
    }

// MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
// MARK: - UITextFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        validate(textField)
    }
    
    @IBAction func editingChanged(_ sender: UITextField) {
        validate(sender)
        loginButton.isEnabled = userNameIsValid() && chatRoomIsValid()
    }
    
    func validate(_ textField: UITextField?) {
        if textField == userNameTextField && !userNameIsValid() {
            chatRoomDescritptionLabel.text = ""
            userNameDescriptionLabel.text = LoginConstant.shouldContainAlphanumeric
        } else if textField == chatRoomNameTextField && !chatRoomIsValid() {
            userNameDescriptionLabel.text = ""
            chatRoomDescritptionLabel.text = LoginConstant.shouldContainAlphanumericWithoutSpace
        } else {
            userNameDescriptionLabel.text = ""
            chatRoomDescritptionLabel.text = userNameDescriptionLabel.text
        }
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func setLoginInfoText(_ text: String?) {
        if text != loginInfo.text {
            loginInfo.text = text
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
    
    // MARK: - Login
    func login() {
        isEditing = false
        beginConnect()
        if core.currentUser != nil {
            core.loginWithCurrentUser()
        } else {
            core.signUp(withFullName: userNameTextField.text, roomName: chatRoomNameTextField.text)
        }
    }
    
    func beginConnect() {
        setInputEnabled(enabled: false)
        loginButton.showLoading()
    }
    
    func endConnectError() throws {
        setInputEnabled(enabled: true)
        loginButton.hideLoading()
    }
    
// MARK: - Validation helpers
    func userNameIsValid() -> Bool {
        let characterSet = CharacterSet.whitespaces
        let userName = userNameTextField.text?.trimmingCharacters(in: characterSet)
        let userNameRegex = "^[^_][\\w\\u00C0-\\u1FFF\\u2C00-\\uD7FF\\s]{2,19}$"
        let userNamePredicate = NSPredicate(format: "SELF MATCHES %@", userNameRegex)
        let userNameIsValid: Bool = userNamePredicate.evaluate(with: userName)
        return userNameIsValid
    }
    
    func chatRoomIsValid() -> Bool {
        let characterSet = CharacterSet.whitespaces
        let tag = chatRoomNameTextField.text?.trimmingCharacters(in: characterSet)
        let tagRegex = "^[a-zA-Z][a-zA-Z0-9]{2,14}$"
        let tagPredicate = NSPredicate(format: "SELF MATCHES %@", tagRegex)
        let tagIsValid: Bool = tagPredicate.evaluate(with: tag)
        return tagIsValid
    }
}
