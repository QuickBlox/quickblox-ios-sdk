//
//  ActionsMenuViewController.swift
//  sample-chat-swift
//
//  Created by Injoit on 10/15/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit

class ActionsMenuViewController: UITableViewController {
    var cancelAction:(() -> Void)?
    private var actions:[MenuAction] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.addShadowToTableView(color: #colorLiteral(red: 0.7834715247, green: 0.8073117137, blue: 0.8447045684, alpha: 1))
        tableView.isUserInteractionEnabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        cancelAction?()
    }
    
    override func viewWillLayoutSubviews() {
        preferredContentSize = CGSize(width: 148, height: tableView.contentSize.height)
    }
    
    func addAction(_ action: MenuAction) {
        actions.insert(action, at: 0)
    }
    
   override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MenuActionCellConstant.reuseIdentifier, for: indexPath) as? MenuActionCell else {
            return UITableViewCell()
        }
        let action = actions[indexPath.row]
        cell.actionLabel.text = action.title

        return cell
    }

   override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let action = actions[indexPath.row]
        DispatchQueue.main.async(execute: {
            self.dismiss(animated: false) {
                action.successHandler?()
                self.cancelAction?()
            }
        })
    }
}
