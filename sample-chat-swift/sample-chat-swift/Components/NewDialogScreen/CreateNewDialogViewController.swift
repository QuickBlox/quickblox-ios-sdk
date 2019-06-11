//
//  CreateNewDialogViewController.swift
//  sample-chat-swift
//
//  Created by Injoit on 1/28/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import Foundation

enum DialogAction {
    case create
    case add
}

struct ChatNameRegularExtention {
    static let chatname = "^[^_][\\w\\u00C0-\\u1FFF\\u2C00-\\uD7FF\\s]{2,19}$"
}

class CreateNewDialogViewController: UITableViewController {
    
    //MARK: - Properties
    private var users : [QBUUser] = []
    private let chatManager = ChatManager.instance
    private var chatNameTextFeld: UITextField!
    private var successAction: UIAlertAction!
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Fetching users from cache.
        chatManager.delegate = self
        let  profile = Profile()
        if profile.isFull == true {
            navigationItem.title = profile.fullName
        }
        if QBChat.instance.isConnected == true {
            chatManager.updateStorage()
        }
        checkCreateChatButtonState()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.rightBarButtonItem?.title = "SA_STR_CREATE".localized
        title = "SA_STR_NEW_CHAT".localized
    }
    
    //MARK: - Internal Methods
    private func updateUsers() {
        
        let users = chatManager.storage.sortedAllUsers()
        setupUsers(users)
        checkCreateChatButtonState()
    }
    
    private func setupUsers(_ users: [QBUUser]) {
        var filteredUsers: [QBUUser] = []
        let currentUser = Profile()
        if currentUser.isFull == true {
            filteredUsers = users.filter({$0.id != currentUser.ID})
        }
        
        self.users = filteredUsers
        tableView.reloadData()
    }
    
    private func checkCreateChatButtonState() {
        navigationItem.rightBarButtonItem?.isEnabled = tableView.indexPathsForSelectedRows?.isEmpty == false
    }
    
    
    //MARK: - Actions
    @IBAction func createChatButtonPressed(_ sender: AnyObject) {
        guard let selectedIndexes = tableView.indexPathsForSelectedRows else {
            return
        }
        var selectedUsers: [QBUUser] = []
        for indexPath in selectedIndexes {
            let user = users[indexPath.row]
            selectedUsers.append(user)
        }
        let completion = { [weak self] (response: QBResponse?, dialog: QBChatDialog?) -> Void in
            guard let dialog = dialog else {
                if let error = response?.error {
                    SVProgressHUD.showError(withStatus: error.error?.localizedDescription)
                }
                return
            }
            
            for indexPath in selectedIndexes {
                self?.tableView.deselectRow(at: indexPath, animated: false)
            }
            
            SVProgressHUD.showSuccess(withStatus: "STR_DIALOG_CREATED".localized)
            
            self?.checkCreateChatButtonState()
            self?.openNewDialog(dialog)
        }
        
        let isPrivate = selectedUsers.count == 1
        
        if isPrivate {
            createChat(users: selectedUsers, completion: completion)
        } else {
           let alertController = UIAlertController(title: "SA_STR_ENTER_CHAT_NAME".localized,
                                                    message: nil,
                                                    preferredStyle: .alert)
            alertController.addTextField { (textField) in
                self.chatNameTextFeld = textField
                self.chatNameTextFeld.placeholder = "Enter Chat Name"
                self.chatNameTextFeld.delegate = self
            }
            let cancelAction = UIAlertAction(title: "SA_STR_CANCEL".localized, style: .cancel, handler: nil)
            successAction = UIAlertAction(title: "SA_STR_OK".localized, style: .default) { (action:UIAlertAction) in
                guard let textField = alertController.textFields?.first else {
                    return
                }
                var chatName = ""
                if let text = textField.text?.trimmingCharacters(in: CharacterSet.whitespaces) {
                    chatName = text
                }
                self.createChat(name: chatName, users: selectedUsers, completion: completion)

            }
            successAction.isEnabled = false
            alertController.addAction(cancelAction)
            alertController.addAction(successAction)
            present(alertController, animated: false) {
                self.checkCreateChatButtonState()
            }
        }
    }

    private func messageText(action: DialogAction, withUsers users: [QBUUser]) -> String {
        let actionMessage = "SA_STR_CREATE_NEW".localized
        guard let current = QBSession.current.currentUser,
            let fullName = current.fullName else {
                return ""
        }
        var message = "\(fullName) \(actionMessage)"
        for user in users {
            guard let userFullName = user.fullName else {
                continue
            }
            
            message += " \(userFullName),"
        }
        message = String(message.dropLast())
        return message
    }
    
    private func createChat(name: String? = nil,
                            users:[QBUUser],
                            completion: @escaping ((_ response: QBResponse?, _ createdDialog: QBChatDialog?) -> Void)) {
        SVProgressHUD.show(with: .clear)
        if users.count == 1 {
            // Creating private chat.
            guard let user = users.first else {
                SVProgressHUD.dismiss()
                completion(nil, nil)
                return
            }
            chatManager.createPrivateDialog(withOpponent: user, completion: { (response, dialog) in
                SVProgressHUD.showSuccess(withStatus: "SA_STR_COMPLETED".localized)
                guard let dialog = dialog else {
                    completion(nil, nil)
                    return
                }
                completion(response, dialog)
            })
        } else {
            // Creating group chat.
            let name = name ?? ""
            chatManager.createGroupDialog(withName: name,
                                          photo: nil,
                                          occupants: users) { [weak self] (response, dialog) -> Void in
                
                guard response?.error == nil,
                    let dialog = dialog,
                    let dialogOccupants = dialog.occupantIDs else {
                        SVProgressHUD.showError(withStatus: response?.error?.error?.localizedDescription)
                        return
                }
                guard let message = self?.messageText(action: .create, withUsers: users) else {
                    completion(response, nil)
                    return
                }
                self?.chatManager.sendAddingMessage(message, action: .create, withUsers: dialogOccupants, to: dialog, completion: { (error) in
                    completion(response, dialog)
                })
            }
        }
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
    
    // MARK: - UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SA_STR_CELL_USER".localized,
                                                       for: indexPath) as? UserTableViewCell else {
            return UITableViewCell()
        }
        let user = self.users[indexPath.row]
        cell.setupColorMarker(chatManager.color(indexPath.row))
        cell.userDescription = user.fullName ?? user.login
        cell.tag = indexPath.row
        return cell
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.checkCreateChatButtonState()
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        self.checkCreateChatButtonState()
    }
}

