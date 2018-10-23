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
    private var dataSource: UsersDataSource?
    
    // MARK: Lifecycle
    
    deinit {
        
        debugPrint("deinit \(self)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = UsersDataSource()
        var users: [QBUUser] = []
        for user in (usersDataSource?.objects)! {
            if !(chatDialog?.occupantIDs?.contains(NSNumber(value: user.id)))! {
                
                users.append(user)
            }
        }
        dataSource?.objects = users
        
        tableView.dataSource = dataSource
        tableView.rowHeight = 44
        
        // adding refresh control task
        if refreshControl != nil {
            
            refreshControl?.addTarget(self, action: #selector(self.fetchData), for: .valueChanged)
        }
        
        let createChatButton = UIBarButtonItem(title: "Update", style: .plain, target: self, action: #selector(self.didPressUpdateChatButton(_:)))
        
        navigationItem.rightBarButtonItem = createChatButton
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if refreshControl?.isRefreshing ?? false {
            tableView.setContentOffset(CGPoint(x: 0, y: -(refreshControl?.frame.size.height ?? 0.0)), animated: false)
        }
    }
    
    @objc func didPressUpdateChatButton(_ item: UIBarButtonItem?) {
        
        SVProgressHUD.show()
        var pushOccupantsIDs: [String] = []
        for user: QBUUser? in (dataSource?.selectedObjects)! {
            if let anID = user?.id {
                pushOccupantsIDs.append(String(format: "%tu", anID))
            }
        }
        chatDialog?.pushOccupantsIDs = pushOccupantsIDs
        
        weak var weakSelf = self
        QBRequest.update(chatDialog!, successBlock: { response, chatDialog in
            
            weakSelf?.chatDialog?.occupantIDs = chatDialog.occupantIDs
            SVProgressHUD.dismiss()
            weakSelf?.navigationController?.popViewController(animated: true)
            
        }, errorBlock: { response in
            
            SVProgressHUD.showError(withStatus: "\(String(describing: response.error?.reasons))")
        })
    }
    
    // MARK: UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        dataSource?.selectObject(at: indexPath)
        tableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .none)
        
        navigationItem.rightBarButtonItem?.isEnabled = dataSource?.selectedObjects.count ?? 0 > 0
    }
    
    // MARK: Private
    @objc func fetchData() {
        
        weak var weakSelf = self
        QBDataFetcher.fetchUsers({ users in
            
            let strongSelf = weakSelf
            var mutableUsers = users
            for user in users! {
             
                if (strongSelf?.chatDialog?.occupantIDs?.contains(NSNumber(value: user.id)))! {
                        mutableUsers?.removeAll(where: { element in element == user })
                    }
            }
            strongSelf?.dataSource?.objects = mutableUsers!
            strongSelf?.tableView.reloadData()
            strongSelf?.refreshControl?.endRefreshing()
        })
    }
}
