//
//  Constants.swift
//  sample-chat-swift
//
//  Created by Anton Sokolchenko on 3/30/15.
//  Copyright (c) 2015 quickblox. All rights reserved.
//


import Foundation

//0-release, 1-dev, 2-qa
let QB_CHAT_SAMPLE_MODE:Int = 1
let kChatPresenceTimeInterval:NSTimeInterval = 45
let kDialogsPageLimit:UInt = 100

class Constants{
    class var QB_VERSION_STR: String {
        if QB_CHAT_SAMPLE_MODE == 0 {
            return "release"
        }
        else if QB_CHAT_SAMPLE_MODE == 1 {
            return "dev"
        }
        else if QB_CHAT_SAMPLE_MODE == 2 {
            return "qa"
        }
        return ""
    }
}