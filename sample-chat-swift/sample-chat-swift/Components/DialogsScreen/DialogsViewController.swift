//
//  DialogsViewController.swift
//  sample-chat-swift
//
//  Created by Injoit on 9/30/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit
import Quickblox

class DialogsViewController: DialogListViewController {
    //MARK: - Properties
    var onSignIn: (() -> Void)?
    private var isPresentAlert = false
    private var connection: ConnectionModule! {
        didSet {
            connection.onAuthorize = {
                debugPrint("[\(DialogsViewController.className)] [connection] On Authorize")
                let userDefaults = UserDefaults.standard
                guard userDefaults.bool(forKey: NotificationsConstant.needUpdateToken) != false,
                      let token = userDefaults.object(forKey: NotificationsConstant.token) as? Data else {
                          return
                      }
                NotificationsProvider.deleteLastSubscription {
                    NotificationsProvider.createSubscription(withToken: token)
                }
            }
            
            connection.onConnect = { [weak self] in
                guard let self = self else {
                    return
                }
                self.isPresentAlert = false
                debugPrint("[\(DialogsViewController.className)] [connection] On Connect")
                self.showAnimatedAlertView(nil, message: ConnectionConstant.connectionEstablished)
                self.refreshControl?.beginRefreshing()
                self.chatManager.updateStorage()
            }
            
            connection.onDisconnect = { [weak self] (isNetwork) in
                guard let self = self else {
                    return
                }
                debugPrint("[\(DialogsViewController.className)] [connection] On Disconnect")
                if isNetwork == true || self.isPresentAlert == true { return }
                self.isPresentAlert = true
                self.refreshControl?.endRefreshing()
                self.showAnimatedAlertView(nil, message: ConnectionConstant.noInternetConnection)
            }
        }
    }
    
