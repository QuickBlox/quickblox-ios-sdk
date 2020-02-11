//
//  NewDialogsViewController.swift
//  sample-chat-swift
//
//  Created by Vladimir Nybozhinsky on 9/30/19.
//  Copyright © 2019 quickblox. All rights reserved.
//

import UIKit
import Quickblox
import SVProgressHUD

struct DialogsConstant {
    static let dialogsPageLimit:Int = 100
    static let segueGoToChat = "goToChat"
    static let selectOpponents = "SelectOpponents"
    static let infoSegue = "PresentInfoViewController"
    static let deleteChats = "Delete Chats"
    static let forward = "Forward to"
    static let deleteDialogs = "deleteDialogs"
    static let chats = "Chats"
}

class DialogTableViewCellModel: NSObject {
    
    //MARK: - Properties
    var textLabelText: String = ""
    var unreadMessagesCounterLabelText : String?
    var unreadMessagesCounterHiden = true
    var dialogIcon : UIImage?
    
    //MARK: - Life Cycle
    init(dialog: QBChatDialog) {
        super.init()
        
        textLabelText = dialog.name ?? "UN"
        
        // Unread messages counter label
        if dialog.unreadMessagesCount > 0 {
            var trimmedUnreadMessageCount = ""
            
            if dialog.unreadMessagesCount > 99 {
                trimmedUnreadMessageCount = "99+"
            } else {
                trimmedUnreadMessageCount = String(format: "%d", dialog.unreadMessagesCount)
            }
            unreadMessagesCounterLabelText = trimmedUnreadMessageCount
            unreadMessagesCounterHiden = false
        } else {
            unreadMessagesCounterLabelText = nil
            unreadMessagesCounterHiden = true
        }
        // Dialog icon
        if dialog.type == .private {
            dialogIcon = UIImage(named: "user")
            
            if dialog.recipientID == -1 {
                return
            }
            // Getting recipient from users.
            if let recipient = ChatManager.instance.storage.user(withID: UInt(dialog.recipientID)),
                let fullName = recipient.fullName {
                self.textLabelText = fullName
            } else {
                ChatManager.instance.loadUser(UInt(dialog.recipientID)) { [weak self] (user) in
                    self?.textLabelText = user?.fullName ?? user?.login ?? ""
                }
            }
        } else {
            self.dialogIcon = UIImage(named: "group")
        }
    }
}

class NewDialogsViewController: UITableViewController {
    var chatVC: ChatViewController?
    var testCompletion:((_ message: String) -> String)?
    //MARK: - Properties
    private let chatManager = ChatManager.instance
    private var dialogs: [QBChatDialog] = []
    private var titleView = TitleView()
    private var cancel = false
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.titleView = titleView
        setupNavigationTitle()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        chatManager.delegate = self
        if QBChat.instance.isConnected == true {
            chatManager.updateStorage()
        }
        
        setupNavigationBar()
        setupNavigationTitle()
        let tapGestureDelete = UILongPressGestureRecognizer(target: self, action: #selector(tapEdit(_:)))
        tapGestureDelete.minimumPressDuration = 0.3
        tapGestureDelete.delaysTouchesBegan = true
        tapGestureDelete.delegate = self as? UIGestureRecognizerDelegate
        tableView.addGestureRecognizer(tapGestureDelete)
    }
    
