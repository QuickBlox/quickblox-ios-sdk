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
		
		QBApplication.sharedApplication().applicationId = kQBApplicationID
		QBConnection.registerServiceKey(kQBRegisterServiceKey)
		QBConnection.registerServiceSecret(kQBRegisterServiceSecret)
		QBSettings.setAccountKey(kQBAccountKey)
		QBSettings.setLogLevel(QBLogLevel.Debug)
		
		ConnectionManager.instance.startObservingInternetAvailability()
		
		return true
	}
	
	func applicationWillResignActive(application: UIApplication) {
	}
	
	func applicationDidEnterBackground(application: UIApplication) {
		if QBChat.instance().isLoggedIn() {
			QBChat.instance().logout()
		}
		ConnectionManager.instance.stopObservingInternetAvailability()
	}
	
	func applicationWillEnterForeground(application: UIApplication) {
		if let user = ConnectionManager.instance.currentUser {
			QBChat.instance().loginWithUser(user)
			
			ConnectionManager.instance.logInWithUser(user, completion: { (success, errorMessage) -> Void in
				ConnectionManager.instance.joinAllRooms()
				ConnectionManager.instance.startObservingInternetAvailability()
			})
		}
	}
	
	func applicationDidBecomeActive(application: UIApplication) {
		ConnectionManager.instance.startObservingInternetAvailability()
	}
	
	func applicationWillTerminate(application: UIApplication) {
		if QBChat.instance().isLoggedIn() {
			QBChat.instance().logout()
		}
	}
	
	
}

