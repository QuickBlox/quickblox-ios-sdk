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
    static let answerInterval: TimeInterval = 10.0
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
    lazy private var navViewController: UINavigationController = {
        let navViewController = UINavigationController()
        return navViewController
        
    }()
    private var answerTimer: Timer?
    private var sessionID: String?
    private var isUpdatedPayload = true
    private weak var session: QBRTCSession?
    private var voipRegistry: PKPushRegistry = PKPushRegistry(queue: DispatchQueue.main)
    private var callUUID: UUID?
    lazy private var backgroundTask: UIBackgroundTaskIdentifier = {
        let backgroundTask = UIBackgroundTaskIdentifier.invalid
        return backgroundTask
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        QBRTCClient.instance().add(self)
        
        // Reachability
        if Reachability.instance.networkConnectionStatus() != NetworkConnectionStatus.notConnection {
            loadUsers()
        }
        
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
        
        //MARK: - Reachability
        let updateConnectionStatus: ((_ status: NetworkConnectionStatus) -> Void)? = { [weak self] status in
            let notConnection = status == .notConnection
            if notConnection == true {
                self?.cancelCallAlert()
            } else {
                self?.loadUsers()
            }
        }
        Reachability.instance.networkStatusBlock = { status in
            updateConnectionStatus?(status)
        }
        
        if let refreshControl = self.refreshControl, refreshControl.isRefreshing == true {
            let contentOffset = CGPoint(x: 0.0, y: -refreshControl.frame.size.height)
            tableView.setContentOffset(contentOffset, animated: false)
        }
        navigationController?.isToolbarHidden = false
        isUpdatedPayload = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        invalidateAnswerTimer()
        navigationController?.isToolbarHidden = true
    }
    
    // MARK: - UI Configuration
    private func setupAnswerTimerWithTimeInterval(_ timeInterval: TimeInterval) {
        if self.answerTimer != nil {
            self.answerTimer?.invalidate()
            self.answerTimer = nil
        }
        
        self.answerTimer = Timer.scheduledTimer(timeInterval: timeInterval,
                                                target: self,
                                                selector: #selector(endCallByTimer),
                                                userInfo: nil,
                                                repeats: false)
    }
    
    private func invalidateAnswerTimer() {
        if self.answerTimer != nil {
            self.answerTimer?.invalidate()
            self.answerTimer = nil
        }
    }
    
    @objc private func endCallByTimer() {
        invalidateAnswerTimer()
        
        if let endCall = CallKitManager.instance.currentCall() {
            CallKitManager.instance.endCall(with: endCall.uuid) {
                debugPrint("[UsersViewController] endCall sessionDidClose")
            }
        }
        prepareCloseCall()
    }
    
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
                    debugPrint("[UsersViewController] endCall func hasConnectivity")
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
                    let opponentsIDs: [NSNumber] = self.dataSource.ids(forUsers: self.dataSource.selectedUsers)
                    let opponentsNames: [String] = self.dataSource.selectedUsers.compactMap({ $0.fullName ?? $0.login })
                    
                    //Create new session
                    let session = QBRTCClient.instance().createNewSession(withOpponents: opponentsIDs, with: conferenceType)
                    if session.id.isEmpty == false {
                        self.session = session
                        self.sessionID = session.id
                        guard let uuid = UUID(uuidString: session.id) else {
                            return
                        }
                        self.callUUID = uuid
                        let profile = Profile()
                        guard profile.isFull == true else {
                            return
                        }
                        
                        CallKitManager.instance.startCall(withUserIDs: opponentsIDs, session: session, uuid: uuid)
                        
                        if let callViewController = self.storyboard?.instantiateViewController(withIdentifier: UsersSegueConstant.call) as? CallViewController {
                            callViewController.session = self.session
                            callViewController.usersDataSource = self.dataSource
                            callViewController.callUUID = uuid
                            callViewController.sessionConferenceType = conferenceType
                            let nav = UINavigationController(rootViewController: callViewController)
                            nav.modalTransitionStyle = .crossDissolve
                            nav.modalPresentationStyle = .fullScreen
                            self.present(nav , animated: false)
                            self.audioCallButton.isEnabled = false
                            self.videoCallButton.isEnabled = false
                            self.navViewController = nav
                        }
                        
                        let opponentsNamesString = opponentsNames.joined(separator: ",")
                        let allUsersNamesString = "\(profile.fullName)," + opponentsNamesString
                        let arrayUserIDs = opponentsIDs.map({"\($0)"})
                        let usersIDsString = arrayUserIDs.joined(separator: ",")
                        let allUsersIDsString = "\(profile.ID)," + usersIDsString
                        let opponentName = profile.fullName
                        let conferenceTypeString = conferenceType == .video ? "1" : "2"
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        let timeStamp = formatter.string(from: Date())
                        let payload = ["message": "\(opponentName) is calling you.",
                            "ios_voip": "1",
                            UsersConstant.voipEvent: "1",
                            "sessionID": session.id,
                            "opponentsIDs": allUsersIDsString,
                            "contactIdentifier": allUsersNamesString,
                            "conferenceType" : conferenceTypeString,
                            "timestamp" : timeStamp
                        ]
                        let data = try? JSONSerialization.data(withJSONObject: payload,
                                                               options: .prettyPrinted)
                        var message = ""
                        if let data = data {
                            message = String(data: data, encoding: .utf8) ?? ""
                        }
                        let event = QBMEvent()
                        event.notificationType = QBMNotificationType.push
                        event.usersIDs = usersIDsString
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
            
            CallKitManager.instance.endCall(with: self.callUUID) {
                debugPrint("[UsersViewController] endCall cancelCallAlert")
                
            }
            self.prepareCloseCall()
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
        if CallKitManager.instance.isCallStarted() == false,
            let sessionID = self.sessionID,
            sessionID == session.id,
            session.initiatorID == userID || isUpdatedPayload == false {
            CallKitManager.instance.endCall(with: callUUID)
            prepareCloseCall()
        }
    }
    
    func didReceiveNewSession(_ session: QBRTCSession, userInfo: [String : String]? = nil) {
        if self.session != nil {
            session.rejectCall(["reject": "busy"])
            return
        }
        invalidateAnswerTimer()
        
        self.session = session
        
        if let currentCall = CallKitManager.instance.currentCall() {
            //open by VOIP Push

            CallKitManager.instance.setupSession(session)
            if currentCall.status == .ended {
                CallKitManager.instance.setupSession(session)
                CallKitManager.instance.endCall(with: currentCall.uuid)
                session.rejectCall(["reject": "busy"])
                prepareCloseCall()
                } else {
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
                
                prepareCallerNameForOpponentIDs(opponentIDs) { (callerName) in
                    CallKitManager.instance.updateIncomingCall(withUserIDs: session.opponentsIDs,
                                                               outCallerName: callerName,
                                                               session: session,
                                                               uuid: currentCall.uuid)
                }
            }
        } else {
            //open by call
            
            if let uuid = UUID(uuidString: session.id) {
                callUUID = uuid
                sessionID = session.id
                
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
                
                prepareCallerNameForOpponentIDs(opponentIDs) { [weak self] (callerName) in
                    self?.reportIncomingCall(withUserIDs: opponentIDs,
                                             outCallerName: callerName,
                                             session: session,
                                             uuid: uuid)
                }
            }
        }
    }
    
    private func prepareCallerNameForOpponentIDs(_ opponentIDs: [NSNumber], completion: @escaping (String) -> Void)  {
        var callerName = ""
        var opponentNames = [String]()
        var newUsers = [String]()
        for userID in opponentIDs {
            
            // Getting recipient from users.
            if let user = dataSource.user(withID: userID.uintValue),
                let fullName = user.fullName {
                opponentNames.append(fullName)
            } else {
                newUsers.append(userID.stringValue)
            }
        }
        
        if newUsers.isEmpty == false {
            
            QBRequest.users(withIDs: newUsers, page: nil, successBlock: { [weak self] (respose, page, users) in
                if users.isEmpty == false {
                    self?.dataSource.update(users: users)
                    for user in users {
                        opponentNames.append(user.fullName ?? user.login ?? "")
                    }
                    callerName = opponentNames.joined(separator: ", ")
                    completion(callerName)
                }
            }) { (respose) in
                for userID in newUsers {
                    opponentNames.append(userID)
                }
                callerName = opponentNames.joined(separator: ", ")
                completion(callerName)
            }
        } else {
            callerName = opponentNames.joined(separator: ", ")
            completion(callerName)
        }
    }
    
    private func reportIncomingCall(withUserIDs userIDs: [NSNumber], outCallerName: String, session: QBRTCSession, uuid: UUID) {
        if hasConnectivity() {
            CallKitManager.instance.reportIncomingCall(withUserIDs: userIDs,
                                                       outCallerName: outCallerName,
                                                       session: session,
                                                       sessionID: session.id,
                                                       sessionConferenceType: session.conferenceType,
                                                       uuid: uuid,
                                                       onAcceptAction: { [weak self] (isAccept) in
                                                        guard let self = self else {
                                                            return
                                                        }
                                                        if isAccept == true {
                                                            self.openCall(withSession: session, uuid: uuid, sessionConferenceType: session.conferenceType)
                                                        } else {
                                                            debugPrint("[UsersViewController] endCall reportIncomingCall")
                                                        }
                                                        
                }, completion: { (isOpen) in
                    debugPrint("[UsersViewController] callKit did presented")
            })
        } else {
            
        }
    }
    
    private func openCall(withSession session: QBRTCSession?, uuid: UUID, sessionConferenceType: QBRTCConferenceType) {
        if hasConnectivity() {
            if let callViewController = self.storyboard?.instantiateViewController(withIdentifier: UsersSegueConstant.call) as? CallViewController {
                if let qbSession = session {
                    callViewController.session = qbSession
                }
                callViewController.usersDataSource = self.dataSource
                callViewController.callUUID = uuid
                callViewController.sessionConferenceType = sessionConferenceType
                self.navViewController = UINavigationController(rootViewController: callViewController)
                self.navViewController.modalPresentationStyle = .fullScreen
                self.navViewController.modalTransitionStyle = .crossDissolve
                self.present(self.navViewController, animated: false)
            } else {
                return
            }
        } else {
            return
        }
    }
    
    func sessionDidClose(_ session: QBRTCSession) {
        if let sessionID = self.session?.id,
            sessionID == session.id {
            if let endedCall = CallKitManager.instance.currentCall() {
                CallKitManager.instance.endCall(with: endedCall.uuid) {
                    debugPrint("[UsersViewController] endCall sessionDidClose")
                }
            }
            prepareCloseCall()
        }
    }
    
    private func prepareCloseCall() {
        if self.navViewController.presentingViewController?.presentedViewController == self.navViewController {
            self.navViewController.view.isUserInteractionEnabled = false
            self.navViewController.dismiss(animated: false)
        }
        self.callUUID = nil
        self.session = nil
        self.sessionID = nil
        if QBChat.instance.isConnected == false {
            self.connectToChat()
        }
        self.setupToolbarButtons()
    }
    
    private func connectToChat(success:QBChatCompletionBlock? = nil) {
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
                                        success?(error)
                                    } else {
                                        success?(nil)
                                        //did Login action
                                        SVProgressHUD.dismiss()
                                    }
        })
    }
}

