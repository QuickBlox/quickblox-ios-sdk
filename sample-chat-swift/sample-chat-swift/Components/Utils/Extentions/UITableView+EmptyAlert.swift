//
//  UITableView+EmptyAlert.swift
//  sample-chat-swift
//
//  Created by Injoit on 10/9/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import Foundation

extension UITableView {
    func setupEmptyView(_ alert: String) {
        let backgroundView = UIView(frame: CGRect(x: center.x, y: center.y, width: bounds.size.width, height: bounds.size.height))
        let alertLabel = UILabel()
        alertLabel.textColor = UIColor(red:0.2, green:0.2, blue:0.2, alpha:1)
        alertLabel.font = UIFont.systemFont(ofSize: 17.0, weight: .regular)
        backgroundView.addSubview(alertLabel)
        alertLabel.text = alert
        alertLabel.numberOfLines = 1
        alertLabel.textAlignment = .center
        
        alertLabel.translatesAutoresizingMaskIntoConstraints = false
        alertLabel.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 28.0).isActive = true
        alertLabel.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor).isActive = true
        
        self.backgroundView = backgroundView
        
    }
    func removeEmptyView() {
        self.backgroundView = nil
    }
}
