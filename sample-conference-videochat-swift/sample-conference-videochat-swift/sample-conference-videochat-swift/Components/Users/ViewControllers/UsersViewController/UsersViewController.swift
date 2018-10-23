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
    func usersViewController(_ usersViewController: UsersViewController?, didCreateChatDialog chatDialog: QBChatDialog?)
}

class UsersViewController: UITableViewController {
    
    // MARK: Variables
    
    let core = QBCore.instance
    
    weak var dataSource: UsersDataSource?
    weak var delegate: UsersViewControllerDelegate?

        // MARK: Lifecycle
        
    override func viewDidLoad() {
            super.viewDidLoad()
            
            tableView.dataSource = dataSource
            tableView.rowHeight = 44
        fetchData()
            
            // adding refresh control task
        if (refreshControl != nil) {
            refreshControl?.addTarget(self, action: #selector(UsersViewController.fetchData), for: .valueChanged)
            }
            
            let createChatButton = UIBarButtonItem(title: "Create", style: .plain, target: self, action: #selector(UsersViewController.didPressCreateChatButton(_:)))
            
            navigationItem.rightBarButtonItem = createChatButton
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
        
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
        if (refreshControl?.isRefreshing)! {
            tableView.setContentOffset(CGPoint(x: 0, y: -(refreshControl?.frame.height)!), animated: false)
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
    
    @objc func didPressCreateChatButton(_ item: UIBarButtonItem?) {
        
        if hasConnectivity() {
            
            let selectedUsers = dataSource?.selectedObjects
            let userIDs = selectedUsers?.map{ $0.externalUserID }
            let userNames = selectedUsers?.map{ $0.fullName } as! [String]
            let chatDialog = QBChatDialog(dialogID: nil, type: QBChatDialogType.group)
            chatDialog.occupantIDs = userIDs as [NSNumber]?
            
            chatDialog.name = "\(String(describing: core.currentUser?.fullName)), \(userNames.joined(separator: ", ") )"
            
            SVProgressHUD.show(withStatus: NSLocalizedString("Creating chat dialog.", comment: ""))
            weak var weakSelf = self
            QBRequest.createDialog(chatDialog, successBlock: { response, createdDialog in
                
                SVProgressHUD.dismiss()
                weakSelf?.delegate?.usersViewController(weakSelf, didCreateChatDialog: createdDialog)
                weakSelf?.navigationController?.popViewController(animated: true)
                
            }, errorBlock: { response in
                
                SVProgressHUD.showError(withStatus: "\(String(describing: response.error?.reasons))")
            })
        }
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        dataSource?.selectObject(at: indexPath)
        tableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .none)

        navigationItem.rightBarButtonItem?.isEnabled = dataSource?.selectedObjects.count ?? 0 > 0
    }
    
    // MARK: Actions
    func hasConnectivity() -> Bool {
        
        let hasConnectivity: Bool = core.networkStatus() != QBNetworkStatus.QBNetworkStatusNotReachable
        
        if !hasConnectivity {
            showAlertView(withMessage: NSLocalizedString("Please check your Internet connection", comment: ""))
        }
        
        return hasConnectivity
    }
    
    func showAlertView(withMessage message: String?) {
        
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default, handler: nil))
        
        present(alertController, animated: true)
    }
    
    // MARK: Private
    @objc func fetchData() {
        weak var weakSelf = self
        QBDataFetcher.fetchUsers({ users in
            if let users = users {
                weakSelf?.dataSource?.objects = users
                weakSelf?.tableView.reloadData()
                weakSelf?.refreshControl?.endRefreshing()
            } else {
                self.showAlertView(withMessage: NSLocalizedString("Please check your Internet connection", comment: ""))
            }
        })
    }
}
