//
//  UsersViewController.swift
//  sample-videochat-webrtc-swift
//
//  Created by Vladimir Nybozhinsky on 12/10/18.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit
import Quickblox
import QuickbloxWebRTC
import PushKit
import SVProgressHUD

struct UsersConstant {
    static let pageSize: UInt = 50
    static let aps = "aps"
    static let alert = "alert"
    static let voipEvent = "VOIPCall"
}

struct UsersAlertConstant {
    static let checkInternet = NSLocalizedString("Please check your Internet connection", comment: "")
    static let okAction = NSLocalizedString("Ok", comment: "")
    static let shouldLogin = NSLocalizedString("You should login to use chat API. Session hasn’t been created. Please try to relogin the chat.", comment: "")
    static let logout = NSLocalizedString("Logout...", comment: "")
}

struct UsersSegueConstant {
    static let settings = "PresentSettingsViewController"
    static let call = "CallViewController"
    static let incoming = "IncomingCallViewController"
    static let sceneAuth = "SceneSegueAuth"
}

class UsersViewController: UITableViewController {
    
    @IBOutlet private weak var audioCallButton: UIBarButtonItem!
    @IBOutlet private weak var videoCallButton: UIBarButtonItem!
    
    let core = Core.instance
    lazy private var dataSource: UsersDataSource = {
        let dataSource = UsersDataSource(currentUser: Core.instance.currentUser)
        return dataSource
    }()
    private var nav: UINavigationController?
    private weak var session: QBRTCSession?
    lazy private var voipRegistry: PKPushRegistry = {
        let voipRegistry = PKPushRegistry(queue: DispatchQueue.main)
        return voipRegistry
    }()
    private var callUUID: UUID?
    lazy private var backgroundTask: UIBackgroundTaskIdentifier = {
        let backgroundTask = UIBackgroundTaskIdentifier.invalid
        return backgroundTask
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        core.addDelegate(self)
        QBRTCClient.instance().add(self)
        
        // Reachability
        core.networkStatusBlock = { [weak self] status in
            if status != NetworkConnectionStatus.notConnection {
                self?.loadUsers()
            }
        }
        
        // adding refresh control task
        if let refreshControl = self.refreshControl {
            refreshControl.addTarget(self, action: #selector(loadUsers), for: .valueChanged)
        }
        
        configureNavigationBar()
        configureTableViewController()
        setupToolbarButtonsEnabled(false)
        loadUsers()
        
        voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = Set<PKPushType>([.voIP])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let refreshControl = self.refreshControl, refreshControl.isRefreshing == true {
            let contentOffset = CGPoint(x: 0.0, y: -refreshControl.frame.size.height)
            tableView.setContentOffset(contentOffset, animated: false)
        }
        navigationController?.isToolbarHidden = false
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.isToolbarHidden = true
    }
    
    // MARK: - UI Configuration
    
    func configureTableViewController() {
        dataSource = UsersDataSource(currentUser: Core.instance.currentUser)
        
        CallKitManager.instance.usersDatasource = dataSource
        tableView.dataSource = dataSource
        tableView.rowHeight = 44
        refreshControl?.beginRefreshing()
    }
    
    
    func configureNavigationBar() {
        
        let settingsButtonItem = UIBarButtonItem(image: UIImage(named: "ic-settings"),
                                                 style: .plain,
                                                 target: self,
                                                 action: #selector(self.didPressSettingsButton(_:)))
        navigationItem.leftBarButtonItem = settingsButtonItem
        
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
        let roomNameRange: NSRange = (titleString as NSString).range(of: roomName)
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
        //Show tool bar
        navigationController?.isToolbarHidden = false
        //Set exclusive touch for tool bar
        if let subviews = navigationController?.toolbar.subviews {
            for subview in subviews {
                subview.isExclusiveTouch = true
            }
        }
    }
    
    /**
     *  Load all (Recursive) users for current room (tag)
     */
    
    @objc func loadUsers() {
        
        var t_request: ((_ page: QBGeneralResponsePage, _ allUsers: [QBUUser]) -> Void)?
        var allUsersTempArray = [QBUUser]()
        let request: ((QBGeneralResponsePage, [QBUUser]) -> Void) = { page, allUsers in
            guard  let currentUserTags = Core.instance.currentUser?.tags else {
                return }
            
            QBRequest.users(withTags: currentUserTags, page: page,
                            successBlock: { [weak self] response, page, users in
                                page.currentPage = page.currentPage + 1
                                allUsersTempArray = allUsers
                                allUsersTempArray.append(contentsOf: users)
                                
                                let isLastPage = page.currentPage * page.perPage >= page.totalEntries
                                if isLastPage == false {
                                    t_request?(page, allUsersTempArray)
                                } else {
                                    self?.refreshControl?.endRefreshing()
                                    let isUpdated = self?.dataSource.setUsers(allUsersTempArray)
                                    self?.tableView.reloadData()
                                    if isUpdated == true {
                                        self?.tableView.reloadData()
                                    }
                                    t_request = nil
                                }
                                
                                
                }, errorBlock: { response in
                    self.refreshControl?.endRefreshing()
                    t_request = nil
            })
        }
        
        t_request = request
        let allUsers: [QBUUser] = []
        request(QBGeneralResponsePage(currentPage: 1, perPage: UsersConstant.pageSize), allUsers)
    }
    
    
    // MARK: - Actions
    
    @IBAction func refresh(_ sender: UIRefreshControl?) {
        
        loadUsers()
    }
    
    @IBAction func didPressAudioCall(_ sender: UIBarButtonItem?) {
        call(with: QBRTCConferenceType.audio)
    }
    
    @IBAction func didPressVideoCall(_ sender: UIBarButtonItem?) {
        call(with: QBRTCConferenceType.video)
    }
    
    // MARK: - Internal Methods
    private func hasConnectivity() -> Bool {
        let status = core.networkConnectionStatus()
        guard status != NetworkConnectionStatus.notConnection else {
            showAlertView(message: UsersAlertConstant.checkInternet)
            return false
        }
        return true
    }
    
    private func showAlertView(message: String?) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: UsersAlertConstant.okAction, style: .default,
                                                handler: nil))
        present(alertController, animated: true)
    }
    
    @objc func didPressSettingsButton(_ item: UIBarButtonItem?) {
        
        performSegue(withIdentifier: UsersSegueConstant.settings, sender: item)
    }
    
    
    //MARK: - Overrides
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
        case UsersSegueConstant.settings:
            let settingsViewController = (segue.destination as? UINavigationController)?.topViewController
                as? SessionSettingsViewController
            settingsViewController?.delegate = self
            
        case UsersSegueConstant.call:
            debugPrint("UsersSegueConstant.call")
            
        default:
            break
        }
    }
    
    func call(with conferenceType: QBRTCConferenceType) {
        
        if session != nil {
            return
        }
        
        if hasConnectivity() {
            CallPermissions.check(with: conferenceType) { granted in
                if granted {
                    let opponentsIDs = self.dataSource.ids(forUsers: self.dataSource.selectedUsers)
                    //Create new session
                    let session = QBRTCClient.instance().createNewSession(withOpponents: opponentsIDs, with: conferenceType)
                    if session.id.isEmpty == false {
                        self.session = session
                        var uuid: UUID? = nil
                        if CallKitManager.isCallKitAvailable() == true {
                            uuid = UUID()
                            CallKitManager.instance.startCall(withUserIDs: opponentsIDs, session: session, uuid: uuid)
                        }
                        
                        if let callViewController = self.storyboard?.instantiateViewController(withIdentifier: UsersSegueConstant.call) as? CallViewController {
//                            callViewController.session = self.session
//                            callViewController.usersDataSource = self.dataSource
//                            callViewController.callUUID = uuid
                            
                            
                            self.nav = UINavigationController(rootViewController: callViewController)
                            
                            if let nav = self.nav {
                                nav.modalTransitionStyle = .crossDissolve
                                self.present(nav , animated: false)
                            }
                        }
                        
                        let opponentName = String(describing: self.core.currentUser?.fullName)
                        
                        let payload = ["message": "\(opponentName) is calling you.",
                            "ios_voip": "1", UsersConstant.voipEvent: "1"]
                        let data = try? JSONSerialization.data(withJSONObject: payload,
                                                               options: .prettyPrinted)
                        var message = ""
                        if let data = data {
                            message = String(data: data, encoding: .utf8) ?? ""
                        }
                        
                        let event = QBMEvent()
                        event.notificationType = QBMNotificationType.push
                        let arrayUserIDs = opponentsIDs.map({"\($0)"})
                        event.usersIDs = arrayUserIDs.joined(separator: ",")
                        event.type = QBMEventType.oneShot
                        event.message = message
                        
                        QBRequest.createEvent(event, successBlock: { response, events in
                            print("Send voip push - Success")
                        }, errorBlock: { response in
                            print("Send voip push - Error")
                        })
                        
                    } else {
                        SVProgressHUD.showError(withStatus: UsersAlertConstant.shouldLogin)
                    }
                }
            }
        }
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        dataSource.selectUser(at: indexPath)
        setupToolbarButtonsEnabled(dataSource.selectedUsers.count > 0)
        
        if dataSource.selectedUsers.count > 4 {
            videoCallButton.isEnabled = false
        }
        
        tableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .none)
    }
    
    // MARK: - CallKitDataSource
    
    func userName(forUserID userID: NSNumber, sender: Any?) -> String {
        
        let user = dataSource.user(withID: userID.uintValue)
        return user?.fullName ?? ""
    }
    
    // MARK: - Helpers
    
    func setupToolbarButtonsEnabled(_ enabled: Bool) {
        guard let toolbarItems = toolbarItems, toolbarItems.isEmpty == false else {
            return
        }
        for item in toolbarItems {
            item.isEnabled = enabled
        }
    }
}

