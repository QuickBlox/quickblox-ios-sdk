//
//  ZoomedView.swift
//  sample-conference-videochat-swift
//
//  Created by Vladimir Nybozhinsky on 04.10.2018.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit

class ZoomedView: UIView {
    //MARK: - Properties
    var videoView: UIView? {
        willSet{
            videoView?.removeFromSuperview()
        }
        
        didSet {
            guard let view = videoView else { return }
            
            addSubview(view)
            
            view.translatesAutoresizingMaskIntoConstraints = false
            view.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            view.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            view.topAnchor.constraint(equalTo: topAnchor).isActive = true
            view.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        }
    }
    
    var didTapView: ((_ zoomedView: ZoomedView?) -> Void)?
    
    //MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(white: 0.0, alpha: 1.0)
        addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                    action: #selector(didReceiveTap(_:))))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Actions
    
    @objc func didReceiveTap(_ sender: UITapGestureRecognizer?) {
        guard let didTapView = didTapView else { return }
        didTapView(self)
    }
}
