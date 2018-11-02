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

struct LoginNameRegularExtention {
    static let user = "^[^_][\\w\\u00C0-\\u1FFF\\u2C00-\\uD7FF\\s]{2,19}$"
    static let chat = "^[a-zA-Z][a-zA-Z0-9]{2,14}$"
}

class LoginTableViewController: UITableViewController {
    
    //MARK: - IBOutlets
    @IBOutlet private weak var loginInfo: UILabel!
    @IBOutlet private weak var userNameDescriptionLabel: UILabel!
    @IBOutlet private weak var chatRoomDescritptionLabel: UILabel!
    @IBOutlet private weak var userNameTextField: UITextField!
    @IBOutlet private weak var chatRoomNameTextField: UITextField!
    @IBOutlet private weak var loginButton: LoadingButton!

    //MARK: - Properties
    private let core = Core.instance
    private var needReconnect = false
    
    private var inputEnabled = true {
        didSet {
            chatRoomNameTextField.isEnabled = inputEnabled
            userNameTextField.isEnabled = inputEnabled
        }
    }
    
    private var infoText = "" {
        didSet {
            loginInfo.text = infoText
            tableView.reloadData()
        }
    }
    
    //MARK: - Life Cicles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        core.addDelegate(self)
        
        tableView.estimatedRowHeight = 80.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.keyboardDismissMode = .onDrag
        tableView.delaysContentTouches = false
        navigationItem.title = LoginConstant.enterToChat
        
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
    
    //MARK - Setup
    private func defaultConfiguration() {
        loginButton.hideLoading()
        loginButton.setTitle(LoginConstant.login, for: .normal)
        loginButton.isEnabled = false
        userNameTextField.text = ""
        chatRoomNameTextField.text = ""
        inputEnabled = true
        
        // Reachability
        let updateLoginInfo: ((_ status: NetworkConnectionStatus) -> Void)? = { [weak self] status in
            let notConnection = status == NetworkConnectionStatus.notConnection
            let loginInfo = notConnection ? LoginConstant.checkInternet : LoginConstant.enterUsername
            self?.infoText = loginInfo
        }
        
        core.networkStatusBlock = { [weak self] status in
            if self?.needReconnect == true, status != NetworkConnectionStatus.notConnection {
                self?.needReconnect = false
                self?.login()
            } else {
                updateLoginInfo?(status)
            }
        }
        updateLoginInfo?(core.networkConnectionStatus())
    }
    
    //MARK: Actions
    @IBAction func didPressLoginButton(_ sender: LoadingButton) {
        login()
    }
    
    @IBAction func editingChanged(_ sender: UITextField) {
        validate(sender)
        loginButton.isEnabled = userNameIsValid() && chatRoomIsValid()
    }

    //MARK: - Overrides
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    //MARK: - Internal Methods
    private func login() {
        beginConnect()
        if core.currentUser != nil {
            core.loginWithCurrentUser()
        } else {
            core.signUp(withFullName: userNameTextField.text, roomName: chatRoomNameTextField.text)
        }
    }
    
    private func beginConnect() {
        isEditing = false
        inputEnabled = false
        loginButton.showLoading()
    }
    
    private func endConnectError() {
        inputEnabled = true
        loginButton.hideLoading()
    }
    
    private func validate(_ textField: UITextField?) {
        if textField == userNameTextField, userNameIsValid() == false {
            chatRoomDescritptionLabel.text = ""
            userNameDescriptionLabel.text = LoginConstant.shouldContainAlphanumeric
        } else if textField == chatRoomNameTextField, chatRoomIsValid() == false {
            userNameDescriptionLabel.text = ""
            chatRoomDescritptionLabel.text = LoginConstant.shouldContainAlphanumericWithoutSpace
        } else {
            userNameDescriptionLabel.text = ""
            chatRoomDescritptionLabel.text = userNameDescriptionLabel.text
        }
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    //MARK: - Validation helpers
    private func userNameIsValid() -> Bool {
        let characterSet = CharacterSet.whitespaces
        let trimmedText = userNameTextField.text?.trimmingCharacters(in: characterSet)
        let regularExtension = LoginNameRegularExtention.user
        let predicate = NSPredicate(format: "SELF MATCHES %@", regularExtension)
        let isValid = predicate.evaluate(with: trimmedText)
        return isValid
    }
    
    private func chatRoomIsValid() -> Bool {
        let characterSet = CharacterSet.whitespaces
        let trimmedText = chatRoomNameTextField.text?.trimmingCharacters(in: characterSet)
        let regularExtension = LoginNameRegularExtention.chat
        let predicate = NSPredicate(format: "SELF MATCHES %@", regularExtension)
        let isValid: Bool = predicate.evaluate(with: trimmedText)
        return isValid
    }
}

extension LoginTableViewController: CoreDelegate {
    //MARK: - CoreDelegate
    func coreDidLogin(_ core: Core) {
        performSegue(withIdentifier: LoginConstant.showUsers, sender: nil)
    }
    
    func coreDidLogout(_ core: Core) {
        defaultConfiguration()
    }
    
    func core(_ core: Core, loginStatus: String) {
        infoText = loginStatus
    }
    
    func core(_ core: Core, error: Error, domain: ErrorDomain) {
        var infoText = error.localizedDescription
        if error._code == NSURLErrorNotConnectedToInternet {
            infoText = LoginConstant.checkInternet
            needReconnect = true
        } else if core.networkConnectionStatus() != NetworkConnectionStatus.notConnection,
            (domain == ErrorDomain.signUp || domain == ErrorDomain.logIn) {
                login()
        } else {
            endConnectError()
        }
        self.infoText = infoText
    }
}

extension LoginTableViewController: UITextFieldDelegate {
    //MARK: - UITextFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        validate(textField)
    }
}
