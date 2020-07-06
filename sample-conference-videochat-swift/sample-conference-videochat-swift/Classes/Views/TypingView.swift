//
//  TypingView.swift
//  sample-conference-videochat-swift
//
//  Created by Injoit on 11/26/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit

struct TypingViewConstant {
    static let typingOne = " is typing..."
    static let typingTwo = " are typing..."
    static let typingFour = " and 2 more are typing..."
}

class TypingView: UIView {
    
    private let chatManager = ChatManager.instance
    
    lazy var typingLabel: UILabel = {
        let typingLabel = UILabel()
        typingLabel.textColor = #colorLiteral(red: 0.4235294118, green: 0.4784313725, blue: 0.5725490196, alpha: 1)
        typingLabel.font = .italicSystemFont(ofSize: 13.0)
        typingLabel.textAlignment = .left
        addSubview(typingLabel)
        typingLabel.translatesAutoresizingMaskIntoConstraints = false
        typingLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16.0).isActive = true
        typingLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -16.0).isActive = true
        typingLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        typingLabel.heightAnchor.constraint(equalToConstant: 15.0).isActive = true
        return typingLabel
    }()
    
    func setupTypingView(_ opponentUsersIDs: Set<UInt>?) {
        guard let opponentsIDs = opponentUsersIDs else {
            return
        }
        var typingString = ""
        var userNames = [String]()
        opponentsIDs.forEach { (userID) in
            guard let opponentUser = self.chatManager.storage.user(withID: userID) else {
                return
            }
            if let userName = opponentUser.fullName {
                userNames.append(userName)
            } else {
                userNames.append("User")
            }
        }
        switch opponentsIDs.count {
        case 1:
            typingString = userNames[0] + TypingViewConstant.typingOne
        case 2:
            typingString = userNames[0] + " and " + userNames[1] + TypingViewConstant.typingTwo
        case 3:
            typingString = userNames[0] + ", " + userNames[1] + " and " + userNames[2] + TypingViewConstant.typingTwo
        default:
            typingString = userNames[0] + ", " + userNames[1] + TypingViewConstant.typingFour
        }
        typingLabel.text = typingString
    }
}
