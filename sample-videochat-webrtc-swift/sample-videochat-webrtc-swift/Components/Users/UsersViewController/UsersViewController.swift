//
//  UsersViewController.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 28.01.2021.
//  Copyright © 2021 quickBlox. All rights reserved.
//

import UIKit
import Quickblox
import QuickbloxWebRTC
import PushKit
import SVProgressHUD

struct UsersConstant {
    static let perPage:UInt = 100
    static let noUsers = "No user with that name"
    static let subscriptionID = "last_voip_subscription_id"
    static let token = "last_voip_token"
    static let needUpdateToken = "last_voip_token_need_update"
    static let okAction = "Ok"
    static let noInternetCall = "Still in connecting state, please wait"
    static let noInternet = """
No Internet Connection
Make sure your device is connected to the internet
"""
}

typealias CallHangUpAction = ((_ callId: String) -> Void)

class UsersViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var usersView: UITableView! {
        didSet {
            usersView.register(UINib(nibName: UserCellConstant.reuseIdentifier, bundle: nil),
                               forCellReuseIdentifier: UserCellConstant.reuseIdentifier)
            usersView.allowsMultipleSelection = true
        }
    }
    @IBOutlet weak var searchBarView: SearchBarView!
    @IBOutlet weak var audioCallButton: UIButton!
    @IBOutlet weak var videoCallButton: UIButton!
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet weak var gradientView: CallGradientView! {
        didSet {
            gradientView.setupGradient(firstColor: #colorLiteral(red: 0.9565117955, green: 0.9645770192, blue: 0.9769250751, alpha: 1),
                                            secondColor: #colorLiteral(red: 0.9565117955, green: 0.9645770192, blue: 0.9769250751, alpha: 1).withAlphaComponent(0.0))
        }
    }

    //MARK: - Properties
    private var refreshControl: UIRefreshControl?
    private lazy var selectedUsersView: SelectedUsersView = {
        let selectedUsersView = SelectedUsersView.loadNib()
        return selectedUsersView
    }()
    private var navigationTitleView = TitleView()

    private var voipRegistry: PKPushRegistry = PKPushRegistry(queue: DispatchQueue.main)
    private let callHelper = CallHelper()
    private var callViewController: CallViewControllerProtocol? = nil
    
    private var usersDataSource: UsersDataSource! {
        didSet {
            usersDataSource.onSetDisplayedUsers = { [weak self] in
                self?.refreshControl?.endRefreshing()
                self?.usersView.reloadData()
                self?.usersView.isUserInteractionEnabled = true
            }
            usersDataSource.onSelectUser = { [weak self] (user, isSelected) in
                guard let self = self, let selectedUser = user else { return }
                
                if isSelected == false {
                    self.selectedUsersView.removeView(selectedUser.id)
                    return
                }
                
                self.selectedUsersView.addView(selectedUser.id, userName: selectedUser.fullName ?? "QBUser")
                
            }
            usersDataSource.onSearchNextUsers = { [weak self] in
                self?.usersDataSource.downloadUsers(self?.searchBarView.searchText ?? "")
            }
            usersDataSource.onChooseMoreUsers = { [weak self] in
                self?.showAMaxCountAlert()
            }
        }
    }
    
    private var connection: ConnectionModule! {
        didSet {
            connection.onStartAuthorization = { [weak self] in
                debugPrint("[\(UsersViewController.className)] [connection] On Start Authorization")
                DispatchQueue.main.async {
                    self?.navigationTitleView.textColor = .orange
                }
            }
            
            connection.onAuthorize = { [weak self] in
                debugPrint("[\(UsersViewController.className)] [connection] On Authorize")
                let userDefaults = UserDefaults.standard
                guard userDefaults.bool(forKey: UsersConstant.needUpdateToken) != false,
                      let token = userDefaults.object(forKey: UsersConstant.token) as? Data else {
                    return
                }
                self?.deleteLastSubscription {
                    self?.createSubscription(withToken: token)
                }
            }
            
            connection.onAuthorizeFailed = { [weak self] in
                debugPrint("[\(UsersViewController.className)] [connection] On Authorize Failed")
                self?.connection.deactivateAutomaticMode()
                self?.navigationController?.popToRootViewController(animated: false)
            }
            
            connection.onStartConnection = { [weak self] in
                debugPrint("[\(UsersViewController.className)] [connection] On Start Connection")
                DispatchQueue.main.async {
                    self?.navigationTitleView.textColor = .orange
                }
            }
            
            connection.onConnect = { [weak self] in
                self?.isPresentAlert = false
                debugPrint("[\(UsersViewController.className)] [connection] On Connect")
                DispatchQueue.main.async {
                    self?.navigationTitleView.textColor = .white
                }
                self?.usersView.isUserInteractionEnabled = false
                self?.loadUsers()
            }
            
            connection.onDisconnect = { [weak self] (isNetwork) in
                debugPrint("[\(UsersViewController.className)] [connection] On Disconnect")
                DispatchQueue.main.async {
                    self?.navigationTitleView.textColor = .orange
                }
                if isNetwork == true || self?.isPresentAlert == true { return }
                self?.isPresentAlert = true

                SVProgressHUD.showInfo(withStatus: UsersConstant.noInternet)
            }
        }
    }
    
    private var isPresentAlert = false
    
    //MARK: - Life Cycle
    private func configureNavigationBar() {
        let currentUser = Profile()
        guard currentUser.isFull  else { return }
        
        navigationTitleView.title = currentUser.fullName
        navigationItem.titleView = navigationTitleView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        connection = ConnectionModule()
        connection.activateAutomaticMode()
        
        callHelper.delegate = self
        
        voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = Set<PKPushType>([.voIP])
        
        usersDataSource = UsersDataSource()
        usersView.dataSource = usersDataSource
        usersView.delegate = usersDataSource
        
        searchBarView.delegate = usersDataSource
        
        gradientView.addSubview(selectedUsersView)
        selectedUsersView.translatesAutoresizingMaskIntoConstraints = false
        selectedUsersView.leftAnchor.constraint(equalTo: gradientView.leftAnchor, constant: 0.0).isActive = true
        selectedUsersView.topAnchor.constraint(equalTo: gradientView.topAnchor).isActive = true
        selectedUsersView.bottomAnchor.constraint(equalTo: gradientView.bottomAnchor).isActive = true
        selectedUsersView.rightAnchor.constraint(equalTo: audioCallButton.leftAnchor, constant: -6).isActive = true
        
        self.selectedUsersView.onSelectedUserViewCancelTapped = { [weak self] (userID) in
            guard let self = self else {return}
            if let indexUser = self.usersDataSource.displayedUsers.firstIndex(where: {$0.id == userID}) {
                let indexPath = IndexPath(row: indexUser, section: 0)
                self.usersView.deselectRow(at: indexPath, animated: false)
            }
            self.usersDataSource.removeSelectedUser(userID)
        }
        
        configureNavigationBar()
        addRefreshControl()
        addInfoButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        CallPermissions.check(with: .video, presentingViewController: self) { granted in
            debugPrint("\(UsersViewController.className)] isGranted \(granted)")
        }
        
        usersView.isUserInteractionEnabled = false
        if connection.established {
            loadUsers()
        }
        
        if let refreshControl = refreshControl, refreshControl.isRefreshing == true {
            let contentOffset = CGPoint(x: 0.0, y: -refreshControl.frame.size.height)
            usersView.setContentOffset(contentOffset, animated: false)
        }
    }
    
    //MARK: - Actions
    @IBAction func didTapLogout(_ sender: UIBarButtonItem) {
        if connection.established == false {
            SVProgressHUD.showInfo(withStatus: UsersConstant.noInternetCall)
            return
        }
        SVProgressHUD.show(withStatus: "Logouting...")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        deleteLastSubscription { [weak self] in
            self?.connection.breakConnection {
                guard let self = self else { return }
                SVProgressHUD.dismiss()
                self.connection.deactivateAutomaticMode()
                UserDefaults.standard.removeObject(forKey: UsersConstant.token)
                self.navigationController?.popToRootViewController(animated: false)
                SVProgressHUD.showSuccess(withStatus: "Complited")
                Profile.clear()
            }
        }
    }
    
    @IBAction func didPressAudioCall(_ sender: UIButton) {
        call(with: QBRTCConferenceType.audio)
    }
    
    @IBAction func didPressVideoCall(_ sender: UIButton) {
        call(with: QBRTCConferenceType.video)
    }
    
    private func call(with conferenceType: QBRTCConferenceType) {
        if connection.established == false {
            SVProgressHUD.showInfo(withStatus: UsersConstant.noInternetCall)
            return
        }
        if usersDataSource.selectedUsers.count == 0 || usersDataSource.selectedUsers.count > 3 {
            return
        }
        guard callHelper.registeredCallId?.isEmpty == true else { return }
        
        CallPermissions.check(with: conferenceType, presentingViewController: self) { [weak self] granted in
            guard let self = self, granted == true else { return }
            self.connection.activateCallMode()
            var callMembers: [NSNumber: String] = [:]
            for user in self.usersDataSource.selectedUsers {
                callMembers[NSNumber(value: user.id)] = user.fullName ?? "User"
            }
            let hasVideo = conferenceType == .video
            let userInfo = ["name": "Test",
                            "url" : "http.quickblox.com",
                            "param" : "\"1,2,3,4\""]
            self.callHelper.registerCall(withMembers: callMembers, hasVideo: hasVideo, userInfo: userInfo)
        }
    }
    
    private func showAMaxCountAlert() {
        guard let maxCountAlertViewControllerVC = Screen.selectedUsersCountAlert() else {
            return
        }
        maxCountAlertViewControllerVC.modalPresentationStyle = .overFullScreen
        present(maxCountAlertViewControllerVC, animated: false)
   }
    
    @objc private func loadUsers() {
        usersDataSource.downloadUsers()
    }
    
    private func addRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.tintColor = #colorLiteral(red: 0.4975875616, green: 0.5540842414, blue: 0.639736414, alpha: 1)
        refreshControl?.addTarget(self, action: #selector(loadUsers), for: .valueChanged)
        usersView.addSubview(refreshControl!)
        refreshControl?.beginRefreshing()
    }
}

