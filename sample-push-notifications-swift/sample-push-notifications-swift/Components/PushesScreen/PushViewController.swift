//
//  ViewController.swift
//  sample-push-notifications-swift
//
//  Created by Injoit on 3/19/19.
//  Copyright © 2019 QuickBlox. All rights reserved.
//

import UIKit
import Quickblox
import SVProgressHUD

class PushViewController: UIViewController {
    
    //MARK: - Properties
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sendPushButton: UIBarButtonItem!
    @IBOutlet weak var pushMessageTextView: PushTextView!
    @IBOutlet weak var segmentedController: UISegmentedControl!
    
    var pushMessages: [String] = []
    private var currentPushType: PushType = .apns
    
    lazy private var notificationsProvider: NotificationsProvider = {
        let notificationsProvider = NotificationsProvider()
        return notificationsProvider
    }()

    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        notificationsProvider.delegate = self
        pushMessageTextView.placeholder = "Enter push message here"
        pushMessageTextView.textContainerInset = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 0.0, right: 0.0)
        
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect(x: 0.0,
                                    y: pushMessageTextView.frame.size.height - 1.0,
                                    width: view.frame.size.width,
                                    height: 1.0)
        bottomBorder.backgroundColor = UIColor(red: 200.0/255.0,
                                               green: 199.0/255.0,
                                               blue: 204.0/255.0,
                                               alpha: 1.0).cgColor
        pushMessageTextView.layer.addSublayer(bottomBorder)

        sendPushButton.isEnabled = false
        
        let profile = Profile()
        if profile.isFull == true {
            sendPushButton.isEnabled = true
            title = profile.fullName
        } else {
            SVProgressHUD.showError(withStatus: "You are not authorized.")
        }
        
        let logoutButton = UIBarButtonItem(title:"Logout",
                                           style: .plain,
                                           target: self,
                                           action: #selector(didTapLogout(_:)))
        navigationItem.leftBarButtonItem = logoutButton
        
        addInfoButton()
    }
    
    //MARK: - Actions
    @IBAction func pushTypeDidChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            currentPushType = .apns
        } else if sender.selectedSegmentIndex == 1 {
            currentPushType = .apnsVoip
        }
    }
    
    
    @objc private func didTapLogout(_ sender: UIBarButtonItem) {
        SVProgressHUD.show(withStatus: "Logouting...")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        guard let uuidString = UIDevice.current.identifierForVendor?.uuidString else {
            return
        }
        #if targetEnvironment(simulator)
        logOut()
        #else
        
        QBRequest.subscriptions(successBlock: { [weak self] (response, subscriptions) in
            guard let subscriptions = subscriptions, subscriptions.isEmpty == false else {
                self?.logOut()
                return
            }
            let deleteSubscriptionsGroup = DispatchGroup()
            for subscription in subscriptions {
                if let subscriptionsUIUD = subscription.deviceUDID,
                   subscriptionsUIUD == uuidString {
                    deleteSubscriptionsGroup.enter()
                    QBRequest.deleteSubscription(withID: subscription.id) { (response) in
                        deleteSubscriptionsGroup.leave()
                        debugPrint("[NotificationsProvider] Unregister Subscription request - Success")
                    } errorBlock: { (response) in
                        deleteSubscriptionsGroup.leave()
                        debugPrint("[NotificationsProvider] Unregister Subscription request - Error")
                    }
                }
            }
            deleteSubscriptionsGroup.notify(queue: DispatchQueue.main) {
                self?.logOut()
            }
        }) { (response) in
            if response.status.rawValue == 404 {
                self.showLoginScreen()
            }
        }
        #endif
    }
    
    //MARK: - Internal Methods
    //MARK: - logOut flow
    fileprivate func showLoginScreen() {
        Profile.clear()
        AppDelegate.shared.rootViewController.showLoginScreen()
        SVProgressHUD.showSuccess(withStatus: "Complited")
    }
    
    private func logOut() {
        QBRequest.logOut(successBlock: { [weak self] response in
            self?.showLoginScreen()
        }) { response in
            debugPrint("[DialogsViewController] logOut error: \(response)")
        }
    }
    
    //MARK: - IActions
    @IBAction func sendPush(_ sender: UIBarButtonItem) {
        
        view.endEditing(true)
        guard let message = pushMessageTextView.text else {
            return
        }
        // empty text
        if message.isEmpty == true {
            SVProgressHUD.showInfo(withStatus: "Please enter some text")
        } else {
            sendPushWith(message)
            pushMessageTextView.resignFirstResponder()
            pushMessageTextView.text = nil;
        }
    }
    
    //MARK: - Internal Methods
    private func sendPushWith(_ message: String) {
        
        let profile = Profile()
        if profile.isFull == false {
            return
        }
        let currentUserId = "\(profile.ID)"

        switch currentPushType {
        case .apns:
            SVProgressHUD.show(withStatus: "Sending a APNS Push")
            QBRequest.sendPush(withText: message, toUsers: currentUserId, successBlock: { (response, events) in
                SVProgressHUD.showSuccess(withStatus: "Your message successfully sent")
                
            }) { (error) in
                SVProgressHUD.showError(withStatus: error.description)
            }
        case .apnsVoip:
            SVProgressHUD.show(withStatus: "Sending a VOIP Push")
            let payload = ["message": message,
                "ios_voip": "1",
                "VOIPCall": "1",
                "alertMessage": message
            ]
            let data = try? JSONSerialization.data(withJSONObject: payload,
                                                   options: .prettyPrinted)
            var eventMessage = ""
            if let data = data {
                eventMessage = String(data: data, encoding: .utf8) ?? ""
            }
            let event = QBMEvent()
            event.notificationType = QBMNotificationType.push
            event.usersIDs = currentUserId
            event.type = QBMEventType.oneShot
            event.message = eventMessage
            QBRequest.createEvent(event, successBlock: { response, events in
                SVProgressHUD.showSuccess(withStatus: "Your message successfully sent")
            }, errorBlock: { error in
                SVProgressHUD.showError(withStatus: error.description)
            })
        }
    }
    
    func didReceivePush(_ messages: [String]) {
        for message in messages {
            pushMessages.insert(message, at: 0)
        }
        tableView.reloadData()
    }
}

//MARK: - TableViewDataSource & TableViewDelegate
extension PushViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pushMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PushMessageCellIdentifier") else {
            return UITableViewCell()
        }
        cell.textLabel?.text = pushMessages[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension PushViewController: NotificationsProviderDelegate {
    func notificationsProvider(_ notificationsProvider: NotificationsProvider, didReceive messages: [String]) {
        didReceivePush(messages)
    }
}