    //MARK: - Setup
    override func setupNavigationBar() {
        connection = ConnectionModule()
        connection.activateAutomaticMode()
        
        QBChat.instance.addDelegate(self)
        
        navigationItem.rightBarButtonItems = []
        navigationItem.leftBarButtonItems = []
        let exitButtonItem = UIBarButtonItem(image: UIImage(named: "exit"),
                                             style: .plain,
                                             target: self,
                                             action: #selector(didTapLogout))
        exitButtonItem.tintColor = .white
        
        let emptyButtonItem = UIBarButtonItem(image: UIImage(named: "icon-info"),
                                              style: .plain,
                                              target: self,
                                              action: nil)
        emptyButtonItem.tintColor = .clear
        emptyButtonItem.isEnabled = false
        navigationItem.leftBarButtonItems = [exitButtonItem, emptyButtonItem]
        
        let usersButtonItem = UIBarButtonItem(image: UIImage(named: "add"),
                                              style: .plain,
                                              target: self,
                                              action: #selector(didTapNewChat(_:)))
        navigationItem.rightBarButtonItem = usersButtonItem
        usersButtonItem.tintColor = .white
        addInfoButton()
    }
    
    override func setupNavigationTitle() {
        self.title = DialogsConstant.chats
    }
    
    override func setupDialogs() {
        chatManager.delegate = self
        let tapGestureDelete = UILongPressGestureRecognizer(target: self, action: #selector(didTapEdit(_:)))
        tapGestureDelete.minimumPressDuration = 0.5
        tapGestureDelete.delaysTouchesBegan = true
        tableView.addGestureRecognizer(tapGestureDelete)
        chatManager.updateStorage()
        self.refreshControl?.beginRefreshing()
    }
    
    @objc private func didTapEdit(_ gestureReconizer: UILongPressGestureRecognizer) {
        guard gestureReconizer.state != .ended else {
            return
        }
        gestureReconizer.state = .ended
        tableView.removeGestureRecognizer(gestureReconizer)
        guard let deleteVC = Screen.dialogsSelectionViewController() else {
            return
        }
        deleteVC.action = .delete
        navigationController?.pushViewController(deleteVC, animated: false)
    }
    
    @objc private func didTapNewChat(_ sender: UIBarButtonItem) {
        guard let createNewDialogVC = Screen.createNewDialogViewController() else {
            return
        }
        navigationController?.pushViewController(createNewDialogVC, animated: true)
    }
    
    @objc private func didTapLogout() {
        if QBChat.instance.isConnected == false {
            showAnimatedAlertView(nil, message: ConnectionConstant.noInternetConnection)
            return
        }
        progressView.start()
        NotificationsProvider.deleteLastSubscription { [weak self] in
            self?.connection.breakConnection {
                guard let self = self else {
                    return
                }
                self.connection.deactivateAutomaticMode()
                UserDefaults.standard.removeObject(forKey: NotificationsConstant.token)
                self.navigationController?.popToRootViewController(animated: false)
                Profile.clear()
                self.chatManager.storage.clear()
                CacheManager.shared.clearCache()
                self.progressView.stop()
                self.onSignIn?()
            }
        }
    }
    
    @IBAction func refreshDialogs(_ sender: UIRefreshControl) {
        chatManager.updateStorage()
    }
    
    //MARK: - Internal Methods
    private func openChatScreen(_ dialogID: String) {
        guard let chatVC = Screen.chatViewController() else {
            return
        }
        chatVC.dialogID = dialogID
        navigationController?.pushViewController(chatVC, animated: false)
    }
    
    // MARK: - UITableViewDataSource
    override func configure(cell: DialogCell, for indexPath: IndexPath) {
        tableView.allowsMultipleSelection = false
        cell.checkBoxImageView.isHidden = true
        cell.checkBoxView.isHidden = true
        cell.lastMessageDateLabel.isHidden = false
        cell.contentView.backgroundColor = .clear
        cell.lastMessageDateLabel.isHidden = false
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let dialog = dialogs[indexPath.row]
        guard let dialogID = dialog.id else {
            return
        }
        openChatScreen(dialogID)
    }
}

// MARK: - QBChatDelegate
extension DialogsViewController: QBChatDelegate {
    func chatRoomDidReceive(_ message: QBChatMessage, fromDialogID dialogID: String) {
        if currentUser.ID == message.senderID,
           message.isNotificationMessageTypeLeave == true,
           let index = dialogs.firstIndex(where: { $0.id == dialogID })  {
            chatManager.delegate = self
            dialogs.remove(at: index)
            let indexPath = IndexPath(item: index, section: 0)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .none)
            tableView.endUpdates()
            return
        }
        chatManager.updateDialog(with: dialogID, with: message)
    }
    
    func chatDidReceive(_ message: QBChatMessage) {
        guard let dialogID = message.dialogID else {
            return
        }
        chatManager.updateDialog(with: dialogID, with: message)
    }
    
    func chatDidReceiveSystemMessage(_ message: QBChatMessage) {
        guard message.senderID != currentUser.ID else {
            return
        }
        guard let dialogID = message.dialogID,
              chatManager.storage.dialog(withID: dialogID) == nil else {
                  return
              }
        chatManager.updateDialog(with: dialogID, with: message)
    }
    
    func chatServiceChatDidFail(withStreamError error: Error) {
        debugPrint("[DialogsViewController] \(#function) error: \(error.localizedDescription)")
    }
    
    func chatDidAccidentallyDisconnect() {
        debugPrint("[DialogsViewController] \(#function)")
    }
    
    func chatDidNotConnectWithError(_ error: Error) {
        debugPrint("[DialogsViewController] \(#function) error: \(error.localizedDescription)")
    }
    
    func chatDidDisconnectWithError(_ error: Error?) {
        if let error = error {
            debugPrint("[DialogsViewController] \(#function) error: \(error.localizedDescription)")
        }
    }
    
    func chatDidConnect() {
        debugPrint("[DialogsViewController] \(#function)")
    }
    
    func chatDidReconnect() {
        debugPrint("[DialogsViewController] \(#function)")
    }
}

// MARK: - ChatManagerDelegate
extension DialogsViewController: ChatManagerDelegate {
    func chatManager(_ chatManager: ChatManager, didUpdateChatDialog chatDialog: QBChatDialog) {
        reloadContent()
    }
    
    func chatManager(_ chatManager: ChatManager, didFailUpdateStorage message: String) {
        refreshControl?.endRefreshing()
        showAnimatedAlertView(nil, message: message)
    }
    
    func chatManager(_ chatManager: ChatManager, didUpdateStorage message: String) {
        reloadContent()
    }
    
    func chatManagerWillUpdateStorage(_ chatManager: ChatManager) {
        if navigationController?.topViewController == self {
            
        }
    }
}
