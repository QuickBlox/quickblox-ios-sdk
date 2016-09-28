//
//  Constants.swift
//  sample-chat-swift
//
//  Created by Anton Sokolchenko on 3/30/15.
//  Copyright (c) 2015 quickblox. All rights reserved.
//


import Foundation

let kChatPresenceTimeInterval:TimeInterval = 45
let kDialogsPageLimit:UInt = 100
let kMessageContainerWidthPadding:CGFloat = 40.0


/*  ServicesManager
	...
	func downloadLatestUsers(successBlock:(([QBUUser]?) -> Void)?, errorBlock:((NSError) -> Void)?) {
	
	let enviroment = Constants.QB_USERS_ENVIROMENT
	
	self.usersService.searchUsersWithTags([enviroment])
	*/
class Constants {
	
    class var QB_USERS_ENVIROMENT: String {
		
#if DEBUG
        return "dev"
#elseif QA
        return "qbqa"
#else
    assert(false, "Not supported build configuration")
    return ""
#endif
        
    }
}
