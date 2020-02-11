//
//  ChatPopVC.swift
//  sample-chat-swift
//
//  Created by Injoit on 10/15/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit

class ChatPopVC: UITableViewController {

    var selectedAction:((_ action: ChatActions?) -> Void)?
    var actions:[ChatActions] = []

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
        preferredContentSize = CGSize(width: 148, height: tableView.contentSize.height)
    }
    
    private func stringAction(_ action: ChatActions) -> String {
        switch action {
        case .LeaveChat: return "Leave Chat"
        case .ChatInfo: return "Chat info"
        case .Edit: return "Edit"
        case .Delete: return "Delete"
        case .Forward: return "Forward"
        case .DeliveredTo: return "Delivered to..."
        case .ViewedBy: return "Viewed by..."
        case .SaveAttachment: return "Save attachment"
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
}
