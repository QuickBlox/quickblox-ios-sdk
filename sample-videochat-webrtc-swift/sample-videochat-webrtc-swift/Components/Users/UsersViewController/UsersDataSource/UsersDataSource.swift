//
//  UsersDataSource.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 12/10/18.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit
import Quickblox

typealias FetchUsersCompletion = (_ error: String?, _ objects: [QBUUser], _ cancel: Bool) -> Void
typealias SetUsersCompletion = () -> Void
typealias SelectUserCompletion = (_ user: QBUUser?, _ isSelect: Bool) -> Void

class UsersDataSource: NSObject {
    
    // MARK: - Properties
    var onSetDisplayedUsers: SetUsersCompletion?
    var onSearchNextUsers: SetUsersCompletion?
    var onSelectUser: SelectUserCompletion?
    var onChooseMoreUsers: SetUsersCompletion?
    
    private(set) var displayedUsers: [QBUUser] = [] {
        didSet {
            onSetDisplayedUsers?()
        }
    }
    
    private(set) var downloadedUsers: [QBUUser]  = []
    private var cancelFetch = false
    private var currentFetchPage: UInt = 1
    
    private(set) var selectedUsers: Set<QBUUser> = []
    private var searchedUsers: [QBUUser] = []
    private var cancelSearch = false
    private var currentSearchPage: UInt = 1
    private var isSearch = false


    //MARK: - Public Methods
    func user(withID ID: UInt) -> QBUUser? {
        return downloadedUsers.filter{ $0.id == ID }.first
    }

    func downloadUsers(_ searchText: String = "") {
        downloadedUsers = []
        currentFetchPage = 1
        currentSearchPage = 1
        if isSearch == false {
            fetchUsers()
            return
        }
        if searchText.count > 2 {
            searchUsers(searchText)
        }
    }
    
    func downloadUsers(withIDs usersIDs: [String], completion: @escaping FetchUsersCompletion) {
        QBRequest.users(withIDs: usersIDs, page: nil, successBlock: { [weak self] (response, page, users) in

            guard let self = self, users.isEmpty == false else {
                completion(self?.errorMessage(response: response), [], false)
                return
            }

            for user in users {
                if self.downloadedUsers.contains(user) {continue}
                self.downloadedUsers.append(user)
            }
            self.setupDispayedUsers(self.downloadedUsers)
            completion(nil, users, false)

        }, errorBlock: { (response) in
            completion(self.errorMessage(response: response), [], false)
            debugPrint("[UsersViewController] error fetch usersWithIDs")
        })
    }
    
    func removeSelectedUsers() {
        selectedUsers.removeAll()
    }
    
    func removeSelectedUser(_ userID: UInt) {
        guard let user = selectedUsers.filter({ $0.id == userID }).first else { return }
        selectedUsers.remove(user)
    }
    
    //MARK: - Internal Methods
    private func setupDispayedUsers(_ users: [QBUUser]) {
        let profile = Profile()
        var filteredUsers = users.filter({$0.id != profile.ID})
        if selectedUsers.isEmpty == false {
            var addedUsersSet = Set(users)
            for user in selectedUsers {
                if addedUsersSet.contains(user) == false {
                    filteredUsers.insert(user, at: 0)
                    addedUsersSet.insert(user)
                }
            }
        }
        let usersSet = Set(filteredUsers)
        filteredUsers = sortedUsers(Array(usersSet))
        displayedUsers = filteredUsers
    }
    
    private func sortedUsers(_ users: [QBUUser]) -> [QBUUser] {
        let sortedUsers = users.sorted(by: {
            guard let firstUpdatedAt = $0.lastRequestAt, let secondUpdatedAt = $1.lastRequestAt else {
                return false
            }
            return firstUpdatedAt > secondUpdatedAt
        })
        return sortedUsers
    }
    
    private func searchUsers(_ name: String) {
        searchUsers(name,
                    currentPage: currentSearchPage,
                    perPage: UsersConstant.perPage) { [weak self] error, users, cancel in
            guard let self = self else { return }
            self.cancelSearch = cancel
            if self.currentSearchPage == 1 {
                self.searchedUsers = []
            }
            if cancel == false {
                self.currentSearchPage += 1
            }
            let profile = Profile()
            self.searchedUsers = self.searchedUsers + users.filter({$0.id != profile.ID})
            self.searchedUsers = self.sortedUsers(self.searchedUsers)
            self.displayedUsers = self.searchedUsers
        }
    }
    
