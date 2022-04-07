//
//  ProgressView.swift
//  sample-chat-swift
//
//  Created by Injoit on 09.11.2021.
//  Copyright © 2021 QuickBlox. All rights reserved.
//

import UIKit

class ProgressView: UIView {
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        rounded(cornerRadius: 16)
        layer.zPosition = CGFloat(Float.greatestFiniteMagnitude)
    }
    
    var isRunning: Bool {
        return activityIndicator.isAnimating
    }
    
    func start() {
        if isRunning == true { return }
        guard let lastWindow = UIApplication.shared.windows.last else { return }
        lastWindow.addSubview(self)
        center = lastWindow.center
        lastWindow.bringSubviewToFront(self)
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
        }
    }
    
    func stop() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.removeFromSuperview()
        }
    }
}
