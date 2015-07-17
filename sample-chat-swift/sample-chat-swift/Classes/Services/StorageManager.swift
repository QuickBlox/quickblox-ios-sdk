//
//  StorageManager.swift
//  sample-chat-swift
//
//  Created by Injoit on 5/26/15.
//  Copyright (c) 2015 quickblox. All rights reserved.
//

import Foundation

class StorageManager: NSObject {
    
    static let instance = StorageManager()
    
    var dialogs:[QBChatDialog] = []
    
    func reset() {
        self.dialogs.removeAll(keepCapacity: false)
    }
    
}
