//
//  EnterChatNameVC.swift
//  sample-conference-videochat-swift
//
//  Created by Injoit on 10/9/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit
import Quickblox
import SVProgressHUD

class EnterChatNameVC: UIViewController {
    
    //MARK: - Properties
    lazy var chatNameInputContainer: InputContainer = {
        let chatNameInputContainer = InputContainer.loadNib()
        chatNameInputContainer.setup(title: .chatName,
                                  hint: .chatName,
                                  regexes: [.chatName])
        chatNameInputContainer.delegate = self
        return chatNameInputContainer
    }()
    var selectedUsers: [QBUUser] = []
    private let chatManager = ChatManager.instance
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(chatNameInputContainer)
        chatNameInputContainer.translatesAutoresizingMaskIntoConstraints = false
        chatNameInputContainer.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        chatNameInputContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16.0).isActive = true
        chatNameInputContainer.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        chatNameInputContainer.inputTextfield.becomeFirstResponder()
        chatNameInputContainer.layoutIfNeeded()
        
        let backButtonItem = UIBarButtonItem(image: UIImage(named: "chevron"),
                                             style: .plain,
                                             target: self,
                                             action: #selector(didTapBack(_:)))
        navigationItem.leftBarButtonItem = backButtonItem
        backButtonItem.tintColor = .white
        
        let createButtonItem = UIBarButtonItem(title: "Finish",
                                               style: .plain,
                                               target: self,
                                               action: #selector(createChatButtonPressed(_:)))
        navigationItem.rightBarButtonItem = createButtonItem
        createButtonItem.tintColor = .white
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        title = "New Chat"
        
        //MARK: - Reachability
        let updateConnectionStatus: ((_ status: NetworkConnectionStatus) -> Void)? = { [weak self] status in
            let notConnection = status == .notConnection
            if notConnection == true {
                self?.showAlertView(LoginConstant.checkInternet, message: LoginConstant.checkInternetMessage)
            } else {
                if QBChat.instance.isConnected == false, QBChat.instance.isConnecting == false {
                        self?.chatManager.connect()
                }
            }
        }
        Reachability.instance.networkStatusBlock = { status in
            updateConnectionStatus?(status)
        }
        updateConnectionStatus?(Reachability.instance.networkConnectionStatus())
    }
    
    //MARK: - Actions
    @objc func didTapBack(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func createChatButtonPressed(_ sender: UIBarButtonItem) {
        
        let chatName = chatNameInputContainer.inputTextfield.text ?? "New Group Chat"
        sender.isEnabled = false
        SVProgressHUD.show()
        chatManager.storage.update(users: selectedUsers)
        
        chatManager.createGroupDialog(withName: chatName,
                                      photo: nil,
                                      occupants: selectedUsers) { [weak self] (error, dialog) -> Void in
            guard let self = self else {return}
            guard let dialog = dialog,
                  let dialogID = dialog.id else {
                if let error = error?.localizedDescription {
                    SVProgressHUD.showError(withStatus: error)
                }
                sender.isEnabled = true
                return
            }
            self.openNewDialog(dialogID)
        }
    }
    
    private func openNewDialog(_ dialogID: String) {
        guard let navigationController = navigationController else {
            return
        }
        let controllers = navigationController.viewControllers
        
        controllers.forEach{
            if $0 is DialogsViewController,
               let dialogsViewController = $0 as? DialogsViewController {
                dialogsViewController.onOpenChatScreenWithDialogID?(dialogID, true)
                return
            }
        }
    }
}

extension EnterChatNameVC: InputContainerDelegate {
    func inputContainer(_ container: InputContainer, didChangeValidState isValid: Bool) {
        if isValid == false {
            navigationItem.rightBarButtonItem?.isEnabled = false
            return
        }
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
}
