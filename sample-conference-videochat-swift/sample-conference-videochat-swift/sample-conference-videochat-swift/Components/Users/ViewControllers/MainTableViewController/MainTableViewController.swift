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

struct MainSegueConstant {
    static let settings = "PresentSettingsViewController"
    static let users = "PresentUsersViewController"
    static let call = "PresentCallViewController"
    static let sceneAuth = "SceneSegueAuth"
}

struct MainAlertConstant {
    static let checkInternet = NSLocalizedString("Please check your Internet connection", comment: "")
    static let okAction = NSLocalizedString("Ok", comment: "")
    static let logout = NSLocalizedString("Logout...", comment: "")
}

class MainTableViewController: UITableViewController, SettingsViewControllerDelegate, QBCoreDelegate,
DialogsDataSourceDelegate, UsersViewControllerDelegate {
    
    //MARK: Variables
    let core = QBCore.instance
    private lazy var dialogsDataSource:DialogsDataSource = {
        let dialogsDataSource = DialogsDataSource()
        dialogsDataSource.delegate = self
        return dialogsDataSource
    }()
    var usersDataSource = UsersDataSource()
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        core.addDelegate(self)
        
        // Reachability
        core.networkStatusBlock = { [weak self] status in
            if status != NetworkConnectionStatus.notConnection {
                self?.fetchData()
            }
        }
        
        configureNavigationBar()
        configureTableViewController()
        fetchData()
        
        // adding refresh control task
        if let refreshControl = self.refreshControl {
            refreshControl.addTarget(self, action: #selector(self.fetchData), for: .valueChanged)
        }
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
    
    // MARK: UI Configuration
    func configureTableViewController() {
        tableView.dataSource = dialogsDataSource
        tableView.rowHeight = 76.0
        refreshControl?.beginRefreshing()
    }
    
    func configureNavigationBar() {
        let settingsButtonItem = UIBarButtonItem(image: UIImage(named: "ic-settings"),
                                                 style: .plain,
                                                 target: self,
                                                 action: #selector(didPressSettingsButton(_:)))
        navigationItem.leftBarButtonItem = settingsButtonItem
        
        let usersButtonItem = UIBarButtonItem(image: UIImage(named: "new-message"),
                                              style: .plain,
                                              target: self,
                                              action: #selector(didPressUsersButton(_:)))
        navigationItem.rightBarButtonItem = usersButtonItem
        
        //Custom label
        var userName = "Logged in as "
        var roomName = ""
        var titleString = ""
        if let currentUser = core.currentUser,
            let fullname = currentUser.fullName,
            let tags = currentUser.tags,
            tags.isEmpty == false,
            let name = tags.first {
            roomName = name
            userName = userName + fullname
            titleString = roomName + "\n" + userName
        }

        let attrString = NSMutableAttributedString(string: titleString)
        let roomNameRange: NSRange = (titleString as NSString).range(of: roomName )
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
        let status = core.networkConnectionStatus()
        guard status != NetworkConnectionStatus.notConnection else {
            showAlertView(withMessage: MainAlertConstant.checkInternet)
            return false
        }
        return true
    }
    
    func showAlertView(withMessage message: String?) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: MainAlertConstant.okAction, style: .default,
                                                handler: nil))
        present(alertController, animated: true)
    }
    
    @objc func didPressSettingsButton(_ item: UIBarButtonItem?) {
        performSegue(withIdentifier: MainSegueConstant.settings, sender: item)
    }
    
    @objc func didPressUsersButton(_ item: UIBarButtonItem?) {
        performSegue(withIdentifier: MainSegueConstant.users, sender: item)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
        case MainSegueConstant.settings:
            let settingsViewController = (segue.destination as? UINavigationController)?.topViewController
                as? SessionSettingsViewController
            settingsViewController?.delegate = self
            
        case MainSegueConstant.users:
            let usersViewController = segue.destination as? UsersViewController
            usersViewController?.dataSource = usersDataSource
            usersViewController?.delegate = self
            
        case MainSegueConstant.call:
            guard let senderArr = (sender as? (QBChatDialog, QBRTCConferenceType)) else { return }
            let callVC = segue.destination as? CallViewController
            callVC?.chatDialog = senderArr.0
            callVC?.conferenceType = senderArr.1
            callVC?.usersDataSource = usersDataSource
            
        default:
            break
        }
    }
    
    //MARK: - DialogsDataSourceDelegate
    func dialogsDataSource(_ dialogsDataSource: DialogsDataSource?,
                           dialogCellDidTapListener dialogCell: UITableViewCell?) {
        joinDialog(fromDialogCell: dialogCell, conferenceType: QBRTCConferenceType(rawValue: 0)!)
    }
    
    func dialogsDataSource(_ dialogsDataSource: DialogsDataSource?,
                           dialogCellDidTapAudio dialogCell: UITableViewCell?) {
        joinDialog(fromDialogCell: dialogCell, conferenceType: QBRTCConferenceType.audio)
    }
    
    func dialogsDataSource(_ dialogsDataSource: DialogsDataSource?,
                           dialogCellDidTapVideo dialogCell: UITableViewCell?) {
        joinDialog(fromDialogCell: dialogCell, conferenceType: QBRTCConferenceType.video)
    }
    
    func dialogsDataSource(_ dialogsDataSource: DialogsDataSource?,
                           commit editingStyle: UITableViewCell.EditingStyle,
                           forRowAt indexPath: IndexPath?) {
        
        guard let indexPath = indexPath else { return }
        if hasConnectivity() && editingStyle == .delete {
            SVProgressHUD.show()
            let chatDialog: QBChatDialog? = self.dialogsDataSource.objects[indexPath.row]
            QBRequest.deleteDialogs(withIDs: Set<AnyHashable>([chatDialog?.id]) as! Set<String>,
                                    forAllUsers: false,
                                    successBlock: { [weak self] response, deletedObjectsIDs,
                                        notFoundObjectsIDs,
                                        wrongPermissionsObjectsIDs in
                                        
                                        guard let `self` = self else { return }
                                        
                                        let dialogs = self.dialogsDataSource.objects
                                         let sortedDialogs = dialogs.filter({$0 != chatDialog})
                                            self.dialogsDataSource.objects = sortedDialogs
                                            self.tableView.reloadData()
                                            SVProgressHUD.dismiss()
                }, errorBlock: { response in
                    SVProgressHUD.showError(withStatus: "\(String(describing: response.error?.reasons))")
            })
        }
    }
    
    // MARK: UsersViewControllerDelegate
    func usersViewController(_ usersViewController: UsersViewController?,
                             didCreateChatDialog chatDialog: QBChatDialog?) {
        var dialogsObjects = dialogsDataSource.objects
        if let chatDialog = chatDialog {
            dialogsObjects.append(chatDialog)
        }
        dialogsDataSource.objects = dialogsObjects
        tableView.reloadData()
    }
    
    // MARK: QBCoreDelegate
    func coreDidLogout(_ core: QBCore?) {
        SVProgressHUD.dismiss()
        //Dismiss Settings view controller
        dismiss(animated: false)
        DispatchQueue.main.async(execute: {
            self.performSegue(withIdentifier: MainSegueConstant.sceneAuth, sender: nil)
        })
    }
    
    func core(_ core: QBCore?, error: Error?, domain: ErrorDomain) {
        if domain == ErrorDomain.ErrorDomainLogOut {
            SVProgressHUD.showError(withStatus: error?.localizedDescription)
        }
    }
    
    // MARK: SettingsViewControllerDelegate
    func settingsViewController(_ vc: SessionSettingsViewController?, didPressLogout sender: Any?) {
        SVProgressHUD.show(withStatus: MainAlertConstant.logout)
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
        let dataGroup = DispatchGroup()
        dataGroup.enter()
        QBDataFetcher.fetchDialogs({ [weak self] dialogs in
            dataGroup.leave()
            if let dialogs = dialogs, dialogs.isEmpty == false {
                self?.dialogsDataSource.objects = dialogs
                self?.tableView.reloadData()
            }
        })
        dataGroup.enter()
        QBDataFetcher.fetchUsers({ [weak self] users in
            dataGroup.leave()
            guard let users = users else { return }
            self?.usersDataSource.objects = users
        })
        dataGroup.notify(queue: DispatchQueue.main) {
            self.refreshControl?.endRefreshing()
        }
    }
    
    func joinDialog(fromDialogCell cell: UITableViewCell?, conferenceType: QBRTCConferenceType) {
        if hasConnectivity() {
            if Int(Float(conferenceType.rawValue)) > 0 {
                QBAVCallPermissions.check(with: conferenceType) { granted in
                    
                    if granted {
                        guard let indexPath = self.tableView.indexPath(for: cell!) else { return }
                        let chatDialog = self.dialogsDataSource.objects[indexPath.row]
                        self.performSegue(withIdentifier: MainSegueConstant.call,
                                          sender: (chatDialog, conferenceType))
                    }
                }
            } else {
                guard let indexPath = self.tableView.indexPath(for: cell!) else { return }
                let chatDialog = self.dialogsDataSource.objects[indexPath.row]
                self.performSegue(withIdentifier: MainSegueConstant.call,
                                  sender: (chatDialog, conferenceType))
            }
        }
    }
}
