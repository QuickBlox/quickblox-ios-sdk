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
//	var user: QBUUser?
	
	init(dialog: QBChatDialog) {
		super.init()
		if dialog.type == .Private {
			self.detailTextLabelText = "SA_STR_PRIVATE".localized
            
			if dialog.recipientID == -1 {
				return
			}
            
//			assert(StorageManager.instance.dialogsUsers.count > 0)
            
            let users = StorageManager.instance.dialogsUsers
            
            var filteredUsers = users.filter(){ $0.ID == UInt(dialog.recipientID) }
            
            if !filteredUsers.isEmpty {
                var recipient = filteredUsers[0]
                self.textLabelText = recipient.login ?? recipient.email
                rightUtilityButtons = self.blockButtonsForDialogType(dialog.type, user: recipient)
//                self.user = recipient
            }
				
		}
		else if dialog.type == .Group {
			self.detailTextLabelText = "SA_STR_GROUP".localized
		}
		else {
			self.detailTextLabelText = "SA_STR_PUBLIC_GROUP".localized
		}
		
		if self.textLabelText.isEmpty {
			// group chat
            
            if let dialogName = dialog.name {
                self.textLabelText = dialogName
            }
			
			rightUtilityButtons = self.blockButtonsForDialogType(dialog.type, user: nil)
		}
		
	}
	
	init(user: QBUUser!) {
		super.init()
		rightUtilityButtons = self.blockButtonsForUser(user)
	}
	
	func blockButtonsForDialogType(dialogType: QBChatDialogType, user: QBUUser?) -> [UIButton]{
		var deleteButton = UIButton()
		
		deleteButton.setTitle("SA_STR_DELETE".localized, forState: UIControlState.Normal)
		deleteButton.backgroundColor = UIColor.redColor()
		deleteButton.tag = 1
		
		if dialogType ==  .Private {
            let users = StorageManager.instance.dialogsUsers
            
			if users.count > 0,
				let strongUser = user {
					var title: String
					var color: UIColor
					if ConnectionManager.instance.privacyManager.isUserInBlockList(strongUser) {
						title = "SA_STR_UNBLOCK".localized
						color = UIColor(red: 0.0, green: 0.5, blue: 0.0, alpha: 1.0)
					}
					else {
						title = "SA_STR_BLOCK".localized
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
		var title = "SA_STR_BLOCK".localized
		var color = UIColor(red: 0.8, green: 0.0, blue: 0.0, alpha: 1.0)
		if ConnectionManager.instance.privacyManager.isUserInBlockList(user) {
			title = "SA_STR_UNBLOCK".localized
			color = UIColor(red: 0.0, green: 0.5, blue: 0.0, alpha: 1.0)
		}
		
		var blockButton = UIButton()
		blockButton.setTitle(title, forState: UIControlState.Normal)
		blockButton.backgroundColor = color
		blockButton.tag = 0
		return [blockButton]
	}
	
}
