//
//  UsersViewController.swift
//  sample-conference-videochat-swift
//
//  Created by Vladimir Nybozhinsky on 12.10.2018.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit
import Quickblox
import SVProgressHUD

protocol UsersViewControllerDelegate: class {
    func usersViewController(_ usersViewController: UsersViewController,
                             didCreateChatDialog chatDialog: QBChatDialog)
}

struct UsersViewControllerConstant {
    static let create = "Create"
    static let creatingChatDialog = NSLocalizedString("Creating chat dialog.", comment: "")
    static let checkInternetConnection = NSLocalizedString("Please check your Internet connection",
                                                           comment: "")
}

class UsersViewController: UITableViewController {
    // MARK: - Properties
    let core = Core.instance
    weak var dataSource: UsersDataSource?
    weak var delegate: UsersViewControllerDelegate?
    
    // MARK: Life Сycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = dataSource
        tableView.rowHeight = 44.0
        fetchData()
        
        let createChatButton = UIBarButtonItem(title: UsersViewControllerConstant.create,
                                               style: .plain,
                                               target: self,
                                               action: #selector(didTapCreateChatButton(_:)))
        
        navigationItem.rightBarButtonItem = createChatButton
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        // adding refresh control task
        if (refreshControl != nil) {
            refreshControl?.addTarget(self, action: #selector(fetchData),
                                      for: .valueChanged)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let refreshControl = self.refreshControl, refreshControl.isRefreshing == true {
            let contentOffset = CGPoint(x: 0.0, y: -refreshControl.frame.size.height)
            tableView.setContentOffset(contentOffset, animated: false)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isMovingFromParent {
            dataSource?.deselectAllObjects()
        }
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
    
    //MARK: - Actions
    @objc private func didTapCreateChatButton(_ item: UIBarButtonItem?) {
        guard hasConnectivity() == true,
            let dataSource = dataSource,
            let fullName = core.currentUser?.fullName else {
            return
        }
    
        let userIDs = dataSource.selectedObjects.map{ NSNumber(value: $0.id) }
        let userNames = dataSource.selectedObjects.compactMap{ $0.fullName }
        let chatDialog = QBChatDialog(dialogID: nil, type: QBChatDialogType.group)
        chatDialog.occupantIDs = userIDs
        
        let userNamesString = userNames.joined(separator: ", ")
        chatDialog.name = "\(fullName), \(userNamesString)"
        
        SVProgressHUD.show(withStatus: UsersViewControllerConstant.creatingChatDialog)
        
        QBRequest.createDialog(chatDialog, successBlock: { [weak self] response, createdDialog in
            guard let `self` = self else { return }
            SVProgressHUD.dismiss()
            self.delegate?.usersViewController(self, didCreateChatDialog: createdDialog)
            self.navigationController?.popViewController(animated: true)
            
            }, errorBlock: { response in
                SVProgressHUD.showError(withStatus: "\(String(describing: response.error?.reasons))")
        })
    }
    
    @objc private func fetchData() {
        DataFetcher.fetchUsers({ [weak self] users in
            if users.isEmpty == false {
                self?.dataSource?.updateObjects(users)
                self?.tableView.reloadData()
                self?.refreshControl?.endRefreshing()
            } else {
                self?.showAlertView(withMessage:  UsersViewControllerConstant.checkInternetConnection)
            }
            }, failure: { [weak self] (description) in
                self?.showAlertView(withMessage: description)
        })
    }
    
    // MARK: - Internal Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let dataSource = dataSource else {
            return
        }
        dataSource.selectObject(at: indexPath)
        
        tableView.reloadSections([0], with: .none)
        navigationItem.rightBarButtonItem?.isEnabled = dataSource.selectedObjects.isEmpty == false
    }
    
    private func hasConnectivity() -> Bool {
        let status = core.networkConnectionStatus()
        guard status != NetworkConnectionStatus.notConnection else {
            showAlertView(withMessage: UsersViewControllerConstant.checkInternetConnection)
            return false
        }
        return true
    }
    
    private func showAlertView(withMessage message: String?) {
        let alertController = UIAlertController(title: nil,
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""),
                                                style: .default,
                                                handler: nil))
        present(alertController, animated: true)
    }
}
