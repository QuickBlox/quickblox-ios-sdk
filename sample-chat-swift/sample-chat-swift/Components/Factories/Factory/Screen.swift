//
//  ModuleFactory.swift
//  sample-chat-swift
//
//  Created by Injoit on 01.09.2020.
//  Copyright © 2020 QuickBlox. All rights reserved.
//

import Foundation

final class Screen {
    class func authViewController() -> AuthViewController? {
        return AuthViewController.controllerFromStoryboard(.auth)
    }
    
    class func splashScreenController() -> SplashScreenViewController? {
        return SplashScreenViewController.controllerFromStoryboard(.auth)
    }
    
    class func dialogsViewController() -> DialogsViewController? {
        return DialogsViewController.controllerFromStoryboard(.dialogs)
    }
    
    class func dialogsSelectionViewController() -> DialogsSelectionViewController? {
        return DialogsSelectionViewController.controllerFromStoryboard(.dialogs)
    }
    
    class func createNewDialogViewController() -> CreateNewDialogViewController? {
        return CreateNewDialogViewController.controllerFromStoryboard(.dialogs)
    }
    
    class func userListViewController(nonDisplayedUsers: [UInt]) -> UserListViewController? {
        return UserListViewController(nibName: nil, bundle: nil, nonDisplayedUsers: nonDisplayedUsers)
    }
    
    class func searchUsersViewController(nonDisplayedUsers: [UInt], searchText: String) -> SearchUsersViewController? {
        return SearchUsersViewController(nibName: nil, bundle: nil, nonDisplayedUsers: nonDisplayedUsers, searchText: searchText)
    }
    
    class func usersInfoViewController(nonDisplayedUsers: [UInt]) -> UsersInfoViewController? {
        return UsersInfoViewController(nibName: nil, bundle: nil, nonDisplayedUsers: nonDisplayedUsers)
    }
    class func viewedByViewController(nonDisplayedUsers: [UInt]) -> ViewedByViewController? {
        return ViewedByViewController(nibName: nil, bundle: nil, nonDisplayedUsers: nonDisplayedUsers)
    }
    
    class func addOccupantsVC() -> AddOccupantsVC? {
        return AddOccupantsVC.controllerFromStoryboard(.chat)
    }
    
    class func chatViewController() -> ChatViewController? {
        return ChatViewController.controllerFromStoryboard(.chat)
    }
    
    class func selectAssetsViewController() -> SelectAssetsViewController? {
        return SelectAssetsViewController.controllerFromStoryboard(.chat)
    }
    
    class func infoTableViewController() -> InfoTableViewController? {
        return InfoTableViewController.controllerFromStoryboard(.infoApp)
    }
}
