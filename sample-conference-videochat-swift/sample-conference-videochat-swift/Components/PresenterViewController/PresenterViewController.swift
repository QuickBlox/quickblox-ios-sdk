//
//  PresenterViewController.swift
//  sample-conference-videochat-swift
//
//  Created by Injoit on 1/27/20.
//  Copyright © 2020 quickBlox. All rights reserved.
//

import UIKit
import Quickblox
import QuickbloxWebRTC

class AuthNavigationController: UINavigationController { }
class DialogsNavigationController: UINavigationController { }
class CallNavigationController: UINavigationController { }
class ChatNavigationController: UINavigationController { }

class PresenterViewController: UIViewController {
    private var factory =  ScreenFactory()
    private var current: UIViewController!
    var conferenceSettings: ConferenceSettings?
    var chatVC = ChatViewController()
    var chatNavVC = ChatNavigationController()
    var callVC: ConferenceView?
    var callNavVC: CallNavigationController?
    
    lazy private var notificationsProvider: NotificationsProvider = {
        let notificationsProvider = NotificationsProvider()
        return notificationsProvider
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        notificationsProvider.delegate = self
        
        guard let splashVC = factory.makeSplashScreenOutput() as? SplashScreenViewController else {
            fatalError("splashVC has not been created")
        }
        splashVC.onSignIn = { [weak self] in
            self?.showLoginScreen()
        }
        
        splashVC.onCompleteAuth = { [weak self] in
            self?.showDialogsScreen()
        }
        current = splashVC
        changeCurrentViewController(current)
    }
    
    private func changeCurrentViewController(_ newCurrentViewController: UIViewController) {
        addChild(newCurrentViewController)
        newCurrentViewController.view.frame = view.bounds
        view.addSubview(newCurrentViewController.view)
        newCurrentViewController.didMove(toParent: self)
        
        if current == newCurrentViewController {
            return
        }
        current.willMove(toParent: nil)
        current.view.removeFromSuperview()
        current.removeFromParent()
        current = newCurrentViewController
    }
    
    private func showLoginScreen() {
        guard let authVC = factory.makeLoginOutput() as? AuthViewController else {
            return
        }
        authVC.onCompleteAuth = { [weak self] in
            self?.showDialogsScreen()
        }
        let authNavVC = AuthNavigationController(rootViewController: authVC)
        setupNavigationVC(authNavVC)
        changeCurrentViewController(authNavVC)
        
    }
    
    private func showDialogsScreen() {
        guard let dialogsVC = factory.makeDialogsOutput() as? DialogsViewController else {
            return
        }
        let dialogsScreen = DialogsNavigationController(rootViewController: dialogsVC)
        dialogsVC.onSignIn = { [weak self] in
            self?.showLoginScreen()
        }
        dialogsVC.onOpenChatScreenWithDialogID = { [weak self] (dialogID, isNewCreated) in
            self?.showChatScreen(dialogID, isNewCreated: isNewCreated)
        }
        setupNavigationVC(dialogsScreen)
        changeCurrentViewController(dialogsScreen)
        CallPermissions.check(with: .video, presentingViewController: self) { [weak self] granted in
            debugPrint("[CallPermissions] isGranted \(granted)")
            self?.notificationsProvider.registerForRemoteNotifications()
        }
    }
    
    private func showChatScreen(_ dialogID: String, isNewCreated: Bool = false) {
        guard let chatVC = factory.makeChatOutput() as? ChatViewController else {
            return
        }
        self.chatVC = chatVC
        chatVC.dialogID = dialogID
        let chatNavVC = ChatNavigationController(rootViewController: chatVC)
        self.chatNavVC = chatNavVC
        setupNavigationVC(chatNavVC)
        chatVC.didCloseChatVC = { [weak self] in
            self?.showDialogsScreen()
        }
        chatVC.didOpenCallScreenWithSettings = { [weak self] (settings) in
            if let settings = settings {
                if let callConferenceID = self?.callVC?.conferenceSettings.conferenceInfo.conferenceID {
                    if callConferenceID != settings.conferenceInfo.conferenceID  {
                        self?.showCallScreenWithSettings(settings)
                    } else {
                        self?.showCallScreen()
                    }
                } else {
                    self?.showCallScreenWithSettings(settings)
                }
            } else {
                self?.showCallScreen()
            }
        }
        changeCurrentViewController(chatNavVC)
        if isNewCreated == true {
            chatVC.sendAddOccupantsMessages([], action: .create)
        }
    }
    
