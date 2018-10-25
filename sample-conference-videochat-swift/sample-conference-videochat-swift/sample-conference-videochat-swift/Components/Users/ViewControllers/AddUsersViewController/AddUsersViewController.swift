//
//  AddUsersViewController.swift
//  sample-conference-videochat-swift
//
//  Created by Vladimir Nybozhinsky on 04.10.2018.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit
import Quickblox
import SVProgressHUD

class AddUsersViewController: UITableViewController {
    weak var usersDataSource: UsersDataSource?
    weak var chatDialog: QBChatDialog?
    private var dataSource = UsersDataSource()
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let usersDataSource = usersDataSource,
            let chatDialog = chatDialog,
            let occupantIDs = chatDialog.occupantIDs  else {
                return
        }
        let users = usersDataSource.objects.filter({
            occupantIDs.contains(NSNumber(value: $0.id)) == false
        })
        dataSource.updateObjects(users)
        
        tableView.dataSource = dataSource
        tableView.rowHeight = 44
        
        // adding refresh control task
        if let refreshControl = self.refreshControl {
            refreshControl.addTarget(self, action: #selector(fetchData), for: .valueChanged)
        }
        let createChatButton = UIBarButtonItem(title: "Update",
                                               style: .plain,
                                               target: self,
                                               action: #selector(didPressUpdateChatButton(_:)))
        
        navigationItem.rightBarButtonItem = createChatButton
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let refreshControl = self.refreshControl, refreshControl.isRefreshing == true {
            let contentOffset = CGPoint(x: 0, y: -refreshControl.frame.size.height)
            tableView.setContentOffset(contentOffset, animated: false)
        }
    }
    deinit {
        debugPrint("deinit \(self)")
    }
    
    @objc func didPressUpdateChatButton(_ item: UIBarButtonItem?) {
        
        SVProgressHUD.show()
        var pushOccupantsIDs: [String] = []
        for user in dataSource.selectedObjects {
            pushOccupantsIDs.append(String(format: "%tu", user.id))
        }
        chatDialog?.pushOccupantsIDs = pushOccupantsIDs
        QBRequest.update(chatDialog!, successBlock: { [weak self] response, chatDialog in
            
            self?.chatDialog?.occupantIDs = chatDialog.occupantIDs
            SVProgressHUD.dismiss()
            self?.navigationController?.popViewController(animated: true)
            
            }, errorBlock: { response in
                
                SVProgressHUD.showError(withStatus: "\(String(describing: response.error?.reasons))")
        })
    }
    
    // MARK: UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dataSource.selectObject(at: indexPath)
        tableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .none)
        navigationItem.rightBarButtonItem?.isEnabled = dataSource.selectedObjects.count > 0
    }
    
    // MARK: Private
    @objc func fetchData() {
        QBDataFetcher.fetchUsers({ [weak self] users in

            guard let users = users else { return }
            var mutableUsers = users
            for user in users {
                
                if (self?.chatDialog?.occupantIDs?.contains(NSNumber(value: user.id)))! {
                    mutableUsers.removeAll(where: { element in element == user })
                }
            }
            self?.dataSource.updateObjects(mutableUsers)
            self?.tableView.reloadData()
            self?.refreshControl?.endRefreshing()
        })
    }
}
