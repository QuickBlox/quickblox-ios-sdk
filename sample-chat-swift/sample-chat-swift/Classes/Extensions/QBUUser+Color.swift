//
//  QBUUserWithColor.swift
//  sample-chat-swift
//
//  Created by Anton Sokolchenko on 3/31/15.
//  Copyright (c) 2015 quickblox. All rights reserved.
//

import UIKit

extension QBUUser {
    var color: UIColor {
        get{
            return UsersDataSource.instance.colorAtUser(self)
        }
    }
    
    var index:UInt {
        get{
            if let index = find(UsersDataSource.instance.users, self){
                return UInt(index)
            }
            else{
                return 0
            }
        }
    }
}
