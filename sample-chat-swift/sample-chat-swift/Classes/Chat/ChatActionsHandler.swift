//
//  ChatActionsHandler.swift
//  Swift-ChatViewController
//
//  Created by Injoit on 1/28/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import Foundation

protocol ChatActionsHandler: class {
  func chatContactRequestDidAccept(_ accept: Bool, sender: Any?)
}
