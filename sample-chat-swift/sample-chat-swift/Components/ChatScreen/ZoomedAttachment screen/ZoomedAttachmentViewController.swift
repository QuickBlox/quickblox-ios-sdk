//
//  ZoomedAttachmentViewController.swift
//  sample-chat-swift
//
//  Created by Injoit on 1/28/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit

class ZoomedAttachmentViewController: UIViewController {
    //MARK: - Properties
    let zoomImageView = UIImageView()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        zoomImageView.frame = view.frame
        zoomImageView.contentMode = .scaleAspectFit
        view.addSubview(zoomImageView)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(goBackAction(_ :)))
        view.addGestureRecognizer(tapGesture)
    }
    
    //MARK: - Actions
    @objc private func goBackAction(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
}