extension UsersViewController: QBRTCClientDelegate {
    
    func didReceiveNewSession(_ session: QBRTCSession, userInfo: [String : String]? = nil) {
        if self.session != nil {
            session.rejectCall(["reject": "busy"])
            return
        }
        
        self.session = session
        
        if CallKitManager.isCallKitAvailable() == true {
            callUUID = UUID()
            var opponentIDs = [session.initiatorID]
            for userID in session.opponentsIDs {
                if userID.uintValue != core.currentUser?.id {
                    opponentIDs.append(userID)
                }
            }

            CallKitManager.instance.reportIncomingCall(withUserIDs: opponentIDs, session: session, uuid: callUUID, onAcceptAction: {

                if let callViewController = self.storyboard?.instantiateViewController(withIdentifier: UsersSegueConstant.call) as? CallViewController {
//                    callViewController.session = session
//                    callViewController.usersDataSource = self.dataSource
//                    callViewController.callUUID = self.callUUID
                    
                    
                    self.nav = UINavigationController(rootViewController: callViewController)
                    
                    if let nav = self.nav {
                        nav.modalTransitionStyle = .crossDissolve
                        self.present(nav , animated: false)
                    }
                }
                
            }, completion: { (end) in
                debugPrint("end")
            })
            
        } else {
            assert(nav == nil, "Invalid parameter not satisfying: !nav")
            
            if let incomingViewController = UIStoryboard(name: "Call", bundle: Bundle.main).instantiateViewController(withIdentifier: UsersSegueConstant.incoming) as? IncomingCallViewController {
//                incomingViewController.delegate = self
//                incomingViewController.session = session
//                incomingViewController.usersDatasource = dataSource
                nav = UINavigationController(rootViewController: incomingViewController)
                if let nav = self.nav {
                    present(nav, animated: false)
                }
            }
        }
    }
    
