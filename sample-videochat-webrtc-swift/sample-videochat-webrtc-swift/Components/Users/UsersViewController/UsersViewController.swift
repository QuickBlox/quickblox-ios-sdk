//
//  UsersViewController.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 12/10/18.
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
    static let shouldLogin = NSLocalizedString("You should login to use VideoChat API. Session hasn’t been created. Please try to relogin.", comment: "")
    static let logout = NSLocalizedString("Logout...", comment: "")
}

struct UsersSegueConstant {
    static let settings = "PresentSettingsViewController"
    static let call = "CallViewController"
    static let sceneAuth = "SceneSegueAuth"
}

class UsersViewController: UITableViewController {
    
    //MARK: - IBOutlets
    @IBOutlet private weak var audioCallButton: UIBarButtonItem!
    @IBOutlet private weak var videoCallButton: UIBarButtonItem!
    
    //MARK: - Properties
    lazy private var dataSource: UsersDataSource = {
        let dataSource = UsersDataSource()
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
        
        QBRTCClient.instance().add(self)
        
        // adding refresh control task
        if let refreshControl = self.refreshControl {
            refreshControl.addTarget(self, action: #selector(loadUsers), for: .valueChanged)
        }
        configureNavigationBar()
        configureTableViewController()
        setupToolbarButtonsEnabled(false)
        voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = Set<PKPushType>([.voIP])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Reachability
        if Reachability.instance.networkConnectionStatus() != NetworkConnectionStatus.notConnection {
            loadUsers()
        }
        
        if let refreshControl = self.refreshControl, refreshControl.isRefreshing == true {
            let contentOffset = CGPoint(x: 0.0, y: -refreshControl.frame.size.height)
            tableView.setContentOffset(contentOffset, animated: false)
        }
        navigationController?.isToolbarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.isToolbarHidden = true
    }
    
    // MARK: - UI Configuration
    private func configureTableViewController() {
        dataSource = UsersDataSource()
        CallKitManager.instance.usersDatasource = dataSource
        tableView.dataSource = dataSource
        tableView.rowHeight = 44
        refreshControl?.beginRefreshing()
    }
    
    private func configureNavigationBar() {
        let settingsButtonItem = UIBarButtonItem(image: UIImage(named: "ic-settings"),
                                                 style: .plain,
                                                 target: self,
                                                 action: #selector(self.didPressSettingsButton(_:)))
        navigationItem.leftBarButtonItem = settingsButtonItem
        //add info button
        showInfoButton()
        
        //Custom label
        var loggedString = "Logged in as "
        var roomName = ""
        var titleString = ""
        let profile = Profile()
        
        if profile.isFull == true  {
            let fullname = profile.fullName
            titleString = loggedString + fullname
            let tags = profile.tags
            if  tags?.isEmpty == false,
                let name = tags?.first {
                roomName = name
                loggedString = loggedString + fullname
                titleString = roomName + "\n" + loggedString
            }
        }
        
        let attrString = NSMutableAttributedString(string: titleString)
        let roomNameRange: NSRange = (titleString as NSString).range(of: roomName)
        attrString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 16.0), range: roomNameRange)
        
        let userNameRange: NSRange = (titleString as NSString).range(of: loggedString)
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
        let firstPage = QBGeneralResponsePage(currentPage: 1, perPage: 100)
        QBRequest.users(withExtendedRequest: ["order": "desc date updated_at"],
                        page: firstPage,
                        successBlock: { [weak self] (response, page, users) in
                            self?.dataSource.update(users: users)
                            self?.tableView.reloadData()
                            self?.refreshControl?.endRefreshing()
                            
            }, errorBlock: { response in
                self.refreshControl?.endRefreshing()
                debugPrint("[UsersViewController] loadUsers error: \(self.errorMessage(response: response) ?? "")")
        })
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
        
        let status = Reachability.instance.networkConnectionStatus()
        guard status != NetworkConnectionStatus.notConnection else {
            showAlertView(message: UsersAlertConstant.checkInternet)
            if CallKitManager.instance.isCallStarted() == false {
                CallKitManager.instance.endCall(with: callUUID) {
                    debugPrint("[UsersViewController] endCall")
                }
            }
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
        let settingsStoryboard =  UIStoryboard(name: "Settings", bundle: nil)
        if let settingsController = settingsStoryboard.instantiateViewController(withIdentifier: "SessionSettingsViewController") as? SessionSettingsViewController {
            settingsController.delegate = self
            navigationController?.pushViewController(settingsController, animated: true)
        }
    }
    
    //MARK: - Overrides
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case UsersSegueConstant.settings:
            let settingsViewController = (segue.destination as? UINavigationController)?.topViewController
                as? SessionSettingsViewController
            settingsViewController?.delegate = self
        case UsersSegueConstant.call:
            debugPrint("[UsersViewController] UsersSegueConstant.call")
        default:
            break
        }
    }
    
    private func call(with conferenceType: QBRTCConferenceType) {
        
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
                        let uuid = UUID()
                        CallKitManager.instance.startCall(withUserIDs: opponentsIDs, session: session, uuid: uuid)
                        if let callViewController = self.storyboard?.instantiateViewController(withIdentifier: UsersSegueConstant.call) as? CallViewController {
                            callViewController.session = self.session
                            callViewController.usersDataSource = self.dataSource
                            callViewController.callUUID = uuid
                            self.nav = UINavigationController(rootViewController: callViewController)
                            if let nav = self.nav {
                                nav.modalTransitionStyle = .crossDissolve
                                self.present(nav , animated: false)
                                self.audioCallButton.isEnabled = false
                                self.videoCallButton.isEnabled = false
                            }
                        }
                        let profile = Profile()
                        guard profile.isFull == true else {
                            return
                        }
                        let opponentName = profile.fullName.isEmpty == false ? profile.fullName : "Unknown user"
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
                            debugPrint("[UsersViewController] Send voip push - Success")
                        }, errorBlock: { response in
                            debugPrint("[UsersViewController] Send voip push - Error")
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
        setupToolbarButtons()
        tableView.reloadData()
    }
    
    // MARK: - Helpers
    private func setupToolbarButtonsEnabled(_ enabled: Bool) {
        guard let toolbarItems = toolbarItems, toolbarItems.isEmpty == false else {
            return
        }
        for item in toolbarItems {
            item.isEnabled = enabled
        }
    }
    
    private func setupToolbarButtons() {
        setupToolbarButtonsEnabled(dataSource.selectedUsers.count > 0)
        if dataSource.selectedUsers.count > 4 {
            videoCallButton.isEnabled = false
        }
    }
    
    private func cancelCallAlert() {
        let alert = UIAlertController(title: UsersAlertConstant.checkInternet, message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .cancel) { (action) in
            
        }
        alert.addAction(cancelAction)
        present(alert, animated: false) {
        }
    }
    
    //Handle Error
    private func errorMessage(response: QBResponse) -> String? {
        var errorMessage : String
        if response.status.rawValue == 502 {
            errorMessage = "Bad Gateway, please try again"
        } else if response.status.rawValue == 0 {
            errorMessage = "Connection network error, please try again"
        } else {
            guard let qberror = response.error,
                let error = qberror.error else {
                    return nil
            }
            
            errorMessage = error.localizedDescription.replacingOccurrences(of: "(",
                                                                           with: "",
                                                                           options:.caseInsensitive,
                                                                           range: nil)
            errorMessage = errorMessage.replacingOccurrences(of: ")",
                                                             with: "",
                                                             options: .caseInsensitive,
                                                             range: nil)
        }
        return errorMessage
    }
}

