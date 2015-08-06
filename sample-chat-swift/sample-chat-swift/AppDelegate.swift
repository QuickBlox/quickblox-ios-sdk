//
//  AppDelegate.swift
//  sample-chat-swift
//
//  Created by Anton Sokolchenko on 3/30/15.
//  Copyright (c) 2015 quickblox. All rights reserved.
//

import UIKit

let kQBApplicationID:UInt = 92
let kQBRegisterServiceKey = "wJHdOcQSxXQGWx5"
let kQBRegisterServiceSecret = "BTFsj7Rtt27DAmT"
let kQBAccountKey = "7yvNe17TnjNUqDoPwfqp"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	
	var window: UIWindow?
	
	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        // Set QuickBlox credentials (You must create application in admin.quickblox.com).
		QBApplication.sharedApplication().applicationId = kQBApplicationID
		QBConnection.registerServiceKey(kQBRegisterServiceKey)
		QBConnection.registerServiceSecret(kQBRegisterServiceSecret)
        QBSettings.setAccountKey(kQBAccountKey)
        
        // Quickblox REST API Session is created and maintained automatically.
        QBConnection.setAutoCreateSessionEnabled(true)
        
        // Enables Quickblox REST API calls debug console output.
		QBSettings.setLogLevel(QBLogLevel.Debug)
        
        // Enables detailed XMPP logging in console output.
        QBSettings.enableXMPPLogging()
		
		return true
	}
	
	func applicationWillResignActive(application: UIApplication) {
	}
	
	func applicationDidEnterBackground(application: UIApplication) {
		ServicesManager.instance().chatService?.logoutChat()
	}
	
	func applicationWillEnterForeground(application: UIApplication) {
        ServicesManager.instance().chatService?.logIn({ (error: NSError!) -> Void in
            
            for dialog : QBChatDialog in ServicesManager.instance().chatService.dialogsMemoryStorage.unsortedDialogs() as! Array<QBChatDialog> {
                
                if dialog.type != QBChatDialogType.Private {
                    ServicesManager.instance().chatService.joinToGroupDialog(dialog, failed: { (error: NSError!) -> Void in
                        
                    })
                }
            }
            
        })
	}
	
	func applicationDidBecomeActive(application: UIApplication) {

	}
	
	func applicationWillTerminate(application: UIApplication) {
		ServicesManager.instance().chatService?.logoutChat()
	}
	
	
}

