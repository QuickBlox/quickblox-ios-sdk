//
//  ChatPrivateTitleView.swift
//  sample-chat-swift
//
//  Created by Injoit on 11/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit

class ChatPrivateTitleView: UIStackView {

    lazy var avatarLabel: UILabel = {
        let avatarLabel = UILabel()
        avatarLabel.backgroundColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        avatarLabel.textColor = .white
        avatarLabel.font = .systemFont(ofSize: 17.0, weight: .semibold)
        avatarLabel.textAlignment = .center
        avatarLabel.setRoundedLabel(cornerRadius: 13.0)
        avatarLabel.translatesAutoresizingMaskIntoConstraints = false
        avatarLabel.widthAnchor.constraint(equalToConstant: 26.0).isActive = true
        avatarLabel.heightAnchor.constraint(equalToConstant: 26.0).isActive = true
        return avatarLabel
    }()

    lazy var avatarImageView: UIImageView = {
        let avatarImageView = UIImageView()
        avatarImageView.setRoundedView(cornerRadius: 13.0)
        avatarImageView.contentMode = .scaleAspectFill
        avatarLabel.addSubview(avatarImageView)
        avatarImageView.center = avatarLabel.center
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.widthAnchor.constraint(equalToConstant: 26.0).isActive = true
        avatarImageView.heightAnchor.constraint(equalToConstant: 26.0).isActive = true
        return avatarImageView
    }()

    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 17.0, weight: .semibold)
        addSubview(titleLabel)
        return titleLabel
    }()
    
    func setupPrivateChatTitleView(_ opponentUser:QBUUser) {
        let userName = opponentUser.fullName
        avatarLabel.text = String(userName?.capitalized.first ?? Character("Q"))
        avatarLabel.backgroundColor = opponentUser.id.generateColor()
        titleLabel.text = userName
        addArrangedSubview(avatarLabel)
        addArrangedSubview(titleLabel)
        spacing = 5.0
        alignment = .center
    }
}
