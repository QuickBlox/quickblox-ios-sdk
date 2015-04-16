//
//  UserBlockButtons.swift
//  sample-chat-swift
//
//  Created by Anton Sokolchenko on 4/10/15.
//  Copyright (c) 2015 quickblox. All rights reserved.
//

class UserBlockButtons: NSObject, SWTableViewCellDelegate{
    // right buttons for SWTableViewCell
    class func blockButtonsForDialogType(dialogType: QBChatDialogType, user: QBUUser?, includeDeleteButton: Bool) -> [UIButton]{
        var deleteButton: UIButton?
        if includeDeleteButton{
            deleteButton = UIButton()
            deleteButton!.setTitle("Delete", forState: UIControlState.Normal)
            deleteButton!.backgroundColor = UIColor.redColor()
            deleteButton!.tag = 1
        }
        switch( dialogType.value ) {
        case QBChatDialogTypePrivate.value:
            if let users = ConnectionManager.instance.dialogsUsers,
                strongUser = user{
                    var recipient = users.filter(){ $0.ID == UInt(strongUser.ID) }[0]
                    var title = "Block"
                    var color = UIColor(red: 0.8, green: 0.0, blue: 0.0, alpha: 1.0)
                    if ConnectionManager.instance.privacyManager.isUserInBlockList(recipient) {
                        title = "Unblock"
                        color = UIColor(red: 0.0, green: 0.5, blue: 0.0, alpha: 1.0)
                    }
                    
                    var blockButton = UIButton()
                    blockButton.setTitle(title, forState: UIControlState.Normal)
                    blockButton.backgroundColor = color
                    blockButton.tag = 0
                    if deleteButton != nil {
                        return [blockButton, deleteButton!]
                    } else{
                        return [blockButton]
                    }
            }
        case QBChatDialogTypeGroup.value:
            return [deleteButton!]
        case QBChatDialogTypePublicGroup.value:
            return [deleteButton!]
        default:
            return [deleteButton!]
        }
        return [deleteButton!]
    }
    class func blockButtonsForUser(user: QBUUser!) -> [UIButton]{
        var title = "Block"
        var color = UIColor(red: 0.8, green: 0.0, blue: 0.0, alpha: 1.0)
        if ConnectionManager.instance.privacyManager.isUserInBlockList(user) {
            title = "Unblock"
            color = UIColor(red: 0.0, green: 0.5, blue: 0.0, alpha: 1.0)
        }
        
        var blockButton = UIButton()
        blockButton.setTitle(title, forState: UIControlState.Normal)
        blockButton.backgroundColor = color
        blockButton.tag = 0
        return [blockButton]
    }
    
}