// MARK: - QBRTCClientDelegate
extension UsersViewController: QBRTCClientDelegate {
    
    func session(_ session: QBRTCSession, hungUpByUser userID: NSNumber, userInfo: [String : String]? = nil) {
        if CallKitManager.instance.isCallStarted() == false {
            CallKitManager.instance.endCall(with: callUUID) {
                debugPrint("[UsersViewController] endCall")
            }
        }
    }
    
    func didReceiveNewSession(_ session: QBRTCSession, userInfo: [String : String]? = nil) {
        if self.session != nil {
            session.rejectCall(["reject": "busy"])
            return
        }
        
        self.session = session
        callUUID = UUID()
        var opponentIDs = [session.initiatorID]
        let profile = Profile()
        guard profile.isFull == true else {
            return
        }
        for userID in session.opponentsIDs {
            if userID.uintValue != profile.ID {
                opponentIDs.append(userID)
            }
        }
        
        var callerName = ""
        var opponentNames = [String]()
        var newUsers = [NSNumber]()
        for userID in opponentIDs {
            
            // Getting recipient from users.
            if let user = dataSource.user(withID: userID.uintValue),
                let fullName = user.fullName {
                opponentNames.append(fullName)
            } else {
                newUsers.append(userID)
            }
        }
        
        if newUsers.isEmpty == false {
            let loadGroup = DispatchGroup()
            for userID in newUsers {
                loadGroup.enter()
                dataSource.loadUser(userID.uintValue) { (user) in
                    if let user = user {
                        opponentNames.append(user.fullName ?? user.login ?? "")
                    } else {
                        opponentNames.append("\(userID)")
                    }
                    loadGroup.leave()
                }
            }
            loadGroup.notify(queue: DispatchQueue.main) {
                callerName = opponentNames.joined(separator: ", ")
                self.reportIncomingCall(withUserIDs: opponentIDs, outCallerName: callerName, session: session, uuid: self.callUUID)
            }
        } else {
            callerName = opponentNames.joined(separator: ", ")
            self.reportIncomingCall(withUserIDs: opponentIDs, outCallerName: callerName, session: session, uuid: self.callUUID)
        }
    }
    