    func sessionDidClose(_ session: QBRTCSession) {
        
        if self.session == session {
            if backgroundTask != .invalid {
                UIApplication.shared.endBackgroundTask(backgroundTask)
                backgroundTask = UIBackgroundTaskIdentifier.invalid
            }
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                if UIApplication.shared.applicationState == .background && self.backgroundTask == .invalid {
                    // dispatching chat disconnect in 1 second so message about call end
                    // from webrtc does not cut mid sending
                    // checking for background task being invalid though, to avoid disconnecting
                    // from chat when another call has already being received in background
                    QBChat.instance.disconnect(completionBlock: nil)
                }
            })
            
            if let nav = self.nav {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                    nav.view.isUserInteractionEnabled = false
                    nav.dismiss(animated: false)
                    self.session = nil
                    self.nav = nil
                })
            } else if CallKitManager.isCallKitAvailable() == true {
                
                CallKitManager.instance.endCall(with: callUUID) {
                    debugPrint("endCall")
                }
                callUUID = nil
                self.session = nil
            }
        }
    }
}

extension UsersViewController: CoreDelegate {
    
    func coreDidLogin(_ core: Core) {
        SVProgressHUD.dismiss()
    }
    
    func coreDidLogout(_ core: Core) {
        SVProgressHUD.dismiss()
        //Dismiss Settings view controller
        dismiss(animated: false)
        DispatchQueue.main.async(execute: {
            self.navigationController?.popToRootViewController(animated: false)
        })
    }
    