// MARK: - PKPushRegistryDelegate
extension UsersViewController: PKPushRegistryDelegate {
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        guard let token = registry.pushToken(for: .voIP) else {
            return
        }
        let userDefaults = UserDefaults.standard
        if let lastToken = userDefaults.object(forKey: UsersConstant.token) as? Data,
           token == lastToken {
            return
        }
        userDefaults.setValue(token, forKey: UsersConstant.token)
        userDefaults.set(true, forKey: UsersConstant.needUpdateToken)
        if connection.tokenHasExpired {
            return
        }
        deleteLastSubscription { [weak self] in
            self?.createSubscription(withToken: token)
        }
    }
    
    private func deleteLastSubscription(withCompletion completion:@escaping () -> Void) {
        let userDefaults = UserDefaults.standard
        guard let lastSubscriptionId = userDefaults.object(forKey: UsersConstant.subscriptionID) as? NSNumber  else {
            completion()
            return
        }
        
        QBRequest.deleteSubscription(withID: lastSubscriptionId.uintValue) { (response) in
            userDefaults.removeObject(forKey: UsersConstant.subscriptionID)
            debugPrint("[\(UsersViewController.className)] \(#function) Unregister Subscription request - Success")
            completion()
        } errorBlock: { (response) in
            debugPrint("[\(UsersViewController.className)] \(#function) Unregister Subscription request - Error")
            completion()
        }
    }
    
    private func createSubscription(withToken token: Data) {
        guard let deviceUUID = UIDevice.current.identifierForVendor?.uuidString else {
            return
        }
        let userDefaults = UserDefaults.standard
        let subscription = QBMSubscription()
        subscription.notificationChannel = .APNSVOIP
        subscription.deviceUDID = deviceUUID
        subscription.deviceToken = token
        
        QBRequest.createSubscription(subscription, successBlock: { response, objects in
            guard let subscriptions = objects, subscriptions.isEmpty == false else {
                return
            }
            var newSubscription: QBMSubscription? = nil
            for subscription in subscriptions {
                if subscription.notificationChannel == .APNSVOIP,
                   let subscriptionsUIUD = subscription.deviceUDID,
                   subscriptionsUIUD == deviceUUID {
                    newSubscription = subscription
                }
            }
            guard let newSubscriptionID = newSubscription?.id else {
                return
            }
            userDefaults.setValue(NSNumber(value: newSubscriptionID), forKey: UsersConstant.subscriptionID)
            debugPrint("[\(UsersViewController.className)] \(#function) Create VOIP Subscription request - Success")
        }, errorBlock: { response in
            debugPrint("[\(UsersViewController.className)] \(#function) Create VOIP Subscription request - Error")
        })
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        deleteLastSubscription {
            debugPrint("[\(UsersViewController.className)] \(#function) Unregister Subscription request - Success")
        }
    }
    
    func pushRegistry(_ registry: PKPushRegistry,
                      didReceiveIncomingPushWith payload: PKPushPayload,
                      for type: PKPushType,
                      completion: @escaping () -> Void) {
        
        defer {
            completion()
        }

        guard (type == .voIP) else {
            return
        }
        
        guard let opponentsIDs = payload.dictionaryPayload["opponentsIDs"] as? String,
              let contactIdentifier = payload.dictionaryPayload["contactIdentifier"] as? String,
              let sessionID = payload.dictionaryPayload["sessionID"] as? String,
              let conferenceType = payload.dictionaryPayload["conferenceType"] as? String,
              let timestamp = payload.dictionaryPayload["timestamp"] as? String else {
            return
        }

        let dictionaryPayload = ["opponentsIDs": opponentsIDs,
                                 "contactIdentifier": contactIdentifier,
                                 "sessionID": sessionID,
                                 "conferenceType": conferenceType,
                                 "timestamp": timestamp
        ]
        
        if callHelper.isValid(sessionID) == false {
            // when a voip push is received with the same session
            // that has an active call at that moment
            debugPrint("\(#function) Received a voip push with the same session that has an active call at that moment")
            return
        }
        
        connection.activateCallMode()
        callHelper.registerCall(withPayload: dictionaryPayload, completion: completion)
        connection.establishConnection()
    }
}