// MARK: - ChatManagerDelegate
extension CreateNewDialogViewController: ChatManagerDelegate {
    func chatManager(_ chatManager: ChatManager, didUpdateChatDialog chatDialog: QBChatDialog) {
        SVProgressHUD.dismiss()
    }
    
    func chatManagerWillUpdateStorage(_ chatManager: ChatManager) {
        SVProgressHUD.show(withStatus: "SA_STR_LOADING_USERS".localized, maskType: .clear)
    }
    
    func chatManager(_ chatManager: ChatManager, didFailUpdateStorage message: String) {
        SVProgressHUD.showError(withStatus: message)
    }
    
    func chatManager(_ chatManager: ChatManager, didUpdateStorage message: String) {
        SVProgressHUD.showSuccess(withStatus: message)
        setupUsers(chatManager.storage.sortedAllUsers())
    }
}

// MARK: - UITextFieldDelegate
extension CreateNewDialogViewController: UITextFieldDelegate {
    private func isValid(userName: String?) -> Bool {
        let characterSet = CharacterSet.whitespaces
        let trimmedText = userName?.trimmingCharacters(in: characterSet)
        let regularExtension = ChatNameRegularExtention.chatname
        let predicate = NSPredicate(format: "SELF MATCHES %@", regularExtension)
        let isValid = predicate.evaluate(with: trimmedText)
        return isValid
    }
    
    private func validate(_ textField: UITextField?) {
        if textField == chatNameTextFeld, isValid(userName: chatNameTextFeld.text) == false {
            self.successAction.isEnabled = false
        } else {
            self.successAction.isEnabled = true
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        validate(textField)
        return true
    }
}