    func core(_ core: Core, loginStatus: String) {
        SVProgressHUD.show(withStatus: loginStatus)
    }
    
    func core(_ core: Core, error: Error, domain: ErrorDomain) {
        guard domain == ErrorDomain.logOut else {
            return
        }
        SVProgressHUD.showError(withStatus: error.localizedDescription)
    }
}

extension UsersViewController: PKPushRegistryDelegate {
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        
        //  New way, only for updated backend
        guard let deviceIdentifier = UIDevice.current.identifierForVendor?.uuidString else {
            return
        }
        
        let subscription = QBMSubscription()
        subscription.notificationChannel = QBMNotificationChannel.APNSVOIP
        subscription.deviceUDID = deviceIdentifier
        subscription.deviceToken = voipRegistry.pushToken(for: .voIP)
        
        QBRequest.createSubscription(subscription, successBlock: { response, objects in
            print("Create Subscription request - Success")
        }, errorBlock: { response in
            print("Create Subscription request - Error")
        })
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        guard let deviceIdentifier = UIDevice.current.identifierForVendor?.uuidString else {
            return
        }
        
        QBRequest.unregisterSubscription(forUniqueDeviceIdentifier: deviceIdentifier, successBlock: { response in
            print("Unregister Subscription request - Success")
        }, errorBlock: { error in
            print("Unregister Subscription request - Error")
        })
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType) {
        if CallKitManager.isCallKitAvailable() == true {
            if payload.dictionaryPayload[UsersConstant.voipEvent] != nil {
                let application = UIApplication.shared
                if application.applicationState == .background && backgroundTask == .invalid {
                    backgroundTask = application.beginBackgroundTask(expirationHandler: {
                        application.endBackgroundTask(self.backgroundTask)
                        self.backgroundTask = UIBackgroundTaskIdentifier.invalid
                    })
                }
                if QBChat.instance.isConnected == false {
                    core.loginWithCurrentUser()
                }
            }
        }
    }
}

extension UsersViewController: SettingsViewControllerDelegate {
    // MARK: - SettingsViewControllerDelegate
    func settingsViewController(_ vc: SessionSettingsViewController, didPressLogout sender: Any) {
        SVProgressHUD.show(withStatus: UsersAlertConstant.logout)
        core.logout()
    }
}

//extension UsersViewController: IncomingCallViewControllerDelegate {
//    func incomingCallViewController(_ vc: IncomingCallViewController, didAccept session: QBRTCSession) {
//        if let callViewController = storyboard?.instantiateViewController(withIdentifier: UsersSegueConstant.call) as? CallViewController {
//            callViewController.session = session
//            callViewController.usersDataSource = dataSource
//            if let nav = self.nav {
//                nav.viewControllers = [callViewController]
//            }
//        }
//    }
//
//    func incomingCallViewController(_ vc: IncomingCallViewController, didReject session: QBRTCSession) {
//        session.rejectCall(nil)
//        if let nav = self.nav {
//            nav.dismiss(animated: false)
//            self.nav = nil
//        }
//    }
//
//}
