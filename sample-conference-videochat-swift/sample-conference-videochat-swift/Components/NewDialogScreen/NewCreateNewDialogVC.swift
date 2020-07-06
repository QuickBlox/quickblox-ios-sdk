//
//  NewCreateNewDialogVC.swift
//  sample-conference-videochat-swift
//
//  Created by Injoit on 10/4/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit
import Quickblox
import SVProgressHUD

enum DialogAction {
    case create
    case add
    case createPlaceholder
}

struct CreateNewDialogConstant {
    static let perPage:UInt = 100
    static let newChat = "New Chat"
    static let noUsers = "No user with that name"
}

class NewCreateNewDialogVC: UIViewController {
    
    @IBOutlet weak var cancelSearchButton: UIButton!
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    private var titleView = TitleView()
    //MARK: - Properties
    private var users : [QBUUser] = []
    private var downloadedUsers : [QBUUser] = []
    private var selectedUsers: Set<QBUUser> = []
    private var foundedUsers : [QBUUser] = []
    private let chatManager = ChatManager.instance
    private var cancel = false
    private var cancelFetch = false
    private var currentFetchPage: UInt = 1
    private var currentSearchPage: UInt = 1
    private var isSearch = false
    private var searchText = ""
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.titleView = titleView
        setupNavigationTitle()

        checkCreateChatButtonState()
        
        tableView.register(UINib(nibName: UserCellConstant.reuseIdentifier, bundle: nil), forCellReuseIdentifier: UserCellConstant.reuseIdentifier)
        
        tableView.keyboardDismissMode = .onDrag
        
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupViews()
        