    private func showChatScreenDidClosedCall(_ isClosedCall: Bool) {
        if current is ChatNavigationController {
            callVC = nil
            callNavVC = nil
            chatVC.action = nil
            
        } else if current is CallNavigationController {
            
            var newStack = [UIViewController]()
            let controllers = chatNavVC.viewControllers
            if controllers.count > 1 {
                controllers.forEach {
                    newStack.append($0)
                    if $0 is ChatViewController  {
                        chatNavVC.setViewControllers(newStack, animated: false)
                        return
                    }
                }
            }
            
            changeCurrentViewController(chatNavVC)
            if isClosedCall == true {
                callVC = nil
                callNavVC = nil
                chatVC.action = nil
            } else {
                chatVC.action = .chatFromCall
            }
        }
    }
    
    private func showCallScreenWithSettings(_ callSettings: ConferenceSettings) {
        let showCallScreenCompletion = { [weak self] (callVC: ConferenceView, callNavVC: CallNavigationController) -> Void in
            guard let self = self else {return}
            
            self.setupNavigationVC(callNavVC)
            callVC.conferenceSettings = callSettings
            callVC.didClosedCallScreen = { [weak self] isClosedCall in
                self?.showChatScreenDidClosedCall(isClosedCall)
            }
            
            self.changeCurrentViewController(callNavVC)
        }
        
        if let callConferenceID = callVC?.conferenceSettings.conferenceInfo.conferenceID {
            if callConferenceID != callSettings.conferenceInfo.conferenceID  {
                callVC?.leaveFromCallAnimated(false, completion: { [weak self] in
                    guard let self = self else {return}
                    
                    self.callVC = nil
                    self.callNavVC = nil
                    if callSettings.conferenceInfo.callType == MessageType.startConference.rawValue {
                        self.callVC = self.factory.makeConferenceOutput(withSettings: callSettings)
                    } else if callSettings.conferenceInfo.callType == MessageType.startStream.rawValue, callSettings.conferenceInfo.initiatorID == Profile().ID {
                        self.callVC = self.factory.makeStreamInitiatorOutput(withSettings: callSettings)
                    } else {
                        self.callVC = self.factory.makeStreamParticipantOutput(withSettings: callSettings)
                    }
                    guard let callVC = self.callVC else {return}
                    self.callNavVC = CallNavigationController(rootViewController: callVC as! UIViewController)
                    guard let callNav = self.callNavVC else {return}
                    
                    showCallScreenCompletion(callVC, callNav)
                })
            }
        } else if callVC == nil {
            if callSettings.conferenceInfo.callType == MessageType.startConference.rawValue {
                callVC = factory.makeConferenceOutput(withSettings: callSettings)
            } else if callSettings.conferenceInfo.callType == MessageType.startStream.rawValue, callSettings.conferenceInfo.initiatorID == Profile().ID {
                callVC = factory.makeStreamInitiatorOutput(withSettings: callSettings)
            } else {
                callVC = factory.makeStreamParticipantOutput(withSettings: callSettings)
            }
            
            guard let callVC = callVC else {return}
            callNavVC = CallNavigationController(rootViewController: callVC as! UIViewController)
            guard let callNav = callNavVC else {return}
            
            showCallScreenCompletion(callVC, callNav)
        }
    }
    
    private  func showCallScreen() {
        guard let callVC = self.callVC, let callNavVC = callNavVC else {return}
        
        var newStack = [UIViewController]()
        let controllers = callNavVC.viewControllers
        if controllers.count > 1 {
            controllers.forEach {
                newStack.append($0)
                if $0 is ConferenceView  {
                    callNavVC.setViewControllers(newStack, animated: false)
                    return
                }
            }
        }
        
        callVC.didClosedCallScreen = { [weak self] isClosedCall in
            self?.showChatScreenDidClosedCall(isClosedCall)
        }
        changeCurrentViewController(callNavVC)
    }
    
    private func handlePush() {
        callVC != nil ? showCallScreen() : showDialogsScreen()
    }
    
    private func setupNavigationVC(_ navigationVC: UINavigationController) {
        navigationVC.navigationBar.barStyle = .black
        navigationVC.navigationBar.barTintColor = #colorLiteral(red: 0.2216441333, green: 0.4713830948, blue: 0.9869660735, alpha: 1)
        navigationVC.navigationBar.shadowImage = #imageLiteral(resourceName: "navbar-shadow")
        navigationVC.navigationBar.tintColor = .white
        navigationVC.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension PresenterViewController: NotificationsProviderDelegate {
    func notificationsProvider(_ notificationsProvider: NotificationsProvider, didReceive dialogID: String) {
        if dialogID.isEmpty {
            return
        }
        handlePush()
    }
}
