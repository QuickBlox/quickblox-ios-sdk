//
//  Constants.swift
//  sample-chat-swift
//
//  Created by Anton Sokolchenko on 3/30/15.
//  Copyright (c) 2015 quickblox. All rights reserved.
//


import Foundation

let kChatPresenceTimeInterval:NSTimeInterval = 45
let kDialogsPageLimit:UInt = 100

class Constants {
    
    class var QB_USERS_ENVIROMENT: String {
        
#if RELEASE
        return "release"
#elseif DEBUG
        return "dev"
#elseif QA
        return "qbqa"
#else
    assert(false, "Not supported build configuration")
    return ""
#endif
        
    }
}