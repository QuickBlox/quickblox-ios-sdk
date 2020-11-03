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
    static let noUsers = "No user with that name"
}

class AddOccupantsVC: UIViewController {
    
    @IBOutlet weak var cancelSearchButton: UIButton!
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    private var titleView = TitleView()
    //MARK: - Properties
    private var users : [QBUUser] = []
    private var downloadedUsers : [QBUUser] = []
    private var oldDialogUsers: [QBUUser] = []
    private var selectedUsers: Set<QBUUser> = []
    private var foundUsers : [QBUUser] = []
    private let chatManager = ChatManager.instance
    private var cancel = false
    private var cancelFetch = false
    private var currentFetchPage: UInt = 1
    private var currentSearchPage: UInt = 1
    private var isSearch = false
    private var searchText = ""
    /**
     *  This property is required when creating a ChatViewController.
     */
    var dialogID: String! {
        didSet {
            self.dialog = chatManager.storage.dialog(withID: dialogID)
        }
    }
    private var dialog: QBChatDialog!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.titleView = titleView
        setupNavigationTitle()
        
        chatManager.delegate = self

        checkCreateChatButtonState()
        
        tableView.register(UINib(nibName: UserCellConstant.reuseIdentifier, bundle: nil), forCellReuseIdentifier: UserCellConstant.reuseIdentifier)
        tableView.keyboardDismissMode = .onDrag
        
