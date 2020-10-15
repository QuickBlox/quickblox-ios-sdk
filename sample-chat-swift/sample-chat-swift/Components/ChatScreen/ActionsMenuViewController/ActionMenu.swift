//
//  ActionMenu.swift
//  sample-chat-swift
//
//  Created by Vladimir Nybozhinsky on 13.08.2020.
//  Copyright © 2020 quickBlox. All rights reserved.
//

import Foundation

typealias SelectedAction = (_ action: ChatAction) -> Void

class MenuAction {
    //MARK: - Properties
    var successHandler: SelectedAction?
    var title: String
    var action: ChatAction
    
    //MARK: - Life Cycle
    init (title: String,
          action: ChatAction,
          handler: @escaping SelectedAction) {
        self.title = title
        self.action = action
        self.successHandler = handler
    }
}
