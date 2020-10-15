//
//  Constants.swift
//  sample-chat-swift
//
//  Created by Injoit on 1/28/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//


import Foundation

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
