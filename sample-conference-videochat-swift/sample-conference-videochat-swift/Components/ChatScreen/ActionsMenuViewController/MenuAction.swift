//
//  MenuAction.swift
//  sample-conference-videochat-swift
//
//  Created by Injoit on 15.08.2020.
//  Copyright © 2020 QuickBlox. All rights reserved.
//

import Foundation

typealias SelectedAction = ((_ action: ChatAction) -> Void)

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
