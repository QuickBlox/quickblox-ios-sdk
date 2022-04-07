//
//  ChatActionsHandler.swift
//  sample-chat-swift
//
//  Created by Injoit on 1/28/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import Foundation

protocol ChatActionsHandler: AnyObject {
  func chatContactRequestDidAccept(_ accept: Bool, sender: Any?)
}
