//
//  ModuleFactory.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 01.09.2020.
//  Copyright © 2020 QuickBlox. All rights reserved.
//

import Foundation

final class Screen {
    class func authViewController() -> AuthViewController? {
        return AuthViewController.controllerFromStoryboard(.auth)
    }
    
    class func usersViewController() -> UsersViewController? {
        return UsersViewController.controllerFromStoryboard(.users)
    }
    
    class func sharingViewController() -> SharingViewController? {
        return SharingViewController.controllerFromStoryboard(.call)
    }
    
    class func videoCallViewController() -> VideoCallViewController? {
        return VideoCallViewController.controllerFromStoryboard(.call)
    }
    
    class func audioCallViewController() -> AudioCallViewController? {
        return AudioCallViewController.controllerFromStoryboard(.call)
    }
    
    class func infoTableViewController() -> InfoTableViewController? {
        return InfoTableViewController.controllerFromStoryboard(.infoApp)
    }
    
    class func selectedUsersCountAlert() -> SelectedUsersCountAlert? {
        return SelectedUsersCountAlert.controllerFromStoryboard(.users)
    }
}
