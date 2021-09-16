//
//  MaxCountAlertViewController.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 29.07.2021.
//  Copyright © 2021 QuickBlox. All rights reserved.
//

import UIKit

struct SelectedUsersCountAlertConstant {
    static let defaultNavigationBarHeight: CGFloat = 44.0
}

class SelectedUsersCountAlert: UIViewController {
    //MARK: - IBOutlets
    @IBOutlet weak var alertLabel: PaddingLabel! {
        didSet {
            alertLabel.textPaddingInsets = UIEdgeInsets(top: 0, left: 11, bottom: 0, right: 0)
            alertLabel.setRoundView(cornerRadius: 3.0)
        }
    }
    @IBOutlet weak var alertView: UIView! {
        didSet {
            alertView.addShadowToView(color: #colorLiteral(red: 0.1960526407, green: 0.1960932612, blue: 0.1960500479, alpha: 1))
        }
    }

    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }

    //MARK: - Actions
    @IBAction func tapCancelButton(_ sender: Any) {
        dismiss(animated: false)
    }
    
    //MARK: - Private Methods
    private func setupViews() {
        let topBarHeight = navigationController?.navigationBar.frame.height ?? SelectedUsersCountAlertConstant.defaultNavigationBarHeight
        alertView.translatesAutoresizingMaskIntoConstraints = false
        alertView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12.0).isActive = true
        alertView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 112.0 + topBarHeight).isActive = true
        alertView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12.0).isActive = true
        alertView.heightAnchor.constraint(equalToConstant: 44.0).isActive = true  
    }
}
