//
//  AddOccupantsVC.swift
//  sample-chat-swift
//
//  Created by Injoit on 10/9/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit

struct AddOccupantsConstant {
    static let perPage:UInt = 100
    static let addOccupants = "Add Occupants"
}

class AddOccupantsVC: UIViewController {
    //MARK: - IBOutlets
    @IBOutlet weak var searchBarView: SearchBarView!
    @IBOutlet weak var containerView: UIView!
    
    //MARK: - Views
    private var titleView = TitleView()
    
    //MARK: - Properties
    private var users = Users()
    private let chatManager = ChatManager.instance

    var dialogID: String! {
        didSet {
            self.dialog = chatManager.storage.dialog(withID: dialogID)
        }
    }
    private var dialog: QBChatDialog!
    
    private var current: UserListViewController! {
        didSet {
            QBChat.instance.addDelegate(current)
            current.setupSelectedUsers(Array(users.selected))
            current.onSelectUser = { [weak self] (user, isSelected) in
                guard let self = self else {
                    return
                }
                if isSelected == false {
                    self.users.selected.remove(user)
                } else {
                    self.users.selected.insert(user)
                }
                self.setupNavigationTitle()
                self.checkCreateChatButtonState()
            }
            current.onFetchedUsers = { [weak self] (users) in
                let profile = Profile()
                for user in users {
                    if user.id == profile.ID {
                        continue
                    }
                    self?.users.users[user.id] = user
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.titleView = titleView
        setupNavigationTitle()
        searchBarView.delegate = self

        let createButtonItem = UIBarButtonItem(title: "Done",
                                               style: .plain,
                                               target: self,
                                               action: #selector(addUsersButtonPressed(_:)))
        navigationItem.rightBarButtonItem = createButtonItem
        createButtonItem.tintColor = .white
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        let backButtonItem = UIBarButtonItem(image: UIImage(named: "chevron"),
                                             style: .plain,
                                             target: self,
                                             action: #selector(didTapBack(_:)))
        navigationItem.leftBarButtonItem = backButtonItem
        backButtonItem.tintColor = .white
        guard let occupantIDs = dialog.occupantIDs, let fetchUsersViewController = Screen.userListViewController(nonDisplayedUsers: occupantIDs.map({ $0.uintValue}))  else {
            return
        }
        current = fetchUsersViewController
        changeCurrentViewController(fetchUsersViewController)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
    
    //MARK: - UI Configuration
    private func showFetchScreen() {
        guard let occupantIDs = dialog.occupantIDs, let fetchUsersViewController = Screen.userListViewController(nonDisplayedUsers: occupantIDs.map({ $0.uintValue})) else {
            return
        }
        changeCurrentViewController(fetchUsersViewController)
    }

    private func showSearchScreen(withSearchText searchText: String) {
            guard let occupantIDs = dialog.occupantIDs, let searchUsersViewController = Screen.searchUsersViewController(nonDisplayedUsers: occupantIDs.map({ $0.uintValue}), searchText: searchText) else {
            return
        }
        changeCurrentViewController(searchUsersViewController)
    }
    
    private func changeCurrentViewController(_ newCurrentViewController: UserListViewController) {
        addChild(newCurrentViewController)
        newCurrentViewController.view.frame = containerView.bounds
        containerView.addSubview(newCurrentViewController.view)
        newCurrentViewController.didMove(toParent: self)
        if current == newCurrentViewController {
            return
        }
        current.willMove(toParent: nil)
        current.view.removeFromSuperview()
        current.removeFromParent()
        current = newCurrentViewController
    }
    
    //MARK: - Internal Methods
    private func setupNavigationTitle() {
        let users = users.selected.count == 1 ? "user" : "users"
        let numberUsers = "\(self.users.selected.count) \(users) selected"
        titleView.setupTitleView(title: AddOccupantsConstant.addOccupants, subTitle: numberUsers)
    }
    
    private func checkCreateChatButtonState() {
        navigationItem.rightBarButtonItem?.isEnabled = users.selected.isEmpty == true ? false : true
    }
    
    @objc private func updateDialog(notification: Notification) {
        guard let chatDialogId = notification.userInfo?[ChatManagerConstant.didUpdateChatDialogKey] as? String,
              chatDialogId == dialogID,
              let chatDialog = chatManager.storage.dialog(withID: dialogID),
              let occupantIDs = chatDialog.occupantIDs else {
            return
        }
        dialog = chatDialog
        current.userList.nonDisplayedUsers = occupantIDs.map({ $0.uintValue})
    }
    
    //MARK: - Actions
    @objc func didTapBack(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func addUsersButtonPressed(_ sender: UIBarButtonItem) {
        if QBChat.instance.isConnected == false {
            showNoInternetAlert(handler: nil)
            return
        }
        sender.isEnabled = false
        let selectedUsers = Array(users.selected)
        
        if dialog.type != .group {
            return
        }
        chatManager.storage.update(users: selectedUsers)
        let newUsersIDs = selectedUsers.map{ NSNumber(value: $0.id) }
        // Updates dialog with new occupants.
        chatManager.joinOccupants(withIDs: newUsersIDs, to: dialog) { [weak self] (response, updatedDialog) -> Void in
            guard let self = self,
                  updatedDialog != nil else {
                      sender.isEnabled = true
                      return
                  }
            guard let navigationController = self.navigationController else {
                return
            }
            let controllers = navigationController.viewControllers
            var newStack = [UIViewController]()
            // Move to Chat View Controller animated
            controllers.forEach{
                newStack.append($0)
                if $0 is ChatViewController {
                    navigationController.setViewControllers(newStack, animated: true)
                    return
                }
            }
        }
    }
}

// MARK: - SearchBarViewDelegate
extension AddOccupantsVC: SearchBarViewDelegate {
    func searchBarView(_ searchBarView: SearchBarView, didChangeSearchText searchText: String) {
        if let searchUsersViewController = current as? SearchUsersViewController {
            searchUsersViewController.searchText = searchText
        } else {
            if searchText.count > 2 {
               showSearchScreen(withSearchText: searchText)
            }
        }
    }
    
    func searchBarView(_ searchBarView: SearchBarView, didCancelSearchButtonTapped sender: UIButton) {
        showFetchScreen()
    }
}