// MARK: - CallHelperDelegate
extension UsersViewController: CallHelperDelegate {
    func helper(_ helper: CallHelper, didReciveIncomingCallWithMembers callMembers: [NSNumber], completion:@escaping (String) -> Void) {
        var members: [NSNumber : String] = [:]
        var newUsersIDs: [String] = []

        callMembers.forEach { (userID) in
            if let user = usersDataSource.user(withID: userID.uintValue) {
                members[userID] = user.fullName ?? userID.stringValue
            } else {
                members[userID] = userID.stringValue
                newUsersIDs.append(userID.stringValue)
            }
        }
        
        let contactIdentifier: (_ members: [NSNumber : String]) -> Void = { (members) in
            var membersNames: [String] = []
            callMembers.forEach { (userID) in
                membersNames.append(members[userID]!)
            }
            let contactIdentifier = membersNames.joined(separator: ",")
            completion(contactIdentifier)
        }
        
        if newUsersIDs.isEmpty {
            contactIdentifier(members)
            return
        }
        
        usersDataSource.downloadUsers(withIDs: newUsersIDs) { error, users, cancel in
            for user in users {
                members[NSNumber(value: user.id)] = user.fullName ?? "User"
            }
            contactIdentifier(members)
        }
    }
    
    func helper(_ helper: CallHelper, didAcceptCall callId: String) {
        self.helper(helper, showCall: callId)
    }
    
