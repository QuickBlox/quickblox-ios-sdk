//
//  UsersInfoTableViewController.swift
//  sample-conference-videochat-swift
//
//  Created by Injoit on 1/28/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit
import Quickblox
import SVProgressHUD

struct UsersInfoConstant {
    static let perPage:UInt = 10
    static let delivered = "Message delivered to"
    static let viewed = "Message viewed by"
}

class UsersInfoTableViewController: UITableViewController {
    
    //MARK: - Properties
    /**
     *  This property is required when creating a ChatViewController.
     */
    var dialogID: String! {
        didSet {
            self.dialog = chatManager.storage.dialog(withID: dialogID)
        }
    }
    
    /**
     *  Mute user block action.
     */
    var didPressMuteUser: ((_ isMuted: Bool, _ userID: UInt) -> Void)?
    
    var currentUser = Profile()
    var message: QBChatMessage?
    var action: ChatActions?
    private var titleView = TitleView()
    private var dialog: QBChatDialog!
    var users: [QBUUser] = []
    var usersAudioEnabled: [UInt: Bool] = [:]
    let chatManager = ChatManager.instance
    private lazy var addUsersItem = UIBarButtonItem(image: UIImage(named: "add_user"),
                                                    style: .plain,
                                                    target: self,
                                                    action:#selector(didTapAddUsers(_:)))
    //MARK: - Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.titleView = titleView
        
        tableView.register(UINib(nibName: UserCellConstant.reuseIdentifier, bundle: nil),
                           forCellReuseIdentifier: UserCellConstant.reuseIdentifier)
        
        

        setupUsers(dialogID)
        
        let backButtonItem = UIBarButtonItem(image: UIImage(named: "chevron"),
                                             style: .plain,
                                             target: self,
                                             action: #selector(didTapBack(_:)))
        navigationItem.leftBarButtonItem = backButtonItem
        backButtonItem.tintColor = .white
        
        navigationItem.rightBarButtonItem = addUsersItem
        
        switch action {
        case .InfoFromCall:
            addUsersItem.tintColor = .clear
            addUsersItem.isEnabled = false
            debugPrint("InfoFromCall")
        case .ChatInfo, .ChatFromCall:
            addUsersItem.tintColor = .white
            addUsersItem.isEnabled = true
        case .ViewedBy:
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(chatDidReadMessageNotification(_:)),
                                                   name: ChatViewControllerConstant.chatDidReadMessageNotification,
                                                   object: nil)
        case .DeliveredTo:
            setupUsers(dialogID)
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(chatDidDeliverMessageNotification(_:)),
                                                   name: ChatViewControllerConstant.chatDidDeliverMessageNotification,
                                                   object: nil)
        default:
            debugPrint("default")
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(chatDidBecomeOnlineUserNotification(_:)),
                                               name: ChatViewControllerConstant.chatDidBecomeOnlineUserNotification,
                                               object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Internal Methods
    private func setupNavigationTitleByAction() {
        var title = dialog.name ?? ""
        var members = " members"
        if action == .ViewedBy {
            title = UsersInfoConstant.viewed
        } else if action == .DeliveredTo {
            title = UsersInfoConstant.delivered
        } else if action == ChatActions.InfoFromCall {
            navigationController?.navigationBar.barStyle = .black
            navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.2216441333, green: 0.4713830948, blue: 0.9869660735, alpha: 1)
            navigationController?.navigationBar.tintColor = .white
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            members = " in call"
        }
        
        let numberUsers = "\(self.users.count)" + members
        titleView.setupTitleView(title: title, subTitle: numberUsers)
    }
    
    //MARK: - Actions
    @objc func chatDidReadMessageNotification(_ notification: Notification?) {
        if let readedMessage = notification?.userInfo?["message"] as? QBChatMessage,
            readedMessage.id == self.message?.id {
            self.message = readedMessage
            updateUsers()
        }
    }
    
    @objc func chatDidDeliverMessageNotification(_ notification: Notification?) {
        if let deliverMessage = notification?.userInfo?["message"] as? QBChatMessage,
            deliverMessage.id == self.message?.id {
            self.message = deliverMessage
            updateUsers()
        }
    }
    
    @objc func chatDidBecomeOnlineUserNotification(_ notification: Notification?) {
        if let userID = notification?.userInfo?["userID"] as? UInt {
            if let onlineUser = self.users.filter({ $0.id == userID }).first, let index = self.users.index(of: onlineUser) {
                self.users.remove(at: index)
                self.users.insert(onlineUser, at: 0)
                let indexPath = IndexPath(item: index, section: 0)
                let indexPathFirst = IndexPath(item: 0, section: 0)
                tableView.beginUpdates()
                tableView.deleteRows(at: [indexPath], with: .left)
                tableView.insertRows(at: [indexPathFirst], with: .left)
                tableView.endUpdates()
            }
        }
    }
    
