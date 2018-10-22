//
//  MainTableViewController.swift
//  sample-conference-videochat-swift
//
//  Created by Vladimir Nybozhinsky on 11.10.2018.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit
import SVProgressHUD
import Quickblox
import QuickbloxWebRTC

enum CallSenderValue : Int {
    case dialogInstance
    case conferenceType
}

struct UserMainConstants {
    static let kSettingsSegue = "PresentSettingsViewController"
    static let kUsersSegue = "PresentUsersViewController"
    static let kCallSegue = "PresentCallViewController"
    static let kSceneSegueAuth = "SceneSegueAuth"
}

class MainTableViewController: UITableViewController, SettingsViewControllerDelegate, QBCoreDelegate, DialogsDataSourceDelegate, UsersViewControllerDelegate {
    
    //MARK: Variables
    let core = QBCore.instance
        var dialogsDataSource: DialogsDataSource?
        var usersDataSource: UsersDataSource?
    
    // MARK: Lifecycle
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        core.addDelegate(self)
        
        // Reachability
        weak var weakSelf = self
        core.networkStatusBlock = { status in
            if status != QBNetworkStatus.QBNetworkStatusNotReachable {
                weakSelf?.fetchData()
            }
        }
        
        configureNavigationBar()
        configureTableViewController()
        fetchData()
        
