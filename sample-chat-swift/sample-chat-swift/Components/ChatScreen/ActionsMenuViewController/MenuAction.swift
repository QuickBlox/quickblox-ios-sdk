//
//  MenuAction.swift
//  sample-chat-swift
//
//  Created by Injoit on 13.08.2020.
//  Copyright © 2020 quickBlox. All rights reserved.
//

import Foundation

typealias SelectedAction = (() -> Void)

class MenuAction {
    //MARK: - Properties
    var successHandler: SelectedAction?
    var title: String
    
    //MARK: - Life Cycle
    init (title: String,
          handler: @escaping SelectedAction) {
        self.title = title
        self.successHandler = handler
    }
}