    @objc func didTapBack(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func didTapAddUsers(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "SA_STR_SEGUE_GO_TO_ADD_OPPONENTS".localized, sender: nil)
    }
    
    //MARK: - Internal Methods
    private func updateUsers() {
        guard let occupantIDs = dialog.occupantIDs  else {
            return
        }
        if occupantIDs.isEmpty == false {
            setupUsers(dialogID)
        }
    }
    
    private func setupUsers(_ dialogID: String) {
        guard currentUser.isFull == true else {
            return
        }
        if action != ChatActions.InfoFromCall {
            chatManager.delegate = self
            self.users = chatManager.storage.users(with: dialogID)
        }
        
        if let message = message, let action = action {
            if action == .ViewedBy {
                var readUsers: [QBUUser] = []
                //check and add users who read the message
                if let readIDs = message.readIDs,
                    readIDs.isEmpty == false {
                    for readID in readIDs {
                        if let user = chatManager.storage.user(withID: readID.uintValue) {
                            readUsers.append(user)
                        }
                    }
                }
                self.users = readUsers
            } else if action == .DeliveredTo {
                var deliveredUsers: [QBUUser] = []
                //check and add users who read the message
                if let deliveredIDs = message.deliveredIDs,
                    deliveredIDs.isEmpty == false {
                    for deliveredID in deliveredIDs {
                        if let user = chatManager.storage.user(withID: deliveredID.uintValue) {
                            deliveredUsers.append(user)
                        }
                    }
                }
                self.users = deliveredUsers
            }
        }
        setupNavigationTitleByAction()
        tableView.reloadData()
    }
    
    //MARK: - Overrides
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SA_STR_SEGUE_GO_TO_ADD_OPPONENTS".localized {
            guard let addOccupantsVC = segue.destination as? AddOccupantsVC else {
                return
            }
            addOccupantsVC.dialogID = dialogID
            if action == ChatActions.ChatFromCall {
                addOccupantsVC.action = ChatActions.ChatFromCall
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
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UserCellConstant.reuseIdentifier,
                                                       for: indexPath) as? UserTableViewCell else {
                                                        return UITableViewCell()
        }
        let user = self.users[indexPath.row]
        cell.userColor = user.id.generateColor()
        
        if action == ChatActions.InfoFromCall {
            cell.muteButton.isHidden = false
            cell.muteButton.isEnabled = true
            if let isSelected = usersAudioEnabled[user.id] {
                cell.muteButton.isSelected = !isSelected
            } else {
                cell.muteButton.isSelected = false
            }
            cell.didPressMuteButton = { [weak self] isMuted in
                self?.didPressMuteUser?(isMuted, user.id)
            }
        }
        let userName = user.fullName ?? "QB user"
        if currentUser.ID == user.id {
            cell.muteButton.isHidden = true
            cell.muteButton.isEnabled = false
            cell.userNameLabel.text = userName + " (You)"
        } else {
            cell.userNameLabel.text = userName
        }
        
        cell.userAvatarLabel.text = String(user.fullName?.capitalized.first ?? Character("U"))
        cell.tag = indexPath.row
        cell.checkBoxView.isHidden = true
        cell.checkBoxImageView.isHidden = true
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
}

// MARK: - ChatManagerDelegate
extension UsersInfoTableViewController: ChatManagerDelegate {
    func chatManager(_ chatManager: ChatManager, didUpdateChatDialog chatDialog: QBChatDialog, isOnCall: Bool?) {
        if chatDialog.id == dialogID {
            updateUsers()
        }
        SVProgressHUD.dismiss()
    }
    
    func chatManagerWillUpdateStorage(_ chatManager: ChatManager) {
        SVProgressHUD.show(withStatus: "SA_STR_LOADING_USERS".localized)
    }
    
    func chatManager(_ chatManager: ChatManager, didFailUpdateStorage message: String) {
        SVProgressHUD.showError(withStatus: message)
    }
    
    func chatManager(_ chatManager: ChatManager, didUpdateStorage message: String) {
        SVProgressHUD.showSuccess(withStatus: message)
        
        guard let dialogID = dialogID else {
            return
        }
        setupUsers(dialogID)
    }
}

// MARK: - CallViewControllerDelegate
extension UsersInfoTableViewController: CallViewControllerDelegate {
    func callVC(_ callVC: CallViewController, didAddNewPublisher userID: UInt) {
        if let user = chatManager.storage.user(withID: userID) {
            users.insert(user, at: 0)
            let indexPath = IndexPath(row: 0, section: 0)
            tableView.beginUpdates()
            tableView.insertRows(at: [indexPath], with: .left)
            tableView.endUpdates()
        }
    }
}