    //MARK: - Setup NavBar
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItems = []
        navigationItem.leftBarButtonItems = []
            let exitButtonItem = UIBarButtonItem(image: UIImage(named: "exit"),
                                                 style: .plain,
                                                 target: self,
                                                 action: #selector(didTapLogout(_:)))
            exitButtonItem.tintColor = .white
        
        let emptyButtonItem = UIBarButtonItem(image: UIImage(named: "icon-info"),
                                             style: .plain,
                                             target: self,
                                             action: #selector(didTapEmpty(_:)))
        emptyButtonItem.tintColor = .clear
        emptyButtonItem.isEnabled = false
        navigationItem.leftBarButtonItems = [exitButtonItem, emptyButtonItem]
        
            let usersButtonItem = UIBarButtonItem(image: UIImage(named: "add"),
                                                  style: .plain,
                                                  target: self,
                                                  action: #selector(didTapNewChat(_:)))
            navigationItem.rightBarButtonItem = usersButtonItem
            usersButtonItem.tintColor = .white
            showInfoButton()
    }
    
    @objc func tapEdit(_ gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state != UIGestureRecognizer.State.ended {
            if let deleteVC = storyboard?.instantiateViewController(withIdentifier: "DialogsSelectionVC") as? DialogsSelectionVC {
                deleteVC.action = ChatActions.Delete
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
        }
    }
    
    @objc func didTapEmpty(_ sender: UIBarButtonItem) {

    }
    
    @objc func didTapInfo(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: DialogsConstant.infoSegue, sender: sender)
    }
    
    @objc func didTapNewChat(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: DialogsConstant.selectOpponents, sender: sender)
    }
    
    
    @objc func didTapLogout(_ sender: UIBarButtonItem) {
        if QBChat.instance.isConnected == false {
            SVProgressHUD.showError(withStatus: "Error")
            return
        }
        SVProgressHUD.show(withStatus: "SA_STR_LOGOUTING".localized)
        SVProgressHUD.setDefaultMaskType(.clear)
        
        guard let identifierForVendor = UIDevice.current.identifierForVendor else {
            return
        }
        let uuidString = identifierForVendor.uuidString
        #if targetEnvironment(simulator)
        disconnectUser()
        #else
        QBRequest.subscriptions(successBlock: { (response, subscriptions) in
            if let subscriptions = subscriptions {
                for subscription in subscriptions {
                    if let subscriptionsUIUD = subscriptions.first?.deviceUDID,
                        subscriptionsUIUD == uuidString,
                        subscription.notificationChannel == .APNS {
                        self.unregisterSubscription(forUniqueDeviceIdentifier: uuidString)
                        return
                    }
                }
            }
            self.disconnectUser()
            
        }) { response in
            if response.status.rawValue == 404 {
                self.disconnectUser()
            }
        }
        #endif
    }
    
    private func unregisterSubscription(forUniqueDeviceIdentifier uuidString: String) {
        QBRequest.unregisterSubscription(forUniqueDeviceIdentifier: uuidString, successBlock: { response in
            self.disconnectUser()
        }, errorBlock: { error in
            if let error = error.error {
                SVProgressHUD.showError(withStatus: error.localizedDescription)
                return
            }
            SVProgressHUD.dismiss()
        })
    }
    
    //MARK: - Internal Methods
    private func disconnectUser() {
        QBChat.instance.disconnect(completionBlock: { error in
            if let error = error {
                SVProgressHUD.showError(withStatus: error.localizedDescription)
                return
            }
            self.logOut()
        })
    }
    
    private func logOut() {
        QBRequest.logOut(successBlock: { [weak self] response in
            //ClearProfile
            Profile.clearProfile()
            self?.chatManager.storage.clear()
            CacheManager.shared.clearCache()
            self?.navigationController?.popToRootViewController(animated: false)
            SVProgressHUD.showSuccess(withStatus: "SA_STR_COMPLETED".localized)
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DialogCell",
                                                       for: indexPath) as? DialogCell else {
                                                        return UITableViewCell()
        }
        
        cell.isExclusiveTouch = true
        cell.contentView.isExclusiveTouch = true
        cell.tag = indexPath.row
        
        let chatDialog = dialogs[indexPath.row]
        let cellModel = DialogTableViewCellModel(dialog: chatDialog)
        
            tableView.allowsMultipleSelection = false
            cell.checkBoxImageView.isHidden = true
            cell.checkBoxView.isHidden = true
            cell.unreadMessageCounterLabel.isHidden = false
            cell.unreadMessageCounterHolder.isHidden = false
            cell.lastMessageDateLabel.isHidden = false
            cell.contentView.backgroundColor = .clear
            
            if let dateSend = chatDialog.lastMessageDate {
                cell.lastMessageDateLabel.text = setupDate(dateSend)
            } else if let dateUpdate = chatDialog.updatedAt {
                cell.lastMessageDateLabel.text = setupDate(dateUpdate)
            }
            
            cell.unreadMessageCounterLabel.text = cellModel.unreadMessagesCounterLabelText
            cell.unreadMessageCounterHolder.isHidden = cellModel.unreadMessagesCounterHiden

        cell.dialogLastMessage.text = chatDialog.lastMessageText
        if chatDialog.lastMessageText == nil && chatDialog.lastMessageID != nil {
            cell.dialogLastMessage.text = "[Attachment]"
        }
        if let dateSend = chatDialog.lastMessageDate {
            cell.lastMessageDateLabel.text = setupDate(dateSend)
        } else if let dateUpdate = chatDialog.updatedAt {
            cell.lastMessageDateLabel.text = setupDate(dateUpdate)
        }
        
        cell.dialogName.text = cellModel.textLabelText
        cell.dialogAvatarLabel.backgroundColor = chatManager.color(indexPath.row)
        cell.dialogAvatarLabel.text = String(cellModel.textLabelText.capitalized.first ?? Character("C"))
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

            tableView.deselectRow(at: indexPath, animated: true)
            let dialog = dialogs[indexPath.row]
            performSegue(withIdentifier: "SA_STR_SEGUE_GO_TO_CHAT".localized , sender: dialog.id)

    }

    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let dialog = dialogs[indexPath.row]
        if dialog.type == .publicGroup {
            return false
        }
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        let dialog = dialogs[indexPath.row]
        if editingStyle != .delete || dialog.type == .publicGroup {
            return
        }
        
        let alertController = UIAlertController(title: "SA_STR_WARNING".localized,
                                                message: "SA_STR_DO_YOU_REALLY_WANT_TO_DELETE_SELECTED_DIALOG".localized,
                                                preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "SA_STR_CANCEL".localized, style: .cancel, handler: nil)
        
        let leaveAction = UIAlertAction(title: "SA_STR_DELETE".localized, style: .default) { (action:UIAlertAction) in
            SVProgressHUD.show(withStatus: "SA_STR_DELETING".localized, maskType: .clear)
            
            guard let dialogID = dialog.id else {
                SVProgressHUD.dismiss()
                return
            }
            
            if dialog.type == .private {
                self.chatManager.deleteDialog(withID: dialogID)
            } else {
                
                let currentUser = Profile()
                guard currentUser.isFull == true, let dialogOccupantIDs = dialog.occupantIDs else {
                    return
                }
                // group
                let occupantIDs = dialogOccupantIDs.filter({ $0.intValue != currentUser.ID })
                dialog.occupantIDs = occupantIDs
                
                let message = "\(currentUser.fullName) " + "SA_STR_USER_HAS_LEFT".localized
                // Notifies occupants that user left the dialog.
                self.chatManager.sendLeaveMessage(message, to: dialog, completion: { (error) in
                    if let error = error {
                        debugPrint("[DialogsViewController] sendLeaveMessage error: \(error.localizedDescription)")
                        SVProgressHUD.dismiss()
                        return
                    }
                    self.chatManager.deleteDialog(withID: dialogID)
                })
            }
        }
        alertController.addAction(cancelAction)
        alertController.addAction(leaveAction)
        present(alertController, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "SA_STR_DELETE".localized
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SA_STR_SEGUE_GO_TO_CHAT".localized {
            if let chatVC = segue.destination as? ChatViewController {
                self.chatVC = chatVC
                chatVC.dialogID = sender as? String
            }
        }
    }
    
    // MARK: - Helpers
    private func reloadContent() {
        dialogs = chatManager.storage.dialogsSortByUpdatedAt()
        setupNavigationTitle()
        tableView.reloadData()
    }
    
    fileprivate func setupDate(_ dateSent: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        let currentYearStr = formatter.string(from: Date())
        
        let currentYearFormatter = DateFormatter()
        currentYearFormatter.dateFormat = "dd MMM"
        
        let anotherYearFormatter = DateFormatter()
        anotherYearFormatter.dateFormat = "dd.MM.yy"
        
        var dateString = ""
        
        if Calendar.current.isDateInToday(dateSent) == true {
            dateString = messageTimeDateFormatter.string(from: dateSent)
        } else if Calendar.current.isDateInYesterday(dateSent) == true {
            dateString = "Yesterday"
        } else if formatter.string(from: dateSent) == currentYearStr {
            dateString = currentYearFormatter.string(from: dateSent)
        } else {
            var anotherYearDate = anotherYearFormatter.string(from: dateSent)
            if (anotherYearDate.hasPrefix("0")) {
                anotherYearDate.remove(at: anotherYearDate.startIndex)
            }
            dateString = anotherYearDate
        }
        return dateString
    }
    
    private func setupNavigationTitle() {
        let currentUser = Profile()
        guard currentUser.isFull == true else {
            return
        }
        let title = currentUser.fullName.count > 0 ? currentUser.fullName : currentUser.login
        let numberChats = dialogs.isEmpty == false ? "\(dialogs.count) chats" : " "
        titleView.setupTitleView(title: title, subTitle: numberChats)
    }
}

// MARK: - QBChatDelegate
extension NewDialogsViewController: QBChatDelegate {
    func chatRoomDidReceive(_ message: QBChatMessage, fromDialogID dialogID: String) {
        chatManager.updateDialog(with: dialogID, with: message)
        self.chatVC?.testCompletionString = self.testCompletion!(message.text!)
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
        if let _ = chatManager.storage.dialog(withID: dialogID) {
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
    
    func chatDidDisconnectWithError(_ error: Error) {
    }
    
    func chatDidConnect() {
        if QBChat.instance.isConnected == true {
            chatManager.updateStorage()
            SVProgressHUD.showSuccess(withStatus: "SA_STR_CONNECTED".localized, maskType: .clear)
        }
    }
    
    func chatDidReconnect() {
        SVProgressHUD.show(withStatus: "SA_STR_CONNECTED".localized)
        if QBChat.instance.isConnected == true {
            chatManager.updateStorage()
            SVProgressHUD.showSuccess(withStatus: "SA_STR_CONNECTED".localized, maskType: .clear)
        }
    }
}

// MARK: - ChatManagerDelegate
extension NewDialogsViewController: ChatManagerDelegate {
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
            SVProgressHUD.show()
        }
    }
}
