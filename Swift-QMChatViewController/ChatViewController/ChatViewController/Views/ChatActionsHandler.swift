//
//  ChatActionsHandler.swift
//  Swift-ChatViewController
//
//  Created by Vladimir Nybozhinsky on 11/12/18.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import Foundation

protocol ChatActionsHandler: class {
  func chatContactRequestDidAccept(_ accept: Bool, sender: Any?)
}
