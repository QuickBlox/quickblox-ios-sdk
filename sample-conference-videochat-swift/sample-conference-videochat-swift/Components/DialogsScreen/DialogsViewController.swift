//
//  DialogsViewController.swift
//  sample-conference-videochat-swift
//
//  Created by Injoit on 9/30/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit
import Quickblox
import SVProgressHUD

class DialogsViewController: BaseDialogsViewController, DialogsView {
    //MARK: - Properties
    var onOpenChatScreenWithDialogID: ((String, Bool) -> Void)?
    var onSignIn: (() -> Void)?
    
    //MARK: - Setup
    override func setupNavigationBar() {
        let fullName = String(currentUser.fullName.capitalized.first ?? Character("U"))
        
        let profileBarButton = UIButton(frame: CGRect(x:0, y:0, width:28.0, height:28.0))
        profileBarButton.titleLabel?.font = .systemFont(ofSize: 13.0, weight: .semibold)
        profileBarButton.setTitle(fullName, for: .normal)
        profileBarButton.setTitle(fullName, for: .highlighted)
        profileBarButton.backgroundColor = currentUser.ID.generateColor()
        profileBarButton.layer.cornerRadius = 14.0
        profileBarButton.addTarget(self, action: #selector(didTapMenu(_:)), for: .touchUpInside)
        
        let leftBarButtonItem = UIBarButtonItem(customView: profileBarButton)
        self.navigationItem.leftBarButtonItem = leftBarButtonItem
        
        let usersButtonItem = UIBarButtonItem(image: UIImage(named: "add"),
                                              style: .plain,
                                              target: self,
                                              action: #selector(didTapNewChat(_:)))
        navigationItem.rightBarButtonItem = usersButtonItem
        usersButtonItem.tintColor = .white
    }
    
    override func setupNavigationTitle() {
        self.title = DialogsConstant.chats
    }
    
    override func setupDialogs() {
        chatManager.delegate = self
        SVProgressHUD.show()
        
        let tapGestureDelete = UILongPressGestureRecognizer(target: self, action: #selector(tapEdit(_:)))
        tapGestureDelete.minimumPressDuration = 0.3
        tapGestureDelete.delaysTouchesBegan = true
        tableView.addGestureRecognizer(tapGestureDelete)
        
        chatManager.updateStorage()
    }
    
    @objc func tapEdit(_ gestureReconizer: UILongPressGestureRecognizer) {
        guard gestureReconizer.state != UIGestureRecognizer.State.ended,
              let deleteVC = ScreenFactory().makeSelectionDialogsOutput() else { return }
        let navVC = UINavigationController(rootViewController: deleteVC)
        navVC.navigationBar.barTintColor = #colorLiteral(red: 0.2216441333, green: 0.4713830948, blue: 0.9869660735, alpha: 1)
        navVC.navigationBar.barStyle = .black
        navVC.navigationBar.shadowImage = UIImage(named: "navbar-shadow")
        navVC.navigationBar.isTranslucent = false
        navVC.modalPresentationStyle = .fullScreen
        present(navVC, animated: false) {
            self.tableView.removeGestureRecognizer(gestureReconizer)
        }
    }
    
    @objc func didTapNewChat(_ sender: UIBarButtonItem) {
        guard let createNewDialogVC = ScreenFactory().makeCreateNewDialogOutput() else { return }
        navigationController?.pushViewController(createNewDialogVC, animated: true)
    }
    
    @objc func didTapMenu(_ sender: UIBarButtonItem) {
        guard let actionsMenuVC = ScreenFactory().makeActionsMenuOutput() else { return }
        actionsMenuVC.typeActionsMenuVC = .appMenu
        actionsMenuVC.modalPresentationStyle = .overFullScreen
        
        let userProfileAction = MenuAction(title: Profile().fullName.capitalized, action: .userProfile) { (action) in
            print("User Profile")
        }
        let videoConfigAction = MenuAction(title: "Video Configuration", action: .videoConfig) { [weak self] (action) in
            guard let videoSettingVC = ScreenFactory().makeVideoSettingsOutput() else { return }
            self?.navigationController?.pushViewController(videoSettingVC, animated: true)
        }
        let audioConfigAction = MenuAction(title: "Audio Configuration", action: .audioConfig) { [weak self] (action) in
            guard let audioSettingVC = ScreenFactory().makeAudioSettingsOutput() else { return }
            self?.navigationController?.pushViewController(audioSettingVC, animated: true)
        }
        let appInfoAction = MenuAction(title: "App Info", action: .appInfo) { [weak self] (action) in
            self?.performSegue(withIdentifier: DialogsConstant.infoSegue, sender: nil)
        }
        let logoutAction = MenuAction(title: "Logout", action: .logout) { [weak self] (action) in
            self?.didTapLogout()
        }
        
        actionsMenuVC.addAction(userProfileAction)
        actionsMenuVC.addAction(videoConfigAction)
        actionsMenuVC.addAction(audioConfigAction)
        actionsMenuVC.addAction(appInfoAction)
        actionsMenuVC.addAction(logoutAction)
        
        present(actionsMenuVC, animated: false)
    }
    
    private func didTapLogout() {
        SVProgressHUD.show(withStatus: "Logouting...")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        guard let uuidString = UIDevice.current.identifierForVendor?.uuidString else {
            return
        }
        #if targetEnvironment(simulator)
        disconnectUser()
        #else
        QBRequest.subscriptions(successBlock: { [weak self] (response, subscriptions) in
            guard let subscriptions = subscriptions, subscriptions.isEmpty == false else {
                self?.disconnectUser()
                return
            }
            let deleteSubscriptionsGroup = DispatchGroup()
            for subscription in subscriptions {
                if let subscriptionsUIUD = subscription.deviceUDID,
                   subscriptionsUIUD == uuidString {
                    deleteSubscriptionsGroup.enter()
                    QBRequest.deleteSubscription(withID: subscription.id) { (response) in
                        deleteSubscriptionsGroup.leave()
                        debugPrint("[NotificationsProvider] Unregister Subscription request - Success")
                    } errorBlock: { (response) in
                        deleteSubscriptionsGroup.leave()
                        debugPrint("[NotificationsProvider] Unregister Subscription request - Error")
                    }
                }
            }
            deleteSubscriptionsGroup.notify(queue: DispatchQueue.main) {
                self?.disconnectUser()
            }
        }) { response in
            if response.status.rawValue == 404 {
                self.showLoginScreen()
            } else if let error = response.error?.error {
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            }
        }
        #endif
    }
    
    //MARK: - Internal Methods
    //MARK: - logOut flow
    fileprivate func showLoginScreen() {
        Profile.clear()
        chatManager.storage.clear()
        CacheManager.shared.clearCache()
        onSignIn?()
        SVProgressHUD.showSuccess(withStatus: "Complited")
    }
    
    private func disconnectUser() {
        chatManager.disconnect()
        logOut()
    }
    
    private func logOut() {
        QBRequest.logOut(successBlock: { [weak self] response in
            self?.showLoginScreen()
        }) { response in
            debugPrint("[DialogsViewController] logOut error: \(response)")
        }
    }
    
    // MARK: - UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dialogs.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    override func tableView(_ tableView: UITableView,
                            configureCell cell: DialogCell,
                            for indexPath: IndexPath) {
        
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
        if let dialogID = dialog.id {
            onOpenChatScreenWithDialogID?(dialogID, false)
        }
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
        guard let dialogID = message.dialogID,
              chatManager.storage.dialog(withID: dialogID) == nil else {
            return
        }
        chatManager.updateDialog(with: dialogID, with: message)
    }
    
    func chatServiceChatDidFail(withStreamError error: Error) {
        SVProgressHUD.showError(withStatus: error.localizedDescription)
    }
    
    func chatDidAccidentallyDisconnect() {
    }
    
    func chatDidNotConnectWithError(_ error: Error) {
        SVProgressHUD.showError(withStatus: error.localizedDescription)
    }
    
    func chatDidDisconnectWithError(_ error: Error?) {
        if let error = error {
            SVProgressHUD.showError(withStatus: error.localizedDescription)
        }
    }
    
    func chatDidConnect() {
        if QBChat.instance.isConnected == true {
            chatManager.updateStorage()
            SVProgressHUD.showSuccess(withStatus: "SA_STR_CONNECTED".localized)
        }
    }
    
    func chatDidReconnect() {
        SVProgressHUD.show(withStatus: "SA_STR_CONNECTED".localized)
        if QBChat.instance.isConnected == true {
            chatManager.updateStorage()
            SVProgressHUD.showSuccess(withStatus: "SA_STR_CONNECTED".localized)
        }
    }
}

// MARK: - ChatManagerDelegate
extension DialogsViewController: ChatManagerDelegate {
    func chatManager(_ chatManager: ChatManager, didUpdateChatDialog chatDialog: QBChatDialog) {
        reloadContent()
        SVProgressHUD.dismiss()
    }
    
    func chatManager(_ chatManager: ChatManager, didFailUpdateStorage message: String) {
        SVProgressHUD.showError(withStatus: message)
    }
    
    func chatManager(_ chatManager: ChatManager, didUpdateStorage message: String) {
        reloadContent()
        SVProgressHUD.dismiss()
        QBChat.instance.addDelegate(self)
    }
    
    func chatManagerWillUpdateStorage(_ chatManager: ChatManager) {
        if navigationController?.topViewController == self {
            
        }
    }
}
