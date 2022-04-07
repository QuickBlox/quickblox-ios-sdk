//
//  UserListViewController.swift
//  sample-chat-swift
//
//  Created by Injoit on 28.12.2021.
//  Copyright © 2021 QuickBlox. All rights reserved.
//

import UIKit
import Quickblox

struct UsersConstant {
    static let perPage:UInt = 100
    static let searchPerPage:UInt = 10
    static let noUsers = "No user with that name"
}

typealias SelectUserCompletion = ( _ user: QBUUser, _ isSelected: Bool) -> Void
typealias FetchedUsersCompletion = ( _ users: [QBUUser]) -> Void

class UserListViewController: UITableViewController {
    //MARK: - Properties
    var action: ChatAction? = nil
    var currentUser = Profile()
    var userList = UserList(nonDisplayedUsers: [])
    var onSelectUser: SelectUserCompletion?
    var onFetchedUsers: FetchedUsersCompletion?
    
    //MARK: - Life Cycle
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, nonDisplayedUsers: [UInt] = []) {
        self.userList = UserList(nonDisplayedUsers: nonDisplayedUsers)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: UserCellConstant.reuseIdentifier, bundle: nil),
                           forCellReuseIdentifier: UserCellConstant.reuseIdentifier)
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(red: 244/255, green: 246/255, blue: 249/255, alpha: 1.0)
        tableView.allowsMultipleSelection = true
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(self.refreshUsers(_:)), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if action != nil {
            return
        }
        fetchUsers()
    }
    
    //MARK - Setup
    func fetchUsers() {
        refreshControl?.beginRefreshing()
        userList.fetchWithPage(1) { [weak self] (users, error) in
            guard let self = self, let users = users else {
                self?.refreshControl?.endRefreshing()
                return
            }
            if users.isEmpty == false {
                self.onFetchedUsers?(users)
            }
            self.refreshControl?.endRefreshing()
            self.tableView.reloadData()
        }
    }
    
    func fetchNext() {
        userList.fetchNext { [weak self] (users, error) in
            guard let self = self, let users = users else {
                return
            }
            if users.isEmpty == false {
                self.onFetchedUsers?(users)
            }
            self.tableView.reloadData()
        }
    }

    //MARK: - Actions
    @objc func refreshUsers(_ sender: UIRefreshControl) {
        fetchUsers()
    }
    
    //MARK: - Public Methods
    func setupSelectedUsers(_ users: [QBUUser]) {
        userList.append(users)
        for user in users {
            userList.selected.insert(user.id)
        }
    }
    
    func removeSelectedUsers() {
        guard let indexPathsForSelectedRows = tableView.indexPathsForSelectedRows else {
            return
        }
        for indexPathForSelectedRow in indexPathsForSelectedRows {
            tableView.deselectRow(at: indexPathForSelectedRow, animated: false)
        }
        userList.selected.removeAll()
    }
    
    func removeSelectedUser(_ user: QBUUser) {
        if let index = userList.fetched.firstIndex(of: user)  {
            let indexPath = IndexPath(row: index, section: 0)
            tableView.deselectRow(at: indexPath, animated: false)
        }
        userList.selected.remove(user.id)
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userList.fetched.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UserCellConstant.reuseIdentifier,
                                                       for: indexPath) as? UserTableViewCell else {
            return UITableViewCell()
        }
        let user = userList.fetched[indexPath.row]
        cell.userColor = user.id.generateColor()
        let userName = user.fullName ?? user.login ?? "QB user"
        cell.userNameLabel.text = currentUser.ID == user.id ? userName + " (You)" : userName
        cell.userAvatarLabel.text = String(userName.capitalized.first ?? Character("U"))
        cell.tag = indexPath.row
        
        configure(cell, for: indexPath)
        
        return cell
    }
    
    func configure(_ cell: UserTableViewCell, for indexPath: IndexPath) {
        // Can be overridden in a child class.
        let lastItemNumber = userList.fetched.count - 1
        if action == nil, indexPath.row == lastItemNumber, userList.isLoadAll == false {
            fetchNext()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = userList.fetched[indexPath.row]
        userList.selected.insert(user.id)
        onSelectUser?(user, true)
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let user = userList.fetched[indexPath.row]
        if userList.selected.contains(user.id) == false {
            return
        }
        userList.selected.remove(user.id)
        onSelectUser?(user, false)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let user = self.userList.fetched[indexPath.row]
        if userList.selected.contains(user.id) {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            return
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }
}

//MARK: - QBChatDelegate
extension UserListViewController: QBChatDelegate {
    func chatDidConnect() {
        fetchUsers()
    }
    
    func chatDidReconnect() {
        fetchUsers()
    }
}
