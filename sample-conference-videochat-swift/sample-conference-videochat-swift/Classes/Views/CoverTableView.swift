//
//  CoverTableView.swift
//  sample-conference-videochat-swift
//
//  Created by Injoit on 26.01.2020.
//  Copyright © 2020 quickBlox. All rights reserved.
//

import UIKit

class CoverTableView: UIView {
    @IBOutlet weak var tableView: UITableView!
    var transparentHoleView: UIView?
    var selectedAction:((_ action: ChatActions?) -> Void)?
    var actions:[ChatActions] = []
    
    // MARK: - Initialization
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tableView.register(UINib(nibName: "ActionCell", bundle: nil), forCellReuseIdentifier: "ActionCell")
    }
    
    private func stringAction(_ action: ChatActions) -> String {
        switch action {
        case .UserProfile: return "User Profile"
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
        case .AppInfo: return "App info"
        }
    }
    
    override func layoutSubviews () {
        super.layoutSubviews()
        
        tableView.frame = CGRect(x: (transparentHoleView?.frame.midX)!, y: (transparentHoleView?.frame.midY)!, width: 148, height: tableView.contentSize.height)
    }
}

extension CoverTableView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ActionCell", for: indexPath) as? ActionCell else {
            return UITableViewCell()
        }
        let action = actions[indexPath.row]
        print("action \(action)")
        cell.actionLabel.text = stringAction(action)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let action = actions[indexPath.row]
        DispatchQueue.main.async(execute: {
            self.transparentHoleView = nil
            self.removeFromSuperview()
            self.selectedAction?(action)
        })
    }
}
