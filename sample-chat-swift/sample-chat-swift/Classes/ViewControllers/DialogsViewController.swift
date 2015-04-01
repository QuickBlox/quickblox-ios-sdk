//
//  DialogsTableViewController.swift
//  sample-chat-swift
//
//  Created by Anton Sokolchenko on 4/1/15.
//  Copyright (c) 2015 quickblox. All rights reserved.
//

import UIKit

class DialogsViewController: UIViewController, UITableViewDelegate {
    
    @IBOutlet weak var tableView:UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SVProgressHUD.showWithStatus("Loading")
        
        QBRequest.dialogsWithSuccessBlock({ (response: QBResponse!, dialogs: [AnyObject]!, dialogsUsersIDs: Set<NSObject>!) -> Void in
            
            ConnectionManager.instance.dialogs = dialogs as? [QBChatDialog]
            
            var pagedRequest = QBGeneralResponsePage(currentPage: 0, perPage: 100)
            
            QBRequest.usersWithIDs(Array(dialogsUsersIDs), page: pagedRequest, successBlock: {[unowned self] (response: QBResponse!, page: QBGeneralResponsePage!, users: [AnyObject]!) -> Void in
                
                SVProgressHUD.showSuccessWithStatus("Completed!")
                
                ConnectionManager.instance.dialogsUsers = users as? [QBUUser]
                
                self.tableView.reloadData()
                
                }, errorBlock: { (response: QBResponse!) -> Void in
                    SVProgressHUD.showErrorWithStatus("Can't download users")
                    println(response.error.error)
            })
            }, errorBlock: { (response: QBResponse!) -> Void in
                SVProgressHUD.showErrorWithStatus("Can't download dialogs")
                println(response.error.error)
        })
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let dialogs = ConnectionManager.instance.dialogs {
            return dialogs.count
        }
        
        return 0
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("dialogcell", forIndexPath: indexPath) as! UITableViewCell
        
        var chatDialog = ConnectionManager.instance.dialogs![indexPath.row]
        
        cell.tag = indexPath.row
        
        switch( chatDialog.type.value ) {
        case QBChatDialogTypePrivate.value:
            cell.detailTextLabel?.text = "private"
            if let users = ConnectionManager.instance.dialogsUsers {
                var recipient = users.filter(){ $0.ID == UInt(chatDialog.recipientID) }[0]
                cell.textLabel?.text = recipient.login ?? recipient.email
            }
        case QBChatDialogTypeGroup.value:
            cell.detailTextLabel?.text = "group"
            cell.textLabel?.text = chatDialog.name
        case QBChatDialogTypePublicGroup.value:
            cell.detailTextLabel?.text = "public group"
            cell.textLabel?.text = chatDialog.name
        default:
            break
        }
        return cell
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return NO if you do not want the specified item to be editable.
    return true
    }
    */
    
    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
    // Delete the row from the data source
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    } else if editingStyle == .Insert {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    }
    */
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return NO if you do not want the item to be re-orderable.
    return true
    }
    */
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    }
    */
    
}
