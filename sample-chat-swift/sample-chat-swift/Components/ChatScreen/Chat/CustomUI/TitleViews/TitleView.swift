//
//  TitleView.swift
//  sample-chat-swift
//
//  Created by Injoit on 10/10/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit

class TitleView: UIView {
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 17.0, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.lineBreakMode = .byTruncatingTail
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
        return titleLabel
    }()
    
    lazy var subTitleLabel: UILabel = {
        let subTitleLabel = UILabel()
        subTitleLabel.font = .systemFont(ofSize: 13.0)
        subTitleLabel.textColor = UIColor.white.withAlphaComponent(0.6)
        subTitleLabel.textAlignment = .center
        subTitleLabel.lineBreakMode = .byTruncatingTail
        addSubview(subTitleLabel)
        subTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subTitleLabel.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
        subTitleLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        subTitleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        return subTitleLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        bounds.size.width = 200.0
        bounds.size.height = 40.0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupTitleView(title: String, subTitle: String) {
        titleLabel.text = title
        subTitleLabel.text = subTitle
    }
}