    private func searchUsers(_ name: String,  currentPage: UInt, perPage: UInt, completion: @escaping FetchUsersCompletion) {
        let page = QBGeneralResponsePage(currentPage: currentPage, perPage: perPage)
        QBRequest.users(withFullName: name, page: page,
                        successBlock: { (response, page, users) in
                            let cancel = users.count < page.perPage
                            completion(nil, users, cancel)
                        }, errorBlock: { response in
                            completion(self.errorMessage(response: response), [], false)
                            debugPrint("\(#function) error: \(self.errorMessage(response: response) ?? "")")
                        })
    }
    
    private func fetchUsers() {
        fetchUsers(currentPage: currentFetchPage,
                   perPage: UsersConstant.perPage) { [weak self] error, users, cancel in
            guard let self = self else { return }
            self.cancelFetch = cancel
            if cancel == false {
                self.currentFetchPage += 1
            }
            self.downloadedUsers.append(contentsOf: users)
            
            self.setupDispayedUsers(self.downloadedUsers)
        }
    }
    
    private func fetchUsers(currentPage: UInt, perPage: UInt, completion: @escaping FetchUsersCompletion) {
        let page = QBGeneralResponsePage(currentPage: currentPage, perPage: perPage)
        let extendedRequest: [String: String] = ["order": "desc date last_request_at"]
        QBRequest.users(withExtendedRequest: extendedRequest,
                        page: page,
                        successBlock: { (response, page, users) in
                            let cancel = users.count < page.perPage
                            completion(nil, users, cancel)
                        }, errorBlock: { response in
                            completion(self.errorMessage(response: response), [], false)
                            debugPrint("\(#function) error: \(self.errorMessage(response: response) ?? "")")
                        })
    }
    
    //Handle Error
    private func errorMessage(response: QBResponse) -> String? {
        var errorMessage : String
        if response.status.rawValue == 502 {
            errorMessage = "Bad Gateway, please try again"
        } else if response.status.rawValue == -1009 {
            errorMessage = LoginConstant.checkInternet
        } else {
            guard let qberror = response.error,
                  let error = qberror.error else { return nil }
            
            errorMessage = error.localizedDescription.replacingOccurrences(of: "(",
                                                                           with: "",
                                                                           options:.caseInsensitive,
                                                                           range: nil)
            errorMessage = errorMessage.replacingOccurrences(of: ")",
                                                             with: "",
                                                             options: .caseInsensitive,
                                                             range: nil)
        }
        return errorMessage
    }
}

//MARK: - UITableViewDataSource, UITableViewDelegate
extension UsersDataSource: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if displayedUsers.count == 0, isSearch == true {
            tableView.setupEmptyView("No user with that name")
        } else {
            tableView.removeEmptyView()
        }
        return displayedUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UserCellConstant.reuseIdentifier,
                                                       for: indexPath) as? UserTableViewCell else {
            return UITableViewCell()
        }
        let user = self.displayedUsers[indexPath.row]
        cell.userColor = user.id.generateColor()
        cell.userNameLabel.text = user.fullName ?? user.login
        cell.userAvatarLabel.text = String(user.fullName?.capitalized.first ?? Character("U"))
        cell.tag = indexPath.row
        
        let lastItemNumber = displayedUsers.count - 1
        if indexPath.row == lastItemNumber {
            if isSearch == true, cancelSearch == false {
                onSearchNextUsers?()
            } else if isSearch == false, cancelFetch == false {
                fetchUsers()
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedUsers.count > 2 {
            tableView.deselectRow(at: indexPath, animated: false)
            onChooseMoreUsers?()
            return
        }
        let user = displayedUsers[indexPath.row]
        selectedUsers.insert(user)
        onSelectUser?(user, true)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let user = displayedUsers[indexPath.row]
        if selectedUsers.contains(user) == false { return }
        selectedUsers.remove(user)
        onSelectUser?(user, false)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let user = self.displayedUsers[indexPath.row]
        if selectedUsers.contains(user) {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            return
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }
}

// MARK: - UISearchBarDelegate
extension UsersDataSource: SearchBarViewDelegate {
    func searchBarView(_ searchBarView: SearchBarView, didChangeSearchText searchText: String) {
        if searchText.count > 2 {
            isSearch = true
            currentSearchPage = 1
            cancelSearch = false
            searchUsers(searchText)
        }
        if searchText.count == 0 {
            isSearch = false
            cancelSearch = false
            setupDispayedUsers(downloadedUsers)
        }
    }
    
    func searchBarView(_ searchBarView: SearchBarView, didCancelSearchButtonTapped sender: UIButton) {
        isSearch = false
        cancelSearch = false
        downloadUsers()
    }
}