        //MARK: - Reachability
        let updateConnectionStatus: ((_ status: NetworkConnectionStatus) -> Void)? = { [weak self] status in
            let notConnection = status == .notConnection
            if notConnection == true {
                self?.showAlertView(LoginConstant.checkInternet, message: LoginConstant.checkInternetMessage)
            }
            if notConnection == false {
                if self?.isSearch == false {
                    self?.fetchUsers()
                    
                } else {
                    if let searchText = self?.searchText, searchText.count > 2 {
                        self?.searchUsers(searchText)
                    }
                }
            }
        }
        Reachability.instance.networkStatusBlock = { status in
            updateConnectionStatus?(status)
        }
        updateConnectionStatus?(Reachability.instance.networkConnectionStatus())
    }
    
    //MARK: - Internal Methods
     private func setupViews() {
           let iconSearch = UIImageView(image: UIImage(named: "search"))
           iconSearch.frame = CGRect(x: 0, y: 0, width: 28.0, height: 28.0)
           iconSearch.contentMode = .center
           searchBar.setRoundBorderEdgeColorView(cornerRadius: 0.0, borderWidth: 1.0, borderColor: .white)
           
           if let searchTextField = searchBar.value(forKey: "searchField") as? UITextField {
               if let systemPlaceholderLabel = searchTextField.value(forKey: "placeholderLabel") as? UILabel {
                   searchBar.placeholder = " "

                   // Create custom placeholder label
                   let placeholderLabel = UILabel(frame: .zero)

                   placeholderLabel.text = "Search"
                   placeholderLabel.font = .systemFont(ofSize: 15.0, weight: .regular)
                   placeholderLabel.textColor = #colorLiteral(red: 0.4255777597, green: 0.476770997, blue: 0.5723374486, alpha: 1)

                   systemPlaceholderLabel.addSubview(placeholderLabel)

                   placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
                   placeholderLabel.leadingAnchor.constraint(equalTo: systemPlaceholderLabel.leadingAnchor).isActive = true
                   placeholderLabel.topAnchor.constraint(equalTo: systemPlaceholderLabel.topAnchor).isActive = true
                   placeholderLabel.bottomAnchor.constraint(equalTo: systemPlaceholderLabel.bottomAnchor).isActive = true
                   
                   placeholderLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
               }
               
               searchTextField.leftView = iconSearch
               searchTextField.backgroundColor = .white
               searchTextField.clearButtonMode = .never
           }
           searchBar.showsCancelButton = false
           cancelSearchButton.isHidden = true
       }
    
    private func setupNavigationTitle() {
        let title = CreateNewDialogConstant.newChat
        var users = "users"
        if selectedUsers.count == 1 {
            users = "user"
        }
        let numberUsers = "\(selectedUsers.count) \(users) selected"
        titleView.setupTitleView(title: title, subTitle: numberUsers)
    }
    
    private func setupUsers(_ users: [QBUUser]) {
        var filteredUsers: [QBUUser] = []
        let currentUser = Profile()
        if currentUser.isFull == true {
            filteredUsers = users.filter({$0.id != currentUser.ID})
        }
        
        self.users = filteredUsers
        if selectedUsers.isEmpty == false {
            var usersSet = Set(users)
            for user in selectedUsers {
                if usersSet.contains(user) == false {
                    self.users.insert(user, at: 0)
                    usersSet.insert(user)
                }
            }
        }
        tableView.reloadData()
        checkCreateChatButtonState()
    }
    
    private func addFoundUsers(_ users: [QBUUser]) {
        foundedUsers = foundedUsers + users
        var filteredUsers: [QBUUser] = []
        let currentUser = Profile()
        if currentUser.isFull == true {
            filteredUsers = foundedUsers.filter({$0.id != currentUser.ID})
        }
        self.users = filteredUsers
        tableView.reloadData()
        checkCreateChatButtonState()
    }
    
    private func checkCreateChatButtonState() {
        navigationItem.rightBarButtonItem?.isEnabled = selectedUsers.isEmpty == true ? false : true
    }
    
    //MARK: - Actions
    @IBAction func cancelSearchButtonTapped(_ sender: UIButton) {
        cancelSearchButton.isHidden = true
        searchBar.text = ""
        searchBar.resignFirstResponder()
        isSearch = false
        cancel = false
        setupUsers(downloadedUsers)
    }
    
    @objc func didTapBack(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func createChatButtonPressed(_ sender: UIBarButtonItem) {
        if Reachability.instance.networkConnectionStatus() == .notConnection {
            showAlertView(LoginConstant.checkInternet, message: LoginConstant.checkInternetMessage)
            SVProgressHUD.dismiss()
            return
        }
        
        cancelSearchButton.isHidden = true
        searchBar.text = ""
        searchBar.resignFirstResponder()
        isSearch = false
        self.performSegue(withIdentifier: "enterChatName", sender: nil)
    }
    
    //MARK: - Overrides
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "enterChatName" {
            if let chatNameVC = segue.destination as? EnterChatNameVC {
                let selectedUsers = Array(self.selectedUsers)
                chatNameVC.selectedUsers = selectedUsers
            }
        }
    }
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension NewCreateNewDialogVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if users.count == 0, isSearch == true {
            tableView.setupEmptyView("No user with that name")
        } else {
            tableView.removeEmptyView()
        }
        return users.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UserCellConstant.reuseIdentifier,
                                                       for: indexPath) as? UserTableViewCell else {
                                                        return UITableViewCell()
        }
        let user = self.users[indexPath.row]
        cell.userColor = user.id.generateColor()
        cell.userNameLabel.text = user.fullName ?? user.login
        cell.userAvatarLabel.text = String(user.fullName?.capitalized.first ?? Character("U"))
        cell.tag = indexPath.row
        
        let lastItemNumber = users.count - 1
        if indexPath.row == lastItemNumber {
            if isSearch == true, cancel == false {
                if let searchText = searchBar.text {
                    searchUsers(searchText)
                }
            } else if isSearch == false, cancelFetch == false {
                fetchUsers()
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = self.users[indexPath.row]
        selectedUsers.insert(user)
        checkCreateChatButtonState()
        setupNavigationTitle()
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let user = self.users[indexPath.row]
        if selectedUsers.contains(user) {
            selectedUsers.remove(user)
        }
        checkCreateChatButtonState()
        setupNavigationTitle()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let user = self.users[indexPath.row]
        if selectedUsers.contains(user) {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        } else {
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }
}

// MARK: - UISearchBarDelegate
extension NewCreateNewDialogVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        if searchText.count > 2 {
            isSearch = true
            currentSearchPage = 1
            cancel = false
            searchUsers(searchText)
        }
        if searchText.count == 0 {
            isSearch = false
            cancel = false
            setupUsers(downloadedUsers)
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        cancelSearchButton.isHidden = false
    }
    
    private func searchUsers(_ name: String) {
        SVProgressHUD.show()
        chatManager.searchUsers(name, currentPage: currentSearchPage, perPage: CreateNewDialogConstant.perPage) { [weak self] response, users, cancel in
            if let responseError = response, let errorMessage = responseError.error?.reasons?["message"] as? String {
                self?.showAlertView(nil, message: errorMessage.localized)
            }
            SVProgressHUD.dismiss()
            self?.cancel = cancel
            if self?.currentSearchPage == 1 {
                self?.foundedUsers = []
            }
            if cancel == false {
                self?.currentSearchPage += 1
            }
            if users.isEmpty == false {
                self?.tableView.removeEmptyView()
                self?.addFoundUsers(users)
            } else {
                self?.addFoundUsers(users)
                self?.tableView.setupEmptyView(CreateNewDialogConstant.noUsers)
            }
        }
    }
    
    private func fetchUsers() {
        SVProgressHUD.show()
        chatManager.fetchUsers(currentPage: currentFetchPage, perPage: CreateNewDialogConstant.perPage) { [weak self] response, users, cancel in
            if let responseError = response, let errorMessage = responseError.error?.reasons?["message"] as? String {
                self?.showAlertView(nil, message: errorMessage.localized)
            }
            SVProgressHUD.dismiss()
            self?.cancelFetch = cancel
            if cancel == false {
                self?.currentFetchPage += 1
            }
            self?.downloadedUsers.append(contentsOf: users)
            self?.setupUsers(self?.downloadedUsers ?? [QBUUser]())
            if users.isEmpty == false {
                self?.tableView.removeEmptyView()
            } else {
                self?.tableView.setupEmptyView(CreateNewDialogConstant.noUsers)
            }
        }
    }
}