        // adding refresh control task
        if refreshControl != nil {
            
            refreshControl?.addTarget(self, action: #selector(self.fetchData), for: .valueChanged)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if refreshControl?.isRefreshing ?? false {
            tableView.setContentOffset(CGPoint(x: 0, y: -(refreshControl?.frame.size.height ?? 0.0)), animated: false)
        }
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
    
    // MARK: UI Configuration
    func configureTableViewController() {
        
        dialogsDataSource = DialogsDataSource()
        dialogsDataSource?.delegate = self
        usersDataSource = UsersDataSource()
        tableView.dataSource = dialogsDataSource
        tableView.rowHeight = 76
        refreshControl?.beginRefreshing()
    }
    
    func configureNavigationBar() {
        
        let settingsButtonItem = UIBarButtonItem(image: UIImage(named: "ic-settings"), style: .plain, target: self, action: #selector(self.didPressSettingsButton(_:)))
        
        navigationItem.leftBarButtonItem = settingsButtonItem
        
        let usersButtonItem = UIBarButtonItem(image: UIImage(named: "new-message"), style: .plain, target: self, action: #selector(self.didPressUsersButton(_:)))
        
        navigationItem.rightBarButtonItem = usersButtonItem
        
        //Custom label
        var roomName: String? = nil
        if let anObject = core.currentUser?.tags?.first {
            roomName = "\(anObject)"
        }
        let userName = "Logged in as \(String(describing: core.currentUser?.fullName))"
        let titleString = "\(roomName ?? "")\n\(userName)"
        
        let attrString = NSMutableAttributedString(string: titleString)
        let roomNameRange: NSRange = (titleString as NSString).range(of: roomName ?? "")
        attrString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 16.0), range: roomNameRange)
        
        let userNameRange: NSRange = (titleString as NSString).range(of: userName)
        attrString.addAttribute(.font, value: UIFont.systemFont(ofSize: 12.0), range: userNameRange)
        attrString.addAttribute(.foregroundColor, value: UIColor.gray, range: userNameRange)
        
        let titleView = UILabel(frame: CGRect.zero)
        titleView.numberOfLines = 2
        titleView.attributedText = attrString
        titleView.textAlignment = .center
        titleView.sizeToFit()
        
        navigationItem.titleView = titleView
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
    
    @objc func didPressSettingsButton(_ item: UIBarButtonItem?) {
        
        performSegue(withIdentifier: UserMainConstants.kSettingsSegue, sender: item)
    }
    
    @objc func didPressUsersButton(_ item: UIBarButtonItem?) {
        
        performSegue(withIdentifier: UserMainConstants.kUsersSegue, sender: item)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if (segue.identifier == UserMainConstants.kSettingsSegue) {

            let settingsViewController = (segue.destination as? UINavigationController)?.topViewController as? SessionSettingsViewController
            settingsViewController?.delegate = self
            
        } else if (segue.identifier == UserMainConstants.kUsersSegue) {

            let usersViewController = segue.destination as? UsersViewController
            usersViewController?.dataSource = usersDataSource
            usersViewController?.delegate = self
            
        } else if (segue.identifier == UserMainConstants.kCallSegue) {
            
            guard let senderArr = (sender as? (QBChatDialog, QBRTCConferenceType)) else { return }

            let callVC = segue.destination as? CallViewController
            callVC?.chatDialog = senderArr.0
            callVC?.conferenceType = senderArr.1
            callVC?.usersDataSource = usersDataSource
        }
    }
    
     //MARK: - DialogsDataSourceDelegate
    
    func dialogsDataSource(_ dialogsDataSource: DialogsDataSource?, dialogCellDidTapListener dialogCell: UITableViewCell?) {

        joinDialog(fromDialogCell: dialogCell, conferenceType: QBRTCConferenceType(rawValue: 0)!)
    }

    func dialogsDataSource(_ dialogsDataSource: DialogsDataSource?, dialogCellDidTapAudio dialogCell: UITableViewCell?) {

        joinDialog(fromDialogCell: dialogCell, conferenceType: QBRTCConferenceType.audio)
    }

    func dialogsDataSource(_ dialogsDataSource: DialogsDataSource?, dialogCellDidTapVideo dialogCell: UITableViewCell?) {

        joinDialog(fromDialogCell: dialogCell, conferenceType: QBRTCConferenceType.video)
    }

    func dialogsDataSource(_ dialogsDataSource: DialogsDataSource?, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath?) {
        if hasConnectivity() && editingStyle == .delete {

            SVProgressHUD.show()
            let chatDialog: QBChatDialog? = self.dialogsDataSource?.objects[indexPath?.row ?? 0]
            weak var weakSelf = self
            QBRequest.deleteDialogs(withIDs: Set<AnyHashable>([chatDialog?.id]) as! Set<String>, forAllUsers: false, successBlock: { response, deletedObjectsIDs, notFoundObjectsIDs, wrongPermissionsObjectsIDs in

                let strongSelf = weakSelf
                let dialogs = strongSelf?.dialogsDataSource?.objects
                if let sortedDialogs =  dialogs?.filter({$0 != chatDialog}) {
                    strongSelf?.dialogsDataSource?.objects = sortedDialogs
                    self.tableView.reloadData()
                    SVProgressHUD.dismiss()
                }
            }, errorBlock: { response in

                SVProgressHUD.showError(withStatus: "\(String(describing: response.error?.reasons))")
            })
        }
    }
    
    // MARK: UsersViewControllerDelegate
    func usersViewController(_ usersViewController: UsersViewController?, didCreateChatDialog chatDialog: QBChatDialog?) {

        var mutableObjecs = dialogsDataSource?.objects
        if let aDialog = chatDialog {
            mutableObjecs?.append(aDialog)
        }
        dialogsDataSource?.objects = mutableObjecs!
        tableView.reloadData()
    }
    
    // MARK: QBCoreDelegate
    func coreDidLogout(_ core: QBCore?) {
        
        SVProgressHUD.dismiss()
        //Dismiss Settings view controller
        dismiss(animated: false)
        DispatchQueue.main.async(execute: {
            self.performSegue(withIdentifier: UserMainConstants.kSceneSegueAuth, sender: nil)
        })
    }
    
    func core(_ core: QBCore?, error: Error?, domain: ErrorDomain) {
        
        if domain == ErrorDomain.ErrorDomainLogOut {
            SVProgressHUD.showError(withStatus: error?.localizedDescription)
        }
    }
    
    // MARK: SettingsViewControllerDelegate
    func settingsViewController(_ vc: SessionSettingsViewController?, didPressLogout sender: Any?) {
        
        SVProgressHUD.show(withStatus: NSLocalizedString("Logout...", comment: ""))
        core.logout()
    }
    func coreDidLogin(_ core: QBCore) {
        debugPrint("coreDidLogin")
    }
    
    func coreDidLogout(_ core: QBCore) {
        debugPrint("coreDidLogin")
    }
    
    func core(_ core: QBCore, _ loginStatus: String) {
        debugPrint("coreDidLogin")
    }
    
    func core(_ core: QBCore, _ error: Error, _ domain: ErrorDomain) {
        debugPrint("coreDidLogin")
    }
    
    
    // MARK: Private
    
    @objc func fetchData() {

        weak var weakSelf = self
        let dataGroup = DispatchGroup()

        dataGroup.enter()
        
        QBDataFetcher.fetchDialogs({ dialogs in

            dataGroup.leave()
            let strongSelf = weakSelf
            strongSelf?.dialogsDataSource?.objects = dialogs as! Array<QBChatDialog>
            strongSelf?.tableView.reloadData()
        })

        dataGroup.enter()
        
        QBDataFetcher.fetchUsers({ users in

            dataGroup.leave()
            let strongSelf = weakSelf
            strongSelf?.usersDataSource?.objects = users as! Array<QBUUser>
        })
        
        dataGroup.notify(queue: DispatchQueue.main) {
            let strongSelf = weakSelf
            strongSelf?.refreshControl?.endRefreshing()
        }
    }

    func joinDialog(fromDialogCell cell: UITableViewCell?, conferenceType: QBRTCConferenceType) {
        if hasConnectivity() {

            if Int(Float(conferenceType.rawValue)) > 0 {
                QBAVCallPermissions.check(with: conferenceType) { granted in

                    if granted {

                        var indexPath: IndexPath? = nil
                        if let aCell = cell {
                            indexPath = self.tableView.indexPath(for: aCell)
                        }
                        let chatDialog: QBChatDialog? = self.dialogsDataSource?.objects[indexPath?.row ?? 0]
                        self.performSegue(withIdentifier: UserMainConstants.kCallSegue, sender: (chatDialog!, conferenceType))
                    }
                }
            } else {
                var indexPath: IndexPath? = nil
                if let aCell = cell {
                    indexPath = tableView.indexPath(for: aCell)
                }
                let chatDialog: QBChatDialog? = dialogsDataSource?.objects[indexPath?.row ?? 0]
                performSegue(withIdentifier: UserMainConstants.kCallSegue, sender: (chatDialog!, conferenceType))
            }
        }
    }
}