    private func reportIncomingCall(withUserIDs userIDs: [NSNumber], outCallerName: String, session: QBRTCSession?, uuid: UUID?) {
        if hasConnectivity() {
            CallKitManager.instance.reportIncomingCall(withUserIDs: userIDs,
                                                       outCallerName: outCallerName,
                                                       session: session,
                                                       uuid: self.callUUID,
                                                       onAcceptAction: { [weak self] in
                                                        guard let self = self else {
                                                            return
                                                        }
                                                        
                                                        if let callViewController = self.storyboard?.instantiateViewController(withIdentifier: UsersSegueConstant.call) as? CallViewController {
                                                            callViewController.session = session
                                                            callViewController.usersDataSource = self.dataSource
                                                            callViewController.callUUID = self.callUUID
                                                            self.nav = UINavigationController(rootViewController: callViewController)
                                                            if let nav = self.nav {
                                                                nav.modalTransitionStyle = .crossDissolve
                                                                self.present(nav , animated: false)
                                                            }
                                                        }
                }, completion: { (end) in
                    debugPrint("[UsersViewController] endCall")
            })
        } else {
            
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
                    self.setupToolbarButtons()
                })
                
            } else {
                
                CallKitManager.instance.endCall(with: callUUID) {
                    debugPrint("[UsersViewController] endCall")
                }
                callUUID = nil
                self.session = nil
                setupToolbarButtons()
            }
        }
    }
}

extension UsersViewController: PKPushRegistryDelegate {
    // MARK: - PKPushRegistryDelegate
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        //  New way, only for updated backend
        guard let deviceIdentifier = UIDevice.current.identifierForVendor?.uuidString else {
            return
        }
        let subscription = QBMSubscription()
        subscription.notificationChannel = .APNSVOIP
        subscription.deviceUDID = deviceIdentifier
        subscription.deviceToken = voipRegistry.pushToken(for: .voIP)
        
