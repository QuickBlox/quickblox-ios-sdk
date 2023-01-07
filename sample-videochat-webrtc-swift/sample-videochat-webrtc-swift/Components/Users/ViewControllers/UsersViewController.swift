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

struct UsersConstant {
    static let perPage:UInt = 100
    static let searchPerPage:UInt = 10
    static let noUsers = "No user with that name"
    static let subscriptionID = "last_voip_subscription_id"
    static let token = "last_voip_token"
    static let needUpdateToken = "last_voip_token_need_update"
    static let okAction = "Ok"
}

typealias CallHangUpAction = ((_ callId: String) -> Void)

class UsersViewController: UIViewController {
    //MARK: - IBOutlets
    @IBOutlet weak var searchBarView: SearchBarView!
    @IBOutlet weak var audioCallButton: UIButton!
    @IBOutlet weak var videoCallButton: UIButton!
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet weak var gradientView: CallGradientView! {
        didSet {
            gradientView.setupGradient(firstColor: UIColor(red: 0.96, green: 0.96, blue: 0.98, alpha: 1),
                                       secondColor: UIColor(red: 0.96, green: 0.96, blue: 0.98, alpha: 1).withAlphaComponent(0.0))
        }
    }
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var selectedUsersView: SelectedUsersView! {
        didSet {
            selectedUsersView.onSelectedUserViewCancelTapped = { [weak self] (userID) in
                
                guard let user = self?.users.selected.first(where: {$0.id == userID}) else {
                    return
                }
                self?.users.selected.remove(user)
                self?.current.removeSelectedUser(user)
            }
        }
    }
    
    //MARK: - Properties
    var onSignOut: (() -> Void)?
    private var users = Users()
    private var navigationTitleView = TitleView()
    private var voipRegistry: PKPushRegistry = PKPushRegistry(queue: DispatchQueue.main)
    private let callHelper = CallHelper()
    private var callViewController: CallViewController? = nil
    private var current: UserListViewController! {
        didSet {
            current.setupSelectedUsers(Array(users.selected))
            
            current.onSelectUser = { [weak self] (user, isSelected) in
                
                if isSelected == false {
                    self?.users.selected.remove(user)
                    self?.selectedUsersView.removeView(user.id)
                    return
                }
                if let countUsers = self?.users.selected.count, countUsers > 2 {
                    self?.showMaxCountAlert()
                    return
                }
                self?.users.selected.insert(user)
                self?.selectedUsersView.addView(user.id, userName: user.fullName ?? "QBUser")
            }
            
            current.onFetchedUsers = { [weak self] (users) in
                let profile = Profile()
                for user in users {
                    if user.id == profile.ID {
                        continue
                    }
                    self?.users.users[user.id] = user
                }
            }
        }
    }
    
    private let authModule = AuthModule()
    private let connection = ConnectionModule()
    private var splashVC: SplashScreenViewController? = nil
    
    private var isPresentAlert = false
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let fetchUsersViewController = Screen.userListViewController() else {
            return
        }
        current = fetchUsersViewController
        changeCurrentViewController(fetchUsersViewController)
        
        connection.delegate = self
        if connection.established == false {
            showSplashScreen()
        }
        connection.activateAutomaticMode()
        authModule.delegate = self
        
        callHelper.delegate = self
        
        voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = Set<PKPushType>([.voIP])
        
        searchBarView.delegate = self
        
        configureNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        CallPermissions.check(with: .video, presentingViewController: self) { granted in
            debugPrint("\(UsersViewController.className)] isGranted \(granted)")
        }
    }
    
    //MARK: - UI Configuration
    private func showFetchScreen() {
        guard let fetchUsersViewController = Screen.userListViewController() else {
            return
        }
        changeCurrentViewController(fetchUsersViewController)
    }
    
    private func showSearchScreen(withSearchText searchText: String) {
        guard let searchUsersViewController = Screen.searchUsersViewController() else {
            return
        }
        searchUsersViewController.searchText = searchText;
        changeCurrentViewController(searchUsersViewController)
    }
    
    private func changeCurrentViewController(_ newCurrentViewController: UserListViewController) {
        addChild(newCurrentViewController)
        newCurrentViewController.view.frame = containerView.bounds
        containerView.addSubview(newCurrentViewController.view)
        newCurrentViewController.didMove(toParent: self)
        if current == newCurrentViewController {
            return
        }
        current.willMove(toParent: nil)
        current.view.removeFromSuperview()
        current.removeFromParent()
        current = newCurrentViewController
    }
    
    private func configureNavigationBar() {
        let currentUser = Profile()
        guard currentUser.isFull  else {
            return
        }
        navigationTitleView.title = currentUser.fullName
        navigationItem.titleView = navigationTitleView
        addInfoButton()
    }
    
    //MARK: - Actions
    @IBAction func didTapLogout(_ sender: UIBarButtonItem) {
        logout()
    }
    
    private func logout() {
        if connection.established == false {
            showNoInternetAlert { [weak self] (action) in
                self?.connection.establish()
            }
            return
        }
        deleteLastSubscription { [weak self] in
            self?.connection.breakConnection {
                self?.authModule.logout()
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
            showNoInternetAlert { [weak self] (action) in
                self?.connection.establish()
            }
            return
        }
        if users.selected.count == 0 || users.selected.count > 3 {
            return
        }
        
        guard callHelper.registeredCallId?.isEmpty == true else {
            return
        }
        
        CallPermissions.check(with: conferenceType, presentingViewController: self) { [weak self] granted in
            guard let self = self, granted == true else {
                return
            }
            self.connection.activateCallMode()
            var callMembers: [NSNumber: String] = [:]
            for user in self.users.selected {
                callMembers[NSNumber(value: user.id)] = user.fullName ?? "User"
            }
            let hasVideo = conferenceType == .video
            self.callHelper.registerCall(withMembers: callMembers, hasVideo: hasVideo)
        }
    }
    
    private func showMaxCountAlert() {
        guard let maxCountAlertViewControllerVC = Screen.selectedUsersCountAlert() else {
            return
        }
        maxCountAlertViewControllerVC.modalPresentationStyle = .overFullScreen
        present(maxCountAlertViewControllerVC, animated: false)
    }
    
    //MARK: - Helper Methods
    fileprivate func showSplashScreen() {
        if splashVC == nil, let splashVC = Screen.splashScreenController() {
            self.splashVC = splashVC
            splashVC.modalPresentationStyle = .overCurrentContext
            self.present(splashVC, animated: false)
        }
    }
    
    fileprivate func hideSplashScreen() {
        if splashVC == nil {
            return
        }
        splashVC?.dismiss(animated: false, completion: {
            self.splashVC = nil
        })
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
        
        if callHelper.callReceived(sessionID) == true {
            // when a voip push is received with the same session
            // that has an active call at that moment
            debugPrint("\(#function) Received a voip push with the same session that has an active call at that moment")
            return
        }
        
        connection.activateCallMode()
        callHelper.registerCall(withPayload: dictionaryPayload, completion: completion)
        connection.activateAutomaticMode()
    }
}

// MARK: - CallHelperDelegate
extension UsersViewController: CallHelperDelegate {
    func helper(_ helper: CallHelper, didAcceptCall callId: String) {
        self.helper(helper, showCall: callId)
    }
    
    func helper(_ helper: CallHelper, didRegisterCall callId: String, mediaListener: MediaListener, mediaController: MediaController, direction: CallDirection, members: [NSNumber : String], hasVideo: Bool) {
        
        connection.activateCallMode()
        
        callViewController = hasVideo == true ? Screen.videoCallViewController() : Screen.audioCallViewController()
        
        callViewController?.setupWithCallId(callId, members: members, mediaListener: mediaListener, mediaController: mediaController, direction: direction)
        
        if direction == .outgoing {
            self.helper(helper, showCall: callId)
            return
        }
        let usersIDs = Array(members.keys)
        users.users(usersIDs) { [weak self] (users, error) in
            guard let self = self, let users = users else {
                return
            }
            var callMembers: [NSNumber : String] = [:]
            for user in users {
                callMembers[NSNumber(value: user.id)] = user.fullName ?? "User"
            }
            self.callViewController?.callInfo.updateWithMembers(callMembers)
            let title = Array(callMembers.values).joined(separator: ", ")
            helper.updateCall(callId, title: title)
        }
    }
    
