//
//  UsersInfoTableViewController.swift
//  sample-chat-swift
//
//  Created by Injoit on 1/28/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import Foundation

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
    private var dialog: QBChatDialog!
    var users : [QBUUser] = []
    let chatManager = ChatManager.instance
    private lazy var addUsersItem = UIBarButtonItem(title: "Add occupants",
                                                    style: .plain,
                                                    target: self,
                                                    action:#selector(didTapAddUsers(_:)))
    //MARK: - Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let occupantIDs = dialog.occupantIDs  else {
                return
        }
        chatManager.delegate = self
        let  profile = Profile()
        if profile.isFull == true {
            navigationItem.title = profile.fullName
        }
        setupUsers(dialogID)
        
        navigationItem.rightBarButtonItem = addUsersItem
        if occupantIDs.count >= chatManager.storage.users.count {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    //MARK: - Actions
    @objc private func didTapAddUsers(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "SA_STR_SEGUE_GO_TO_ADD_OPPONENTS".localized, sender: nil)
    }
    
    //MARK: - Internal Methods
    private func updateUsers() {
        guard let occupantIDs = dialog.occupantIDs  else {
            return
        }
        if occupantIDs.count >= chatManager.storage.users.count {
            navigationItem.rightBarButtonItem?.isEnabled = false
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
        if occupantIDs.isEmpty == false {
            setupUsers(dialogID)
        }
    }
    
    private func setupUsers(_ dialogID: String) {
        self.users = chatManager.storage.users(with: dialogID)
        tableView.reloadData()
    }
    
    //MARK: - Overrides
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SA_STR_SEGUE_GO_TO_ADD_OPPONENTS".localized {
            guard let addOccupantsVC = segue.destination as? AddOccupantsController else {
                return
            }
            addOccupantsVC.dialogID = dialogID
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
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SA_STR_CELL_USER".localized, for: indexPath) as? UserTableViewCell else {
            return UITableViewCell()
        }
        let user = users[indexPath.row]
        cell.setupColorMarker(chatManager.color(indexPath.row))
        cell.userDescription = user.fullName
        cell.tag = indexPath.row
        return cell
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
}

// MARK: - ChatManagerDelegate
extension UsersInfoTableViewController: ChatManagerDelegate {
    func chatManagerWillUpdateStorage(_ chatManager: ChatManager) {
        SVProgressHUD.show(withStatus: "SA_STR_LOADING_USERS".localized, maskType: .clear)
    }
    
    func chatManager(_ chatManager: ChatManager, didFailUpdateStorage message: String) {
        SVProgressHUD.showError(withStatus: message)
    }
    
    func chatManager(_ chatManager: ChatManager, didUpdateChatDialog chatDialog: QBChatDialog) {
        if chatDialog.id == dialogID {
            updateUsers()
        }
        SVProgressHUD.dismiss()
    }
    
    func chatManager(_ chatManager: ChatManager, didUpdateStorage message: String) {
        SVProgressHUD.showSuccess(withStatus: message)
        
        guard let dialogID = dialogID else {
            return
        }
        setupUsers(dialogID)
    }
}