        QBRequest.createSubscription(subscription, successBlock: { response, objects in
            debugPrint("[UsersViewController] Create Subscription request - Success")
        }, errorBlock: { response in
            debugPrint("[UsersViewController] Create Subscription request - Error")
        })
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        guard let deviceIdentifier = UIDevice.current.identifierForVendor?.uuidString else {
            return
        }
        QBRequest.unregisterSubscription(forUniqueDeviceIdentifier: deviceIdentifier, successBlock: { response in
            debugPrint("[UsersViewController] Unregister Subscription request - Success")
        }, errorBlock: { error in
            debugPrint("[UsersViewController] Unregister Subscription request - Error")
        })
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType) {
        if payload.dictionaryPayload[UsersConstant.voipEvent] != nil {
            let application = UIApplication.shared
            if application.applicationState == .background && backgroundTask == .invalid {
                backgroundTask = application.beginBackgroundTask(expirationHandler: {
                    application.endBackgroundTask(self.backgroundTask)
                    self.backgroundTask = UIBackgroundTaskIdentifier.invalid
                })
            }
            if QBChat.instance.isConnected == false {
                let profile = Profile()
                guard profile.isFull == true else {
                    return
                }
                
                QBChat.instance.connect(withUserID: profile.ID,
                                        password: LoginConstant.defaultPassword,
                                        completion: { [weak self] error in
                                            guard let self = self else { return }
                                            if let error = error {
                                                if error._code == QBResponseStatusCode.unAuthorized.rawValue {
                                                    self.logoutAction()
                                                } else {
                                                    debugPrint("[UsersViewController] login error response:\n \(error.localizedDescription)")
                                                }
                                            } else {
                                                //did Login action
                                                SVProgressHUD.dismiss()
                                            }
                })
            }
        }
    }
}

// MARK: - SettingsViewControllerDelegate
extension UsersViewController: SettingsViewControllerDelegate {
    func settingsViewController(_ vc: SessionSettingsViewController, didPressLogout sender: Any) {
        logoutAction()
    }
    
    private func logoutAction() {
        if QBChat.instance.isConnected == false {
            SVProgressHUD.showError(withStatus: "It is not connected.")
            return
        }
        SVProgressHUD.show(withStatus: UsersAlertConstant.logout)
        SVProgressHUD.setDefaultMaskType(.clear)
        
        guard let identifierForVendor = UIDevice.current.identifierForVendor else {
            return
        }
        let uuidString = identifierForVendor.uuidString
        #if targetEnvironment(simulator)
        disconnectUser()
        #else
        QBRequest.subscriptions(successBlock: { (response, subscriptions) in
            
            if let subscriptions = subscriptions {
                for subscription in subscriptions {
                    if let subscriptionsUIUD = subscriptions.first?.deviceUDID,
                        subscriptionsUIUD == uuidString,
                        subscription.notificationChannel == .APNSVOIP {
                        self.unregisterSubscription(forUniqueDeviceIdentifier: uuidString)
                        return
                    }
                }
            }
            self.disconnectUser()
            
        }) { response in
            if response.status.rawValue == 404 {
                self.disconnectUser()
            }
        }
        #endif
    }
    
    private func disconnectUser() {
        QBChat.instance.disconnect(completionBlock: { error in
            if let error = error {
                SVProgressHUD.showError(withStatus: error.localizedDescription)
                return
            }
            self.logOut()
        })
    }
    
    private func unregisterSubscription(forUniqueDeviceIdentifier uuidString: String) {
        QBRequest.unregisterSubscription(forUniqueDeviceIdentifier: uuidString, successBlock: { response in
            self.disconnectUser()
        }, errorBlock: { error in
            if let error = error.error {
                SVProgressHUD.showError(withStatus: error.localizedDescription)
                return
            }
            SVProgressHUD.dismiss()
        })
    }
    
    private func logOut() {
        QBRequest.logOut(successBlock: { [weak self] response in
            //ClearProfile
            Profile.clearProfile()
            SVProgressHUD.dismiss()
            //Dismiss Settings view controller
            self?.dismiss(animated: false)
            
            DispatchQueue.main.async(execute: {
                self?.navigationController?.popToRootViewController(animated: false)
            })
        }) { response in
            debugPrint("QBRequest.logOut error\(response)")
        }
    }
}