    func helper(_ helper: CallHelper, didUnregisterCall callId: String) {
        connection.deactivateCallMode()
        guard let callViewController = callViewController else {
            return
        }
        
        callViewController.dismiss(animated: false) {
            self.callViewController = nil
        }
    }
    
    //Internal Method
    private func helper(_ helper: CallHelper, showCall callId: String) {
        guard let callViewController = self.callViewController,
              let callViewControllerCallId = callViewController.callInfo.callId,
              callViewControllerCallId == callId else {
            return
        }
        hideAlertView()
        hideSplashScreen()
        
        let navVC = UINavigationController(rootViewController: callViewController)
        navVC.modalPresentationStyle = .overFullScreen
        present(navVC, animated: false)
        
        current.removeSelectedUsers()
        users.selected.removeAll()
        selectedUsersView.clear()
        callViewController.hangUp = { (callId) in
            helper.unregisterCall(callId, userInfo: ["hangup": "hang up"])
        }
    }
}

// MARK: - UISearchBarDelegate
extension UsersViewController: SearchBarViewDelegate {
    func searchBarView(_ searchBarView: SearchBarView, didChangeSearchText searchText: String) {
        if let searchUsersViewController = current as? SearchUsersViewController {
            searchUsersViewController.searchText = searchText
        } else {
            if searchText.count > 2 {
                showSearchScreen(withSearchText: searchText)
            }
        }
    }
    
    func searchBarView(_ searchBarView: SearchBarView, didCancelSearchButtonTapped sender: UIButton) {
        showFetchScreen()
    }
}

// MARK: - AuthModuleDelegate
extension UsersViewController: AuthModuleDelegate {
    func authModule(_ authModule: AuthModule, didLoginUser user: QBUUser) {
        Profile.synchronize(withUser: user)
        connection.establish()
        let userDefaults = UserDefaults.standard
        guard userDefaults.bool(forKey: UsersConstant.needUpdateToken) != false,
              let token = userDefaults.object(forKey: UsersConstant.token) as? Data else {
            return
        }
        deleteLastSubscription { [weak self] in
            self?.createSubscription(withToken: token)
        }
    }
    
    func authModuleDidLogout(_ authModule: AuthModule) {
        connection.deactivateAutomaticMode()
        UserDefaults.standard.removeObject(forKey: UsersConstant.token)
        onSignOut?()
        Profile.clear()
    }
    
    func authModule(_ authModule: AuthModule, didReceivedError error: ErrorInfo) {
        showUnAuthorizeAlert(message: "\(error.statusCode) \(error.info)" , logoutAction: { [weak self] logoutAction in
            self?.logout()
        }, tryAgainAction: { [weak self] tryAgainAction in
            let profile = Profile()
            self?.authModule.login(fullName: profile.fullName, login: profile.login)
        })
    }
}

// MARK: - ConnectionModuleDelegate
extension UsersViewController: ConnectionModuleDelegate {
    func connectionModuleWillConnect(_ connectionModule: ConnectionModule) {
        showAnimatedAlertView(nil, message: ConnectionConstant.connectingState)
    }
    
    func connectionModuleDidConnect(_ connectionModule: ConnectionModule) {
        current.fetchUsers()
        navigationTitleView.textColor = .white
        hideAlertView()
        hideSplashScreen()
    }
    
    func connectionModuleDidNotConnect(_ connectionModule: ConnectionModule, error: Error) {
        hideSplashScreen()
        if error._code.isNetworkError {
            showNoInternetAlert { [weak self] (action) in
                self?.connection.establish()
            }
            return
        }
        showAlertView(nil, message: error.localizedDescription, handler: nil)
    }
    
    func connectionModuleWillReconnect(_ connectionModule: ConnectionModule) {
        showAnimatedAlertView(nil, message: ConnectionConstant.reconnectingState)
    }
    
    func connectionModuleDidReconnect(_ connectionModule: ConnectionModule) {
        current.fetchUsers()
        navigationTitleView.textColor = .white
        hideAlertView()
    }
    
    func connectionModuleTokenHasExpired(_ connectionModule: ConnectionModule) {
        showSplashScreen()
        let profile = Profile()
        authModule.login(fullName: profile.fullName, login: profile.login)
    }
}
