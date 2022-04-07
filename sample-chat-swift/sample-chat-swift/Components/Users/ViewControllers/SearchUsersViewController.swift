//
//  SearchUsersViewController.swift
//  sample-chat-swift
//
//  Created by Injoit on 28.12.2021.
//  Copyright © 2021 QuickBlox. All rights reserved.
//

import UIKit
import Quickblox

class SearchUsersViewController: UserListViewController {
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, nonDisplayedUsers: [UInt], searchText: String) {
        self.searchText = searchText
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil, nonDisplayedUsers: nonDisplayedUsers)
    }
    required init?(coder: NSCoder) {
        fatalError("You must create this view controller with a user.")
    }
    
    //MARK: - Properties
    var searchText: String = "" {
        didSet {
            if searchText.count > 2 {
                searchUsers(searchText)
            }
        }
    }
    
    //MARK: - Public Methods
    override func fetchUsers() {
        searchUsers(searchText)
    }

    override func fetchNext() {
        userList.searchNext(searchText) { [weak self] (users, error) in
            guard let self = self, let users = users else {
                return
            }
            if users.isEmpty == false {
                self.onFetchedUsers?(users)
            }
            self.tableView.reloadData()
        }
    }

    //MARK: - Private Methods
    private func searchUsers(_ name: String) {
        refreshControl?.beginRefreshing()
        userList.search(name, pageNumber: 1) { [weak self] (users, error) in
            guard let self = self, let users = users else {
                self?.refreshControl?.endRefreshing()
                return
            }
            if users.isEmpty == true, let error = error, error._code == QBResponseStatusCode.notFound.rawValue {
                self.userList.fetched.removeAll()
                self.tableView.setupEmptyView(UsersConstant.noUsers)
            } else {
                self.onFetchedUsers?(users)
                self.tableView.removeEmptyView()
            }
            self.refreshControl?.endRefreshing()
            self.tableView.reloadData()
        }
    }
}

extension UserList {
    func search(_ name: String, pageNumber: UInt, completion: DownloadUsersCompletion?) {
        let page = QBGeneralResponsePage(currentPage: pageNumber, perPage: UsersConstant.searchPerPage)
        QBRequest.users(withFullName: name, page: page,
                        successBlock: { [weak self] (response, page, users) in
            guard let self = self else {
                return
            }
            self.isLoadAll = users.count < page.perPage
            self.currentPage = pageNumber
            self.append(users)
            completion?(users, nil)
        }, errorBlock: { [weak self] (response) in
            if let error = response.error?.error, error._code == QBResponseStatusCode.notFound.rawValue {
                self?.isLoadAll = true
            }
            completion?([], response.error?.error)
        })
    }
    
    func searchNext(_ name: String, completion: DownloadUsersCompletion?) {
        let nextPage = currentPage + 1
        search(name, pageNumber: nextPage) { users, error in
            completion?(users, error);
        }
    }
}
