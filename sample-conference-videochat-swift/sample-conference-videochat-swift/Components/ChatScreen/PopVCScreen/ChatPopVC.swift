//
//  ChatPopVC.swift
//  sample-conference-videochat-swift
//
//  Created by Injoit on 10/15/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit

enum TypePopVC {
    case chatInfo
    case hamburger
}

class ChatPopVC: UITableViewController {

    var selectedAction:((_ action: ChatActions?) -> Void)?
    var actions:[ChatActions] = []
    var typePopVC: TypePopVC?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.addShadowToTableView(color: #colorLiteral(red: 0.7834715247, green: 0.8073117137, blue: 0.8447045684, alpha: 1))
        tableView.isUserInteractionEnabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.selectedAction?(nil)
    }
    
    override func viewWillLayoutSubviews() {
        guard let typePopVC = typePopVC else {return}
        
        switch typePopVC {
        case .chatInfo:
            preferredContentSize = CGSize(width: 154, height: tableView.contentSize.height)
        case .hamburger:
            preferredContentSize = CGSize(width: 177, height: tableView.contentSize.height)
        }
        
    }
    
    private func stringAction(_ action: ChatActions) -> String {
        switch action {
        case .UserProfile: return Profile().fullName.capitalized
        case .StartConference: return "Start Conference"
        case .StartStream: return "Start Stream"
        case .LeaveChat: return "Leave Chat"
        case .ChatInfo: return "Chat Info"
        case .Edit: return "Edit"
        case .Delete: return "Delete"
        case .Forward: return "Forward"
        case .DeliveredTo: return "Delivered to..."
        case .ViewedBy: return "Viewed by..."
        case .SaveAttachment: return "Save attachment"
        case .Logout: return "Logout"
        case .VideoConfig: return "Video Configuration"
        case .AudioConfig: return "Audio Configuration"
        case .ChatFromCall: return "ChatFromCall"
        case .InfoFromCall: return "InfoFromCall"
        case .AppInfo: return "App Info"
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChatActionCell", for: indexPath) as? ChatActionCell else {
            return UITableViewCell()
        }
        
        let action = actions[indexPath.row]
        cell.actionLabel.text = stringAction(action)
        if let type = typePopVC, type == .hamburger {
            if action == .UserProfile {
                cell.actionLabel.font = .systemFont(ofSize: 15.0, weight: .medium)
            }
            if indexPath.row == 1 || indexPath.row == actions.count - 1 {
                    cell.separatorView.isHidden = false
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let action = actions[indexPath.row]
        DispatchQueue.main.async(execute: {
            self.dismiss(animated: false) {
                self.selectedAction?(action)
            }
        })
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let action = actions[indexPath.row]
        if let type = typePopVC, type == .hamburger {
            if action == .Logout || action == .UserProfile {
                return 74.0
            }
        }
        return 44.0
    }
}
