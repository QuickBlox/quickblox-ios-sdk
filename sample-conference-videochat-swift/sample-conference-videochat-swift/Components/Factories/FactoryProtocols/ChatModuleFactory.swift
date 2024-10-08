//
//  ChatModuleFactory.swift
//  sample-conference-videochat-swift
//
//  Created by Injoit on 01.09.2020.
//  Copyright © 2020 QuickBlox. All rights reserved.
//

import Foundation

protocol ChatModuleFactory {
  func makeChatOutput() -> ChatView
}
