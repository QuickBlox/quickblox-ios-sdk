//
//  ChatParentVC.swift
//  sample-conference-videochat-swift
//
//  Created by Injoit on 02.07.2020.
//  Copyright © 2020 QuickBlox. All rights reserved.
//

import UIKit
import Quickblox
import QuickbloxWebRTC

class CallNavigationController: UINavigationController { }
class ChatNavigationController: UINavigationController { }

class ChatParentVC: UIViewController {
    var current = UINavigationController()
    var callSettings: CallSettings?
    var dialogID: String!
    var chatVC = ChatViewController()
    var chatNavVC = ChatNavigationController()
    var callVC: CallViewController?
    var callNavVC: CallNavigationController?
    
    init(dialogID: String) {
        let storyboard = UIStoryboard(name: "Chat", bundle: nil)
        chatVC = (storyboard.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController)
        self.dialogID = dialogID
        chatVC.dialogID = dialogID
        let chatNavVC = ChatNavigationController(rootViewController: chatVC)
        self.chatNavVC = chatNavVC
        current = chatNavVC
        super.init(nibName:  nil, bundle: nil)
        setupNavigationVC(chatNavVC)
        chatVC.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        debugPrint("ChatParentVC deinit")
        NotificationCenter.default.removeObserver(self, name: CallConstants.didRecivePushAndOpenCallChatNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(goToChatFromCallNotification(_:)),
                                               name: CallConstants.didRecivePushAndOpenCallChatNotification,
                                               object: nil)
        
        chatVC.dialogID = dialogID
        chatVC.delegate = self
        
        addChild(current)
        current.view.frame = view.bounds
        view.addSubview(current.view)
        current.didMove(toParent: self)
    }
    
    @objc func goToChatFromCallNotification(_ notification: Notification?) {
        if current is CallNavigationController {
            let controllers = current.viewControllers
            var newStack = [UIViewController]()
            
            //change stack by replacing view controllers after CallViewController
            controllers.forEach{
                newStack.append($0)
                if $0 is CallViewController {
                    current.setViewControllers(newStack, animated: true)
                    return
                }
            }
            showChatScreenDidClosedCall(false)
            
        } else if current is ChatNavigationController {
            let controllers = current.viewControllers
            var newStack = [UIViewController]()
            
            //change stack by replacing view controllers after CallViewController
            controllers.forEach{
                newStack.append($0)
                if $0 is ChatViewController {
                    current.setViewControllers(newStack, animated: true)
                    return
                }
            }
        }
    }
    
    func initChatVC() -> ChatViewController {
        let storyboard = UIStoryboard(name: "Chat", bundle: nil)
        guard let chatVC = storyboard.instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController else {return ChatViewController()}
        return chatVC
    }
    
    func initCallVC() -> CallViewController {
        let storyboard = UIStoryboard(name: "Call", bundle: nil)
        guard let callVC = storyboard.instantiateViewController(withIdentifier: "CallViewController") as? CallViewController else {return CallViewController()}
        return callVC
    }
    
    func showChatScreenDidClosedCall(_ isClosedCall: Bool) {
        if current is ChatNavigationController {
            callVC = nil
            callNavVC = nil
            chatVC.action = nil
        } else if current is CallNavigationController {
            
            addChild(chatNavVC)
            chatNavVC.view.frame = view.bounds
            view.addSubview(chatNavVC.view)
            chatNavVC.didMove(toParent: self)
            
            current.willMove(toParent: nil)
            current.view.removeFromSuperview()
            current.removeFromParent()
            if isClosedCall == true {
                callVC = nil
                callNavVC = nil
                chatVC.action = nil
            } else {
                chatVC.action = .ChatFromCall
            }
            current = chatNavVC
        }
    }
    
    func showCallScreenWithSettings(_ callSettings: CallSettings) {
        
        let showCallScreenCompletion = { [weak self] (callVC: CallViewController, callNavVC: CallNavigationController) -> Void in
            guard let self = self else {return}
            
            self.setupNavigationVC(callNavVC)
            callVC.callSettings = callSettings
            callVC.delegate = self
            
            self.addChild(callNavVC)
            callNavVC.view.frame = self.view.bounds
            self.view.addSubview(callNavVC.view)
            callNavVC.didMove(toParent: self)
            
            self.current.willMove(toParent: nil)
            self.current.view.removeFromSuperview()
            self.current.removeFromParent()
            self.current = callNavVC
        }
        
        if let callConferenceID = callVC?.conferenceID {
            if callConferenceID != callSettings.conferenceID  {
                callVC?.leaveFromCallAnimated(false, isSetupNewCall: true, completion: { [weak self] in
                    guard let self = self else {return}
                    
                    self.callVC = nil
                    self.callNavVC = nil
                    self.callVC = self.initCallVC()
                    guard let callVC = self.callVC else {return}
                    self.callNavVC = CallNavigationController(rootViewController: callVC)
                    guard let callNav = self.callNavVC else {return}
                    
                    showCallScreenCompletion(callVC, callNav)
                })
            }
        } else if callVC == nil {
            callVC = initCallVC()
            guard let callVC = callVC else {return}
            callNavVC = CallNavigationController(rootViewController: callVC)
            guard let callNav = callNavVC else {return}
            
            showCallScreenCompletion(callVC, callNav)
        }
    }
    
    func showCallScreen() {
        guard let callVC = self.callVC, let callNavVC = callNavVC else {return}
        callVC.delegate = self
        
        addChild(callNavVC)
        callNavVC.view.frame = view.bounds
        view.addSubview(callNavVC.view)
        callNavVC.didMove(toParent: self)
        
        current.willMove(toParent: nil)
        current.view.removeFromSuperview()
        current.removeFromParent()
        current = callNavVC
    }
    
    private func setupNavigationVC(_ navigationVC: UINavigationController) {
        navigationVC.navigationBar.barStyle = .black
        navigationVC.navigationBar.barTintColor = #colorLiteral(red: 0.2216441333, green: 0.4713830948, blue: 0.9869660735, alpha: 1)
        navigationVC.navigationBar.tintColor = .white
        navigationVC.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension ChatParentVC: ChildChatVCDelegate {
    func chatVC(_ chatVC: ChatViewController, didOpenCallScreenWithSettings settings: CallSettings?) {
        if let settings = settings {
            if let callConferenceID = callVC?.conferenceID {
                if callConferenceID != settings.conferenceID  {
                    showCallScreenWithSettings(settings)
                } else {
                    showCallScreen()
                }
            } else {
                showCallScreenWithSettings(settings)
            }
        } else {
            showCallScreen()
        }
    }
}

extension ChatParentVC: ChildCallVCDelegate {
    func callVCDidClosedCallScreen(_ isClosedCall: Bool) {
        showChatScreenDidClosedCall(isClosedCall)
    }
}