    func helper(_ helper: CallHelper, didRegisterCall callId: String, direction: CallDirection, members: [NSNumber : String], hasVideo: Bool) {
        
        connection.activateCallMode()
        
        guard let media = helper.media else { return }
        self.callViewController  = hasVideo == true ? Screen.videoCallViewController() : Screen.audioCallViewController()
        
        self.callViewController?.setupWithCallId(callId, members: members, media: media, direction: direction)
        
        if direction == .outgoing {
            self.helper(helper, showCall: callId)
        } else if direction == .incoming {
            let usersIDs = Array(members.keys).map({ $0.stringValue })
            usersDataSource.downloadUsers(withIDs: usersIDs) { error, users, cancel in
                var members: [NSNumber : String] = [:]
                for user in users {
                    members[NSNumber(value: user.id)] = user.fullName ?? "User"
                }
                self.callViewController?.update(withMembers: members)
                let title = Array(members.values).joined(separator: ", ")
                helper.updateCall(callId, title: title)
            }
        }
    }
    
    func helper(_ helper: CallHelper, didUnregisterCall callId: String, userInfo: [String : String]?) {
        connection.deactivateCallMode()
        guard let callViewController = callViewController else { return }
        callViewController.dismiss(animated: false) {
            self.callViewController = nil
        }
    }

    //Internal Method
    private func helper(_ helper: CallHelper, showCall callId: String) {
        guard let callViewController = self.callViewController,
              let callViewControllerCallId = callViewController.callInfo.callId,
              callViewControllerCallId == callId else { return }

        let navVC = UINavigationController(rootViewController: callViewController)
        navVC.modalPresentationStyle = .overFullScreen
        present(navVC, animated: false)
        
        usersDataSource.removeSelectedUsers()
        
        if let indexPathsForSelectedRows = usersView.indexPathsForSelectedRows {
            for indexPathForSelectedRow in indexPathsForSelectedRows {
                usersView.deselectRow(at: indexPathForSelectedRow, animated: false)
            }
        }
        
        selectedUsersView.clear()

        helper.onMute = { (enable) in
            callViewController.onMute(enable)
        }

        callViewController.hangUp = { (callId) in
            helper.unregisterCall(callId, userInfo: ["hangup": "hang up"])
        }
    }
}
