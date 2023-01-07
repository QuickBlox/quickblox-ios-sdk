//
//  UserListViewController.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 28.12.2021.
//  Copyright © 2021 QuickBlox. All rights reserved.
//

import UIKit
import Quickblox

typealias SelectUserCompletion = ( _ user: QBUUser, _ isSelected: Bool) -> Void
typealias FetchedUsersCompletion = ( _ users: [QBUUser]) -> Void

class UserListViewController: UITableViewController {
    //MARK: - Properties
    var userList = UserList()
    var onSelectUser: SelectUserCompletion?
    var onFetchedUsers: FetchedUsersCompletion?
    private var isProcessing = false

    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: UserCellConstant.reuseIdentifier, bundle: nil),
                           forCellReuseIdentifier: UserCellConstant.reuseIdentifier)
        tableView.allowsMultipleSelection = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchUsers()
    }
    
    //MARK - Setup
    func fetchUsers() {
        if isProcessing == true {
            return
        }
        isProcessing = true
        refreshControl?.beginRefreshing()
        userList.fetchWithPage(1) { [weak self] (users, error) in
            guard let self = self, let users = users else {
                self?.refreshControl?.endRefreshing()
                self?.isProcessing = false
                return
            }
            if users.isEmpty == false {
                self.onFetchedUsers?(users)
            }
            self.refreshControl?.endRefreshing()
            self.tableView.reloadData()
            self.isProcessing = false
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
    @IBAction func refreshUsers(_ sender: UIRefreshControl) {
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
        cell.userNameLabel.text = user.fullName ?? user.login
        cell.userAvatarLabel.text = String(user.fullName?.capitalized.first ?? Character("U"))
        cell.tag = indexPath.row
        
        let lastItemNumber = userList.fetched.count - 1
        if indexPath.row == lastItemNumber, userList.isLoadAll == false {
            fetchNext()
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = userList.fetched[indexPath.row]
        if userList.selected.count > 2 {
            tableView.deselectRow(at: indexPath, animated: false)
            onSelectUser?(user, true)
            return
        }
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
