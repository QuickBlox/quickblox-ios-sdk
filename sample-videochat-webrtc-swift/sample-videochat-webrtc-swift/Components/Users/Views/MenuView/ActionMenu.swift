//
//  ActionMenu.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 15.08.2020.
//  Copyright © 2020 QuickBlox. All rights reserved.
//

import Foundation

enum UserAction: String {
    case userProfile
    case selectParticipant
    case appInfo
    case logout
    case videoConfig
    case audioConfig
}

typealias SelectedAction = ((_ action: UserAction) -> Void)

class ActionMenu {
    //MARK: - Properties
    var successHandler: SelectedAction?
    var title: String
    var action: UserAction
    var isSelected: Bool?
    
    //MARK: - Life Cycle
    init (title: String,
          isSelected: Bool?,
          action: UserAction,
          handler: @escaping SelectedAction) {
        self.title = title
        self.action = action
        self.successHandler = handler
        self.isSelected = isSelected
    }
}
