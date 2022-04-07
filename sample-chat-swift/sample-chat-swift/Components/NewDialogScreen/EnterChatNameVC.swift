//
//  EnterChatNameVC.swift
//  sample-chat-swift
//
//  Created by Injoit on 10/9/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit

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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if QBChat.instance.isConnected == false {
            showNoInternetAlert(handler: nil)
            return
        }
    }
    
    //MARK: - Actions
    @objc func didTapBack(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func createChatButtonPressed(_ sender: UIBarButtonItem) {
        if QBChat.instance.isConnected == false {
            showNoInternetAlert(handler: nil)
            return
        }
        let chatName = chatNameInputContainer.inputTextfield.text ?? "New Group Chat"
        sender.isEnabled = false
        chatManager.storage.update(users: selectedUsers)
        
        chatManager.createGroupDialog(withName: chatName,
                                      photo: nil,
                                      occupants: selectedUsers) { [weak self] (error, dialog) -> Void in
            guard let self = self else {return}
            guard let dialog = dialog,
                  let dialogID = dialog.id else {
                      if let error = error {
                          self.showAlertView(nil, message: error, handler: nil)
                      }
                      sender.isEnabled = true
                      return
                  }
            guard let navigationController = self.navigationController else {
                return
            }
            let controllers = navigationController.viewControllers
            var newStack = [UIViewController]()
            
            //change stack by replacing view controllers after ChatVC with ChatVC
            controllers.forEach {
                newStack.append($0)
                if $0 is DialogsViewController {
                    guard let chatController = Screen.chatViewController() else {
                        return
                    }
                    chatController.dialogID = dialogID
                    newStack.append(chatController)
                    navigationController.setViewControllers(newStack, animated: true)
                    return
                }
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
