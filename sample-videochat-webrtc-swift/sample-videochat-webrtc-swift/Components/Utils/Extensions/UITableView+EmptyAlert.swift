//
//  UITableView+EmptyAlert.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 10/9/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit

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
        backgroundView = nil
    }
    
    func addShadowToTableView(color: UIColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)) {
        backgroundColor = .white
        layer.masksToBounds = false
        layer.shadowOffset = CGSize(width: 0, height: 12)
        layer.shadowColor = UIColor(red:0.22, green:0.47, blue:0.99, alpha:0.5).cgColor
        layer.shadowOpacity = 1
        layer.shadowRadius = 11
    }
}
