//
//  UserTableViewCellModel.swift
//  sample-chat-swift
//
//  Created by Anton Sokolchenko on 4/10/15.
//  Copyright (c) 2015 quickblox. All rights reserved.
//

class UserTableViewCellModel: NSObject {
    // right buttons for SWTableViewCell
    var rightUtilityButtons: [UIButton]!
    var detailTextLabelText: String = ""
    var textLabelText: String = ""
    var user: QBUUser?
    
    init(dialogType: QBChatDialogType, user: QBUUser?) {
        super.init()
        rightUtilityButtons = self.blockButtonsForDialogType(dialogType, user: user)
    }
    
    init(dialog: QBChatDialog) {
        super.init()
        if dialog.type.value == QBChatDialogTypePrivate.value {
            self.detailTextLabelText = "private"
            if dialog.recipientID != -1 {
                if let users = ConnectionManager.instance.dialogsUsers {
                    var filteredUsers = users.filter(){ $0.ID == UInt(dialog.recipientID) }
                    if !filteredUsers.isEmpty {
                        var recipient = filteredUsers[0]
                        self.textLabelText = recipient.login ?? recipient.email
                        rightUtilityButtons = self.blockButtonsForDialogType(dialog.type, user: recipient)
                        self.user = recipient
                    }
              }
            }
        }
        else if dialog.type.value == QBChatDialogTypeGroup.value {
            self.detailTextLabelText = "group"
        }
        else {
            self.detailTextLabelText = "public group"
        }
        
        if self.textLabelText.isEmpty {
            self.textLabelText = dialog.name
            rightUtilityButtons = self.blockButtonsForDialogType(dialog.type, user: nil)
        }
        
        
    }
    
    init(user: QBUUser!) {
        super.init()
        rightUtilityButtons = self.blockButtonsForUser(user)
    }
    
    func blockButtonsForDialogType(dialogType: QBChatDialogType, user: QBUUser?) -> [UIButton]{
        var deleteButton = UIButton()
        deleteButton.setTitle("Delete", forState: UIControlState.Normal)
        deleteButton.backgroundColor = UIColor.redColor()
        deleteButton.tag = 1
        
        if dialogType.value ==  QBChatDialogTypePrivate.value {
            if let users = ConnectionManager.instance.dialogsUsers,
                strongUser = user {
                    var title: String
                    var color: UIColor
                    if ConnectionManager.instance.privacyManager.isUserInBlockList(strongUser) {
                        title = "Unblock"
                        color = UIColor(red: 0.0, green: 0.5, blue: 0.0, alpha: 1.0)
                    }
                    else {
                        title = "Block"
                        color = UIColor(red: 0.8, green: 0.0, blue: 0.0, alpha: 1.0)
                    }
                    
                    var blockButton = UIButton()
                    blockButton.setTitle(title, forState: UIControlState.Normal)
                    blockButton.backgroundColor = color
                    blockButton.tag = 0
                    return [blockButton, deleteButton]
            }
        }
        return [deleteButton]
    }
    
    func blockButtonsForUser(user: QBUUser!) -> [UIButton]{
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
