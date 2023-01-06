//
//  UsersInfoViewController.swift
//  sample-chat-swift
//
//  Created by Injoit on 1/28/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import Foundation

class UsersInfoViewController: UserListViewController {
    //MARK: - Properties
    var dialogID: String! {
        didSet {
            dialog = chatManager.storage.dialog(withID: dialogID)
        }
    }
    
    private var dialog: QBChatDialog! {
        didSet {
            setupUsers(dialogID)
            // online/offline for group and public chats
            dialog.onJoinOccupant = { [weak self] userID in
                guard let self = self else {
                    return
                }
                guard let onlineUser = self.userList.fetched.filter({ $0.id == userID }).first,
                      let index = self.userList.fetched.firstIndex(of: onlineUser),
                      index != 0 else {
                          return
                      }
                self.userList.fetched.remove(at: index)
                self.userList.fetched.insert(onlineUser, at: 0)
                let indexPath = IndexPath(item: index, section: 0)
                let indexPathFirst = IndexPath(item: 0, section: 0)
                self.tableView.beginUpdates()
                self.tableView.deleteRows(at: [indexPath], with: .left)
                self.tableView.insertRows(at: [indexPathFirst], with: .left)
                self.tableView.endUpdates()
            }
        }
    }
    private var titleView = TitleView()
    private var users : [QBUUser] = []
    private let chatManager = ChatManager.instance
    private lazy var addUsersItem = UIBarButtonItem(image: UIImage(named: "add_user"),
                                                    style: .plain,
                                                    target: self,
                                                    action:#selector(didTapAddUsers(_:)))
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.titleView = titleView
        let backButtonItem = UIBarButtonItem(image: UIImage(named: "chevron"),
                                             style: .plain,
                                             target: self,
                                             action: #selector(didTapBack(_:)))
        navigationItem.leftBarButtonItem = backButtonItem
        backButtonItem.tintColor = .white
        navigationItem.rightBarButtonItem = addUsersItem
        addUsersItem.tintColor = .white
        addUsersItem.isEnabled = true
        refreshControl = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if QBChat.instance.isConnected == false {
            showNoInternetAlert(handler: nil)
            return
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateDialog),
                                               name: ChatManagerConstant.didUpdateChatDialog,
                                               object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self,
                                                  name: ChatManagerConstant.didUpdateChatDialog,
                                                  object: nil)
    }
    
    //MARK: - Actions
    @objc func didTapBack(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func didTapAddUsers(_ sender: UIBarButtonItem) {
        guard let addOccupantsVC = Screen.addOccupantsVC() else {
            return
        }
        addOccupantsVC.dialogID = dialogID
        navigationController?.pushViewController(addOccupantsVC, animated: true)
    }
    
    //MARK: - Overrides
    override func configure(_ cell: UserTableViewCell, for indexPath: IndexPath) {
        cell.checkBoxView.isHidden = true
        cell.checkBoxImageView.isHidden = true
        cell.isUserInteractionEnabled = false
    }
    
    //MARK: - Internal Methods
    private func setupUsers(_ dialogID: String) {
        userList.fetched = chatManager.storage.users(with: dialogID)
        tableView.reloadData()
        let title = dialog.name ?? "Chat"
        let numberUsers = "\(self.userList.fetched.count) members"
        titleView.setupTitleView(title: title, subTitle: numberUsers)
    }
    
    @objc private func updateDialog(notification: Notification) {
        guard let chatDialogId = notification.userInfo?[ChatManagerConstant.didUpdateChatDialogKey] as? String,
              chatDialogId == dialogID  else { return }
        setupUsers(dialogID)
    }
}
