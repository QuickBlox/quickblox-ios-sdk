//
//  DialogsSelectionVC.swift
//  sample-conference-videochat-swift
//
//  Created by Injoit on 10/11/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit
import Quickblox
import SVProgressHUD

struct DialogsSelectionConstant {
    static let forwarded = "Message forwarded"
}

class DialogsSelectionViewController: BaseDialogsViewController {
    
    //MARK: - Properties
    private var selectedPaths = Set<IndexPath>()
    private var titleView = TitleView()
    var message: QBChatMessage?
    internal var senderID: UInt = 0
    
    override func setupNavigationBar() {
        guard currentUser.isFull == true else {
            return
        }
        senderID = currentUser.ID
        navigationItem.titleView = titleView
        
        let backButtonItem = UIBarButtonItem(image: UIImage(named: "chevron"),
                                             style: .plain,
                                             target: self,
                                             action: #selector(didTapBack(_:)))
        navigationItem.leftBarButtonItem = backButtonItem
        backButtonItem.tintColor = .white
        
        let deleteButtonItem = UIBarButtonItem(title: "Delete",
                                               style: .plain,
                                               target: self,
                                               action: #selector(didTapDelete(_:)))
        navigationItem.rightBarButtonItem = deleteButtonItem
        deleteButtonItem.tintColor = .white
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    override func setupNavigationTitle() {
        var chats = "chats"
        if selectedPaths.count == 1 {
            chats = "chat"
        }
        let numberChats = "\(selectedPaths.count) \(chats) selected"
        titleView.setupTitleView(title: DialogsConstant.deleteChats, subTitle: numberChats)
    }
    
    override func setupDialogs() {
        chatManager.delegate = self
    }
    
    //MARK: - Actions
    private func checkNavRightBarButtonEnabled() {
        navigationItem.rightBarButtonItem?.isEnabled = selectedPaths.isEmpty == true ? false : true
    }
    
    @objc func didTapDelete(_ sender: UIBarButtonItem) {
        let baseAlertMessage = "Do you really want to leave selected dialog"
        let alertMessage = self.selectedPaths.count == 1 ? baseAlertMessage + "?" : baseAlertMessage + "s?"
        let alertController = UIAlertController(title: "Warning",
                                                message: alertMessage,
                                                preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let leaveAction = UIAlertAction(title: "Leave", style: .default) { (action:UIAlertAction) in
            sender.isEnabled = false
            
            let deleteGroup = DispatchGroup()

            for indexPath in self.selectedPaths {
                let dialog = self.dialogs[indexPath.row]
                
                guard let dialogID = dialog.id else {
                    SVProgressHUD.dismiss()
                    return
                }
                
                SVProgressHUD.show(withStatus: "Leaving...")
                
                if dialog.type == .private {
                    deleteGroup.enter()
                    self.chatManager.leaveDialog(withID: dialogID) { error in
                        if error == nil {
                            self.selectedPaths.remove(indexPath)
                        }
                        SVProgressHUD.dismiss()
                        deleteGroup.leave()
                    }
                } else if dialog.type == .publicGroup {
                    SVProgressHUD.dismiss()
                    continue
                } else {
                    // group
                    deleteGroup.enter()
                    dialog.pullOccupantsIDs = [(NSNumber(value: self.currentUser.ID)).stringValue]
                    
                    let message = "\(self.currentUser.fullName) " + "has left"
                    // Notifies occupants that user left the dialog.
                    self.chatManager.sendLeaveMessage(message, to: dialog, completion: { (error) in
                        if let error = error {
                            SVProgressHUD.dismiss()
                            debugPrint("[DialogsViewController] sendLeaveMessage error: \(error)")
                            deleteGroup.leave()
                            
                        } else {
                            self.chatManager.leaveDialog(withID: dialogID) { error in
                                if error == nil {
                                    self.selectedPaths.remove(indexPath)
                                }
                                deleteGroup.leave()
                                SVProgressHUD.dismiss()
                            }
                        }
                    })
                }
            }
            deleteGroup.notify(queue: DispatchQueue.main) {
                self.dismiss(animated: false, completion: nil)
            }
        }
        alertController.addAction(cancelAction)
        alertController.addAction(leaveAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func didTapBack(_ sender: UIBarButtonItem) {
        dismiss(animated: false, completion: nil)
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
        
        tableView.allowsMultipleSelection = true
        cell.checkBoxView.isHidden = false
        cell.unreadMessageCounterLabel.isHidden = true
        cell.unreadMessageCounterHolder.isHidden = true
        cell.lastMessageDateLabel.isHidden = true
        
        if self.selectedPaths.contains(indexPath) {
            cell.contentView.backgroundColor = UIColor(red:0.85, green:0.89, blue:0.97, alpha:1)
            cell.checkBoxImageView.isHidden = false
            cell.checkBoxView.setRoundBorderEdgeColorView(cornerRadius: 4.0,
                                                          borderWidth: 0.0,
                                                          color: UIColor(red:0.22, green:0.47, blue:0.99, alpha:1),
                                                          borderColor: UIColor(red:0.22, green:0.47, blue:0.99, alpha:1))
        } else {
            cell.contentView.backgroundColor = .clear
            cell.checkBoxView.backgroundColor = .clear
            cell.checkBoxView.setRoundBorderEdgeColorView(cornerRadius: 4.0,
                                                          borderWidth: 1.0,
                                                          borderColor: UIColor(red:0.42, green:0.48, blue:0.57, alpha:1))
            cell.checkBoxImageView.isHidden = true
        }
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        handleSelectRowAtIndexPath(indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        handleSelectRowAtIndexPath(indexPath)
    }
    
    private func handleSelectRowAtIndexPath(_ indexPath: IndexPath) {
        let dialog = dialogs[indexPath.row]
        if dialog.type == .publicGroup {
            DispatchQueue.main.async {
                let alertController = UIAlertController(title: "You cannot leave \(dialog.name ?? "Public chat")".localized,
                                                        message: nil,
                                                        preferredStyle: .alert)
                
                let cancelAction = UIAlertAction(title: "SA_STR_CANCEL".localized, style: .cancel, handler: nil)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
            }
        } else {
            if selectedPaths.contains(indexPath) {
                selectedPaths.remove(indexPath)
            } else {
                selectedPaths.insert(indexPath)
            }
            checkNavRightBarButtonEnabled()
            setupNavigationTitle()
            tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let dialog = dialogs[indexPath.row]
        if  dialog.type == .publicGroup {
            return false
        }
        return true
    }
    
    // MARK: - Helpers
    override func reloadContent() {
        dialogs = chatManager.storage.dialogsSortByUpdatedAt()
        setupNavigationTitle()
        tableView.reloadData()
    }
}

// MARK: - ChatManagerDelegate
extension DialogsSelectionViewController: ChatManagerDelegate {
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
    }
    
    func chatManagerWillUpdateStorage(_ chatManager: ChatManager) {
    }
}
