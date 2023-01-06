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
    var onSignOut: (() -> Void)?
    var splashVC: SplashScreenViewController!
    private let authModule = AuthModule()
    private let connection = ConnectionModule()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        connection.delegate = self
        if connection.established == false {
            showSplashScreen()
        }
        connection.activateAutomaticMode()
        authModule.delegate = self
        QBChat.instance.addDelegate(self)
        chatManager.delegate = self
        
        let tapGestureDelete = UILongPressGestureRecognizer(target: self, action: #selector(didTapEdit(_:)))
        tapGestureDelete.minimumPressDuration = 0.5
        tapGestureDelete.delaysTouchesBegan = true
        tableView.addGestureRecognizer(tapGestureDelete)
    }
    
    //MARK: - Setup
    override func setupNavigationBar() {
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
        chatManager.updateStorage()
        self.refreshControl?.beginRefreshing()
    }
    
    @objc private func didTapEdit(_ gestureReconizer: UILongPressGestureRecognizer) {
        guard gestureReconizer.state != .ended else {
            return
        }
        gestureReconizer.state = .ended
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
        logout()
    }
    
    private func logout() {
        if connection.established == false {
            showAnimatedAlertView(nil, message: ConnectionConstant.connectingState)
            return
        }
        progressView.start()
        NotificationsProvider.clearSubscription { [weak self] in
            self?.connection.breakConnection {
                guard let self = self else {
                    return
                }
                self.authModule.logout()
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
        let dialog = dialogs[indexPath.row]
        tableView.allowsMultipleSelection = false
        cell.checkBoxImageView.isHidden = true
        cell.checkBoxView.isHidden = true
        cell.lastMessageDateLabel.isHidden = false
        cell.contentView.backgroundColor = .clear
        cell.lastMessageDateLabel.isHidden = false
        cell.unreadMessageCounterLabel.isHidden = false
        if dialog.type != .publicGroup {
            cell.unreadMessageCounterLabel.text = dialog.unreadMessagesCounter
            cell.unreadMessageCounterHolder.isHidden = dialog.unreadMessagesCounter == nil
        }
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
    
    //MARK: - Helper Methods
    fileprivate func showSplashScreen() {
        if splashVC == nil, let splashVC = Screen.splashScreenController() {
            self.splashVC = splashVC
            splashVC.modalPresentationStyle = .overCurrentContext
            self.present(splashVC, animated: false)
        }
    }
    
    fileprivate func hideSplashScreen() {
        if splashVC == nil {
            return
        }
        splashVC?.dismiss(animated: false, completion: {
            self.splashVC = nil
        })
        progressView.stop()
    }
}

// MARK: - QBChatDelegate
extension DialogsViewController: QBChatDelegate {
    func chatRoomDidReceive(_ message: QBChatMessage, fromDialogID dialogID: String) {
        chatManager.updateDialog(with: dialogID, with: message)
    }
    
    func chatDidReceive(_ message: QBChatMessage) {
        guard let dialogID = message.dialogID else {
            return
        }
        chatManager.updateDialog(with: dialogID, with: message)
    }
    
    func chatDidReceiveSystemMessage(_ message: QBChatMessage) {
        guard let dialogID = message.dialogID else {
            return
        }
        chatManager.updateDialog(with: dialogID, with: message)
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
        debugPrint("[DialogsViewController] didUpdateStorage")
        reloadContent()
    }
}

// MARK: - AuthModuleDelegate
extension DialogsViewController: AuthModuleDelegate {
    func authModule(_ authModule: AuthModule, didLoginUser user: QBUUser) {
        Profile.synchronize(withUser: user)
        connection.establish()
        let userDefaults = UserDefaults.standard
        guard userDefaults.bool(forKey: NotificationsConstant.needUpdateToken) != false,
              let token = userDefaults.object(forKey: NotificationsConstant.token) as? Data else {
            return
        }
        NotificationsProvider.deleteLastSubscription {
            NotificationsProvider.createSubscription(withToken: token)
        }
    }
    
    func authModuleDidLogout(_ authModule: AuthModule) {
        connection.deactivateAutomaticMode()
        navigationController?.popToRootViewController(animated: false)
        Profile.clear()
        chatManager.storage.clear()
        CacheManager.shared.clearCache()
        progressView.stop()
        onSignOut?()
    }
    
    func authModule(_ authModule: AuthModule, didReceivedError error: ErrorInfo) {
        showUnAuthorizeAlert(message: error.info, logoutAction: { [weak self] action in
            self?.logout()
        }, tryAgainAction: { action in
            let profile = Profile()
            authModule.login(fullName: profile.fullName, login: profile.login)
        })
    }
}

// MARK: - ConnectionModuleDelegate
extension DialogsViewController: ConnectionModuleDelegate {
    func connectionModuleWillConnect(_ connectionModule: ConnectionModule) {
        showAnimatedAlertView(nil, message: ConnectionConstant.connectingState)
    }
    
    func connectionModuleDidConnect(_ connectionModule: ConnectionModule) {
        setupDialogs()
        hideAlertView()
        hideSplashScreen()
    }
    
    func connectionModuleDidNotConnect(_ connectionModule: ConnectionModule, error: Error) {
        hideSplashScreen()
        refreshControl?.endRefreshing()
        if error._code.isNetworkError {
            showNoInternetAlert(handler: nil)
            return
        }
        showAlertView(nil, message: error.localizedDescription, handler: nil)
    }
    
    func connectionModuleWillReconnect(_ connectionModule: ConnectionModule) {
        refreshControl?.endRefreshing()
        showAnimatedAlertView(nil, message: ConnectionConstant.reconnectingState)
    }
    
    func connectionModuleDidReconnect(_ connectionModule: ConnectionModule) {
        setupDialogs()
        hideAlertView()
    }
    
    func connectionModuleTokenHasExpired(_ connectionModule: ConnectionModule) {
        showSplashScreen()
        refreshControl?.endRefreshing()
        let profile = Profile()
        authModule.login(fullName: profile.fullName, login: profile.login)
    }
}
