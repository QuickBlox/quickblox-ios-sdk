//
//  CreateNewDialogViewController.swift
//  sample-chat-swift
//
//  Created by Injoit on 10/4/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit

enum DialogAction {
    case create
    case add
    case createPlaceholder
}

struct CreateNewDialogConstant {
    static let perPage:UInt = 100
    static let newChat = "New Chat"
}

class CreateNewDialogViewController: UIViewController {
    //MARK: - IBOutlets
    @IBOutlet weak var searchBarView: SearchBarView!
    @IBOutlet weak var containerView: UIView!
    
    //MARK: - Views
    private var titleView = TitleView()
    
    //MARK: - Properties
    private var users = Users()
    private let chatManager = ChatManager.instance

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

        let createButtonItem = UIBarButtonItem(title: "Create",
                                               style: .plain,
                                               target: self,
                                               action: #selector(createChatButtonPressed(_:)))
        navigationItem.rightBarButtonItem = createButtonItem
        createButtonItem.tintColor = .white
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        let backButtonItem = UIBarButtonItem(image: UIImage(named: "chevron"),
                                             style: .plain,
                                             target: self,
                                             action: #selector(didTapBack(_:)))
        navigationItem.leftBarButtonItem = backButtonItem
        backButtonItem.tintColor = .white
        guard let fetchUsersViewController = Screen.userListViewController(nonDisplayedUsers: [Profile().ID]) else {
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
    }
    
    //MARK: - UI Configuration
    private func showFetchScreen() {
        guard let fetchUsersViewController = Screen.userListViewController(nonDisplayedUsers: [Profile().ID]) else {
            return
        }
        changeCurrentViewController(fetchUsersViewController)
    }

    private func showSearchScreen(withSearchText searchText: String) {
        guard let searchUsersViewController = Screen.searchUsersViewController(nonDisplayedUsers: [Profile().ID], searchText: searchText) else {
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
        titleView.setupTitleView(title: CreateNewDialogConstant.newChat, subTitle: numberUsers)
    }
    
    private func checkCreateChatButtonState() {
        navigationItem.rightBarButtonItem?.isEnabled = users.selected.isEmpty == true ? false : true
    }
    
    //MARK: - Actions
    @objc func didTapBack(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func createChatButtonPressed(_ sender: UIBarButtonItem) {
        if QBChat.instance.isConnected == false {
            showNoInternetAlert(handler: nil)
            return
        }
        let selectedUsers = Array(users.selected)
        let isPrivate = selectedUsers.count == 1
        if isPrivate {
            // Creating private chat.
            chatManager.storage.update(users: selectedUsers)
            guard let user = selectedUsers.first else {
                return
            }
            chatManager.createPrivateDialog(withOpponent: user, completion: { [weak self] (error, dialog) in
                guard let self = self else {return}
                guard let dialog = dialog,
                      let dialogID = dialog.id else {
                    return
                }
                
                guard let navigationController = self.navigationController else {
                    return
                }
                let controllers = navigationController.viewControllers
                var newStack = [UIViewController]()
                
                //change stack by replacing view controllers after ChatVC with ChatVC
                controllers.forEach {
                    newStack.append($0)
                    if $0 is DialogsViewController {
                        guard let chatController = Screen.chatViewController() else {
                            return
                        }
                        chatController.dialogID = dialogID
                        newStack.append(chatController)
                        navigationController.setViewControllers(newStack, animated: true)
                        return
                    }
                }
            })
        } else {
            self.performSegue(withIdentifier: "enterChatName", sender: nil)
        }
    }
    
    //MARK: - Overrides
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "enterChatName" {
            if let chatNameVC = segue.destination as? EnterChatNameVC {
                let selectedUsers = Array(users.selected)
                chatNameVC.selectedUsers = selectedUsers
            }
        }
    }
}

// MARK: - SearchBarViewDelegate
extension CreateNewDialogViewController: SearchBarViewDelegate {
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