extension UsersViewController: PKPushRegistryDelegate {
    // MARK: - PKPushRegistryDelegate
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        guard let voipToken = registry.pushToken(for: .voIP) else {
            return
        }
        guard let deviceIdentifier = UIDevice.current.identifierForVendor?.uuidString else {
            return
        }
        let subscription = QBMSubscription()
        subscription.notificationChannel = .APNSVOIP
        subscription.deviceUDID = deviceIdentifier
        subscription.deviceToken = voipToken
        
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
            UIApplication.shared.unregisterForRemoteNotifications()
            debugPrint("[UsersViewController] Unregister Subscription request - Success")
        }, errorBlock: { error in
            debugPrint("[UsersViewController] Unregister Subscription request - Error")
        })
    }
    
    func pushRegistry(_ registry: PKPushRegistry,
                      didReceiveIncomingPushWith payload: PKPushPayload,
                      for type: PKPushType,
                      completion: @escaping () -> Void) {
        
        let application = UIApplication.shared
        
        //in case of bad internet we check how long the VOIP Push was delivered for call(1-1)
        //if time delivery is more than “answerTimeInterval” - return
        if type == .voIP,
            payload.dictionaryPayload[UsersConstant.voipEvent] != nil {
            if let timeStampString = payload.dictionaryPayload["timestamp"] as? String,
                let opponentsIDsString = payload.dictionaryPayload["opponentsIDs"] as? String {
                let opponentsIDsArray = opponentsIDsString.components(separatedBy: ",")
                if opponentsIDsArray.count == 2 {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    if let startCallDate = formatter.date(from: timeStampString) {
                        if Date().timeIntervalSince(startCallDate) > QBRTCConfig.answerTimeInterval() {
                            debugPrint("[UsersViewController] timeIntervalSinceStartCall > QBRTCConfig.answerTimeInterval")
                            return
                        }
                    }
                }
            }
        }

        if type == .voIP,
            payload.dictionaryPayload[UsersConstant.voipEvent] != nil,
            application.applicationState == .background {
            var opponentsIDs: [String]? = nil
            var opponentsNumberIDs: [NSNumber] = []
            var opponentsNamesString = "incoming call. Connecting..."
            var sessionID: String? = nil
            var callUUID = UUID()
            var sessionConferenceType = QBRTCConferenceType.audio
            self.isUpdatedPayload = false
            
            if let opponentsIDsString = payload.dictionaryPayload["opponentsIDs"] as? String,
                let allOpponentsNamesString = payload.dictionaryPayload["contactIdentifier"] as? String,
                let sessionIDString = payload.dictionaryPayload["sessionID"] as? String,
                let callUUIDPayload = UUID(uuidString: sessionIDString) {
                self.isUpdatedPayload = true
                self.sessionID = sessionIDString
                sessionID = sessionIDString
                callUUID = callUUIDPayload
                if let conferenceTypeString = payload.dictionaryPayload["conferenceType"] as? String {
                    sessionConferenceType = conferenceTypeString == "1" ? QBRTCConferenceType.video : QBRTCConferenceType.audio
                }
                
                let profile = Profile()
                guard profile.isFull == true else {
                    return
                }
                let opponentsIDsArray = opponentsIDsString.components(separatedBy: ",")
                
                var opponentsNumberIDsArray = opponentsIDsArray.compactMap({NSNumber(value: Int($0)!)})
                var allOpponentsNamesArray = allOpponentsNamesString.components(separatedBy: ",")
                for i in 0...opponentsNumberIDsArray.count - 1 {
                    if opponentsNumberIDsArray[i].uintValue == profile.ID {
                        opponentsNumberIDsArray.remove(at: i)
                        allOpponentsNamesArray.remove(at: i)
                        break
                    }
                }
                opponentsNumberIDs = opponentsNumberIDsArray
                opponentsIDs = opponentsNumberIDs.compactMap({ $0.stringValue })
                opponentsNamesString = allOpponentsNamesArray.joined(separator: ", ")
            }
            
            let fetchUsersCompletion = { [weak self] (usersIDs: [String]?) -> Void in
                if let opponentsIDs = usersIDs {
                    QBRequest.users(withIDs: opponentsIDs, page: nil, successBlock: { [weak self] (respose, page, users) in
                        if users.isEmpty == false {
                            self?.dataSource.update(users: users)
                        }
                    }) { (response) in
                        debugPrint("[UsersViewController] error fetch usersWithIDs")
                    }
                }
            }

            self.setupAnswerTimerWithTimeInterval(QBRTCConfig.answerTimeInterval())
            CallKitManager.instance.reportIncomingCall(withUserIDs: opponentsNumberIDs,
                                                       outCallerName: opponentsNamesString,
                                                       session: nil,
                                                       sessionID: sessionID,
                                                       sessionConferenceType: sessionConferenceType,
                                                       uuid: callUUID,
                                                       onAcceptAction: { [weak self] (isAccept) in
                                                        guard let self = self else {
                                                            return
                                                        }
                                                        
                                                        if let session = self.session {
                                                            if isAccept == true {
                                                                self.openCall(withSession: session,
                                                                              uuid: callUUID,
                                                                              sessionConferenceType: sessionConferenceType)
                                                                debugPrint("[UsersViewController]  onAcceptAction")
                                                            } else {
                                                                session.rejectCall(["reject": "busy"])
                                                                debugPrint("[UsersViewController] endCallAction")
                                                            }
                                                        } else {
                                                            if isAccept == true {
                                                                self.openCall(withSession: nil,
                                                                              uuid: callUUID,
                                                                              sessionConferenceType: sessionConferenceType)
                                                                debugPrint("[UsersViewController]  onAcceptAction")
                                                            } else {
                                                                
                                                                debugPrint("[UsersViewController] endCallAction")
                                                            }
                                                            self.setupAnswerTimerWithTimeInterval(UsersConstant.answerInterval)
                                                            self.prepareBackgroundTask()
                                                        }
                                                        completion()
                                                        
                }, completion: { (isOpen) in
                    if QBChat.instance.isConnected == false {
                        self.connectToChat { (error) in
                            if error == nil {
                                fetchUsersCompletion(opponentsIDs)
                            }
                        }
                    } else {
                        fetchUsersCompletion(opponentsIDs)
                    }
                    self.setupAnswerTimerWithTimeInterval(QBRTCConfig.answerTimeInterval())
                    self.prepareBackgroundTask()
                    debugPrint("[UsersViewController] callKit did presented")
            })
        }
    }
    
    private func prepareBackgroundTask() {
        let application = UIApplication.shared
        if application.applicationState == .background && self.backgroundTask == .invalid {
            self.backgroundTask = application.beginBackgroundTask(expirationHandler: {
                application.endBackgroundTask(self.backgroundTask)
                self.backgroundTask = UIBackgroundTaskIdentifier.invalid
            })
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
            SVProgressHUD.showError(withStatus: "Error")
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
            UIApplication.shared.unregisterForRemoteNotifications()
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
