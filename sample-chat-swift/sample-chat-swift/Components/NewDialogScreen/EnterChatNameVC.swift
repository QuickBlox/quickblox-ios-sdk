//
//  EnterChatNameVC.swift
//  sample-chat-swift
//
//  Created by Injoit on 10/9/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit

struct EnterChatNameConstant {
    static let nameHint = NSLocalizedString("Must be in a range from 3 to 20 characters.", comment: "")
    static let chatname = "^[^_]{3,19}$"
}

class EnterChatNameVC: UITableViewController {
    @IBOutlet weak var chatNameTextField: UITextField!
    @IBOutlet weak var chatNameLabel: UILabel!
    @IBOutlet weak var hintLabel: UILabel!

    var selectedUsers: [QBUUser] = []
    private let chatManager = ChatManager.instance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 102.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.keyboardDismissMode = .onDrag
        tableView.delaysContentTouches = false
        
        let backButtonItem = UIBarButtonItem(image: UIImage(named: "chevron"),
                                             style: .plain,
                                             target: self,
                                             action: #selector(didTapBack(_:)))
        navigationItem.leftBarButtonItem = backButtonItem
        backButtonItem.tintColor = .white
        
        let createButtonItem = UIBarButtonItem(title: "Finish",
                                               style: .plain,
                                               target: self,
                                               action: #selector(createChatButtonPressed(_:)))
        navigationItem.rightBarButtonItem = createButtonItem
        createButtonItem.tintColor = .white
        
        title = "New Chat"
        
        setupViews()
        
        //MARK: - Reachability
        let updateConnectionStatus: ((_ status: NetworkConnectionStatus) -> Void)? = { [weak self] status in
            let notConnection = status == .notConnection
            if notConnection == true {
                self?.showAlertView(LoginConstant.checkInternet, message: LoginConstant.checkInternetMessage)
            } else {
                ChatManager.instance.connect { (error) in
                    if let _ = error {
                        SVProgressHUD.showError(withStatus: "QBChat is not Connected")
                    }
                }
            }
        }
        Reachability.instance.networkStatusBlock = { status in
            updateConnectionStatus?(status)
        }
        updateConnectionStatus?(Reachability.instance.networkConnectionStatus())
    }
    
    
    //MARK - Setup
    private func setupViews() {
        chatNameTextField.becomeFirstResponder()
        hintLabel.text = ""
        chatNameTextField.setPadding(left: 12.0)
        chatNameTextField.addShadowToTextField(color: #colorLiteral(red: 0.8755381703, green: 0.9203008413, blue: 1, alpha: 1), cornerRadius: 4.0)
        chatNameTextField.text = ""
        validate(chatNameTextField)
    }
    
    //MARK - Setup keyboardWillHideNotification
    @objc func keyboardWillHide(notification: Notification) {
        if hintLabel.text?.isEmpty == true {
            hintLabel.text = ""
        }
        tableView.reloadData()
    }
    
    // MARK: - UITextField Helpers
    private func isValid(chatName: String?) -> Bool {
        let characterSet = CharacterSet.whitespaces
        let trimmedText = chatName?.trimmingCharacters(in: characterSet)
        let regularExtension = EnterChatNameConstant.chatname
        let predicate = NSPredicate(format: "SELF MATCHES %@", regularExtension)
        let isValid = predicate.evaluate(with: trimmedText)
        return isValid
    }
    
    private func validate(_ textField: UITextField?) {
        if textField == chatNameTextField, isValid(chatName: chatNameTextField.text) == false {
            navigationItem.rightBarButtonItem?.isEnabled = false
            hintLabel.text = EnterChatNameConstant.nameHint
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = true
            hintLabel.text = ""
        }
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    @IBAction func chatNameDidChanged(_ sender: UITextField) {
        validate(sender)
    }
    
    //MARK: - Actions
    @objc func didTapBack(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func createChatButtonPressed(_ sender: UIBarButtonItem) {
        if Reachability.instance.networkConnectionStatus() == .notConnection {
            showAlertView(LoginConstant.checkInternet, message: LoginConstant.checkInternetMessage)
            SVProgressHUD.dismiss()
            return
        }
        
        if selectedUsers.count > 1 {
            let chatName = chatNameTextField.text ?? "New Group Chat"
            
            SVProgressHUD.show()
            chatManager.storage.update(users: selectedUsers)
            
            chatManager.createGroupDialog(withName: chatName,
                                          photo: nil,
                                          occupants: selectedUsers) { [weak self] (response, dialog) -> Void in
                                            
                                            guard response?.error == nil,
                                                let dialog = dialog,
                                                let dialogOccupants = dialog.occupantIDs else {
                                                    SVProgressHUD.showError(withStatus: response?.error?.error?.localizedDescription)
                                                    return
                                            }
                                            if let message = self?.messageText(withChatName: chatName) {
                                                self?.chatManager.sendAddingMessage(message, action: .create, withUsers: dialogOccupants, to: dialog, completion: { (error) in
                                                    
                                                    SVProgressHUD.showSuccess(withStatus: "STR_DIALOG_CREATED".localized)
                                                    
                                                    self?.openNewDialog(dialog)
                                                })
                                                
                                            }
            }
        }
    }
    
    private func messageText(withChatName chatName: String) -> String {
        let actionMessage = "SA_STR_CREATE_NEW".localized
        guard let current = QBSession.current.currentUser,
            let fullName = current.fullName else {
                return ""
        }
        return "\(fullName) \(actionMessage) \"\(chatName)\""
    }
    
    private func openNewDialog(_ newDialog: QBChatDialog) {
        guard let navigationController = navigationController else {
            return
        }
        let controllers = navigationController.viewControllers
        var newStack = [UIViewController]()
        
        //change stack by replacing view controllers after ChatVC with ChatVC       
        controllers.forEach{
            newStack.append($0)
            if $0 is DialogsViewController {
                let storyboard = UIStoryboard(name: "Chat", bundle: nil)
                guard let chatController = storyboard.instantiateViewController(withIdentifier: "ChatViewController")
                    as? ChatViewController else {
                        return
                }
                chatController.dialogID = newDialog.id
                newStack.append(chatController)
                navigationController.setViewControllers(newStack, animated: true)
                return
            }
        }
        //else perform segue
        self.performSegue(withIdentifier: "SA_STR_SEGUE_GO_TO_CHAT".localized, sender: newDialog.id)
    }
    
    //MARK: - Overrides
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SA_STR_SEGUE_GO_TO_CHAT".localized {
            if let chatVC = segue.destination as? ChatViewController {
                chatVC.dialogID = sender as? String
            }
        }
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if hintLabel.text?.isEmpty == true, indexPath.row == 1 {
            return 6
        }
        
        return UITableView.automaticDimension
    }
}

//MARK: - UITextFieldDelegate
extension EnterChatNameVC: UITextFieldDelegate {
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
