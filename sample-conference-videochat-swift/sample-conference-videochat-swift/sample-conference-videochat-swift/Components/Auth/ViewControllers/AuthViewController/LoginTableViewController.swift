//
//  LoginTableViewController.swift
//  sample-conference-videochat-swift
//
//  Created by Vladimir Nybozhinsky on 04.10.2018.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit

class LoginTableViewController: UITableViewController {
    
// MARK: IBOutlets
    @IBOutlet private weak var loginInfo: UILabel!
    @IBOutlet private weak var userNameDescriptionLabel: UILabel!
    @IBOutlet private weak var chatRoomDescritptionLabel: UITextField!
    @IBOutlet private weak var userNameTextField: UITextField!
    @IBOutlet private weak var loginButton: QBLoadingButton!

// MARK: Variables
    var needReconnect: Bool?{
        didSet {
            debugPrint("did set needReconnect \(String(describing: needReconnect))")
        }
    }
    
// MARK: Life Cicles
    
    deinit {
        debugPrint("deinit \(self)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        [Core addDelegate:self];
        
        self.tableView.estimatedRowHeight = 80
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.keyboardDismissMode = .onDrag
        self.tableView.delaysContentTouches = false
        self.navigationItem.title = NSLocalizedString("Enter to chat", comment: "")
        
        self.defaultConfiguration()
        //Update interface and start login if user exist
//        if (Core.currentUser) {
//            self.userNameTextField.text = Core.currentUser.fullName
//            self.chatRoomNameTextField.text = [Core.currentUser.tags firstObject];
//            [self login];
//        }

    }

    private func defaultConfiguration() {
    
//    [self.loginButton hideLoading];
//    [self.loginButton setTitle:NSLocalizedString(@"Login", nil)
//    forState:UIControlStateNormal];
//
//    self.loginButton.enabled = NO;
//    self.userNameTextField.text = @"";
//    self.chatRoomNameTextField.text = @"";
//
//    [self setInputEnabled:YES];
//    // Reachability
//    void (^updateLoginInfo)(QBNetworkStatus status) = ^(QBNetworkStatus status) {
//
//    NSString *loginInfo = (status == QBNetworkStatusNotReachable) ?
//    NSLocalizedString(@"Please check your Internet connection", nil):
//    NSLocalizedString(@"Please enter your username and group name. You can join existent group.", nil);
//    [self setLoginInfoText:loginInfo];
//    };
//
//    Core.networkStatusBlock = ^(QBNetworkStatus status) {
//
//    if (self.needReconnect && status != QBNetworkStatusNotReachable) {
//
//    self.needReconnect = NO;
//    [self login];
//    }
//    else {
//
//    updateLoginInfo(status);
//    }
//    };
//
//    updateLoginInfo(Core.networkStatus);
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
    
  // MARK: Private Metods
//    fileprivate func d

}