        let createButtonItem = UIBarButtonItem(title: "Done",
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
            guard let self = self else {
                return
            }
            let notConnection = status == .notConnection
            if notConnection == true {
                self.showAlertView(LoginConstant.checkInternet, message: LoginConstant.checkInternetMessage)
            }
            if notConnection == false {
                if QBChat.instance.isConnected == false{
                    self.chatManager.connect()
                }
                if self.isSearch == false {
                    self.fetchUsers()
                } else {
                    if self.searchText.count > 2 {
                        self.searchUsers(self.searchText)
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

                // Create our own placeholder label
                let placeholderLabel = UILabel(frame: .zero)

                placeholderLabel.text = "Search"
                placeholderLabel.font = .systemFont(ofSize: 15.0, weight: .regular)
                placeholderLabel.textColor = #colorLiteral(red: 0.4255777597, green: 0.476770997, blue: 0.5723374486, alpha: 1)

                systemPlaceholderLabel.addSubview(placeholderLabel)

                // Layout label to be a "new" placeholder
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
        let title = AddOccupantsConstant.addOccupants
        var users = "users"
        if selectedUsers.count == 1 {
            users = "user"
        }
        let numberUsers = "\(selectedUsers.count) \(users) selected"
        titleView.setupTitleView(title: title, subTitle: numberUsers)
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
            return
        }
        
        cancelSearchButton.isHidden = true
        searchBar.text = ""
        searchBar.resignFirstResponder()
        isSearch = false
        sender.isEnabled = false
        let selectedUsers = Array(self.selectedUsers)
        
        if dialog.type == .group {
            SVProgressHUD.show()
            chatManager.storage.update(users: selectedUsers)
            let newUsersIDs = selectedUsers.map{ NSNumber(value: $0.id) }
            // Updates dialog with new occupants.
            chatManager.joinOccupants(withIDs: newUsersIDs, to: dialog) { [weak self] (response, dialog) -> Void in
                guard response?.error == nil else {
                    SVProgressHUD.showError(withStatus: response?.error?.error?.localizedDescription)
                    sender.isEnabled = true
                    return
                }
                guard let dialog = dialog,
                    let message = self?.messageTextWithUsers(selectedUsers) else {
                        return
                }
                self?.chatManager.sendAddingMessage(message, action: .add, withUsers: newUsersIDs, to: dialog, completion: { (error) in
                    SVProgressHUD.showSuccess(withStatus: "STR_DIALOG_CREATED".localized)
                    
                    self?.checkCreateChatButtonState()
                    self?.openNewDialog(dialog)
                })
            }
        }
    }
    
    private func messageTextWithUsers(_ users: [QBUUser]) -> String {
        let actionMessage = "SA_STR_ADDED".localized
        guard let current = QBSession.current.currentUser,
            let fullName = current.fullName else {
                return ""
        }
        var message = "\(fullName) \(actionMessage)"
        for user in users {
            guard let userFullName = user.fullName else {
                continue
            }
            message += " \(userFullName),"
        }
        message = String(message.dropLast())
        return message
    }
    
    private func openNewDialog(_ newDialog: QBChatDialog) {
        guard let navigationController = navigationController else {
            return
        }
        let controllers = navigationController.viewControllers
        var newStack = [UIViewController]()
        
        //change stack by replacing view controllers after ChatVC with ChatVC
        controllers.forEach{
            newStack.append($0)
            if $0 is DialogsViewController {
                let storyboard = UIStoryboard(name: "Chat", bundle: nil)
                guard let chatController = storyboard.instantiateViewController(withIdentifier: "ChatViewController")
                    as? ChatViewController else {
                        return
                }
                chatController.dialogID = newDialog.id
                newStack.append(chatController)
                navigationController.setViewControllers(newStack, animated: true)
                return
            }
        }
        //else perform segue
        self.performSegue(withIdentifier: "SA_STR_SEGUE_GO_TO_CHAT".localized, sender: newDialog.id)
    }
    
    //MARK: - Overrides
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "enterChatName" {
            if let chatNameVC = segue.destination as? EnterChatNameVC {
                let selectedUsers = Array(self.selectedUsers) + oldDialogUsers
                chatNameVC.selectedUsers = selectedUsers
            }
        }
        if segue.identifier == "SA_STR_SEGUE_GO_TO_CHAT".localized {
            if let chatVC = segue.destination as? ChatViewController {
                chatVC.dialogID = sender as? String
            }
        }
    }
    
    private func setupUsers(_ users: [QBUUser]) {
        let currentUser = Profile()
        
        oldDialogUsers = []
        self.users = []
        
        guard let occupantIDs = dialog.occupantIDs as? [UInt] else {
            return
        }
        
        for user in users {
            if user.id == currentUser.ID {
                continue
            }
            
            if occupantIDs.contains(user.id) {
                oldDialogUsers.append(user)
            } else {
                self.users.append(user)
            }
        }
        var removedUsers:Set<QBUUser> = []
        for user in selectedUsers {
            if occupantIDs.contains(user.id) {
                removedUsers.insert(user)
            }
        }
        selectedUsers.subtract(removedUsers)
        
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
        var filteredUsers: [QBUUser] = []
        let currentUser = Profile()
        
        guard let occupantIDs = dialog.occupantIDs as? [UInt] else {
            return
        }
        
        for user in users {
            if user.id == currentUser.ID {
                continue
            }
            
            if occupantIDs.contains(user.id) == false {
                filteredUsers.append(user)
            }
        }

        var removedUsers:Set<QBUUser> = []
        for user in selectedUsers {
            if occupantIDs.contains(user.id) {
                removedUsers.insert(user)
            }
        }
        selectedUsers.subtract(removedUsers)
        
        foundUsers = foundUsers + filteredUsers
        
        self.users = foundUsers
        tableView.reloadData()
        checkCreateChatButtonState()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension AddOccupantsVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if users.count == 0, isSearch == true {
            tableView.setupEmptyView(AddOccupantsConstant.noUsers)
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
extension AddOccupantsVC: UISearchBarDelegate {
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
            SVProgressHUD.dismiss()
            self?.cancel = cancel
            if self?.currentSearchPage == 1 {
                self?.foundUsers = []
            }
            if cancel == false {
                self?.currentSearchPage += 1
            }
            if users.isEmpty == false {
                self?.tableView.removeEmptyView()
                self?.addFoundUsers(users)
            } else {
                self?.addFoundUsers(users)
                self?.tableView.setupEmptyView(AddOccupantsConstant.noUsers)
            }
        }
    }
    
    private func fetchUsers() {
        if Reachability.instance.networkConnectionStatus() == .notConnection {
            showAlertView(LoginConstant.checkInternet, message: LoginConstant.checkInternetMessage)
            return
        }
        SVProgressHUD.show()
        chatManager.fetchUsers(currentPage: currentFetchPage, perPage: CreateNewDialogConstant.perPage) { [weak self] response, users, cancel in
            SVProgressHUD.dismiss()
            self?.cancelFetch = cancel
            if cancel == false {
                self?.currentFetchPage += 1
            }
            if users.isEmpty == false {
                self?.tableView.removeEmptyView()
                self?.downloadedUsers.append(contentsOf: users)
                self?.setupUsers(self?.downloadedUsers ?? [QBUUser]())
            } else {
                self?.downloadedUsers.append(contentsOf: users)
                self?.setupUsers(self?.downloadedUsers ?? [QBUUser]())
                self?.tableView.setupEmptyView(AddOccupantsConstant.noUsers)
            }
        }
    }
}

// MARK: - ChatManagerDelegate
extension AddOccupantsVC: ChatManagerDelegate {
    func chatManager(_ chatManager: ChatManager, didUpdateChatDialog chatDialog: QBChatDialog) {
        SVProgressHUD.dismiss()
        if chatDialog.id == dialogID {
            dialog = chatDialog
            setupUsers(self.users)
            
        }
    }
    
    func chatManagerWillUpdateStorage(_ chatManager: ChatManager) {
        SVProgressHUD.show(withStatus: "SA_STR_LOADING_USERS".localized)
    }
    
    func chatManager(_ chatManager: ChatManager, didFailUpdateStorage message: String) {
        SVProgressHUD.showError(withStatus: message)
    }
    
    func chatManager(_ chatManager: ChatManager, didUpdateStorage message: String) {
        SVProgressHUD.showSuccess(withStatus: message)
    }
}

