//
//  ModuleFactory.swift
//  sample-conference-videochat-swift
//
//  Created by Injoit on 01.09.2020.
//  Copyright © 2020 QuickBlox. All rights reserved.
//

import Foundation

final class ScreenFactory:
    AuthModuleFactory,
    DialogsModuleFactory,
    ChatModuleFactory,
    SharingModuleFactory,
    ConferenceModuleFactory {
  
    func makeSplashScreenOutput() -> SplashScreen {
        return SplashScreenViewController.controllerFromStoryboard(.auth)
    }
    
    func makeLoginOutput() -> LoginView {
        return AuthViewController.controllerFromStoryboard(.auth)
    }
    
    func makeDialogsOutput() -> DialogsView {
        return DialogsViewController.controllerFromStoryboard(.dialogs)
    }
    
    func makeSelectionDialogsOutput() -> DialogsSelectionViewController? {
        return DialogsSelectionViewController.controllerFromStoryboard(.dialogs)
    }
    
    func makeCreateNewDialogOutput() -> CreateNewDialogViewController? {
        return CreateNewDialogViewController.controllerFromStoryboard(.dialogs)
    }
    
    func makeChatOutput() -> ChatView {
        return ChatViewController.controllerFromStoryboard(.chat)
    }
    
    func makeInfoUsersOutput() -> UsersInfoTableViewController? {
        return UsersInfoTableViewController.controllerFromStoryboard(.chat)
    }
    
    func makeActionsMenuOutput() -> MenuViewController? {
        return MenuViewController.controllerFromStoryboard(.chat)
    }
    
    func makeInfoUpOutput() -> InfoTableViewController? {
        return InfoTableViewController.controllerFromStoryboard(.infoApp)
    }
    
    func makeVideoSettingsOutput() -> VideoSettingsViewController? {
        return VideoSettingsViewController.controllerFromStoryboard(.dialogs)
    }
    
    func makeAudioSettingsOutput() -> AudioSettingsViewController? {
        return AudioSettingsViewController.controllerFromStoryboard(.dialogs)
    }
    
    func makeSelectAssetsOutput() -> SelectAssetsViewController? {
        return SelectAssetsViewController.controllerFromStoryboard(.chat)
    }
    
    
    
    func makeSharingOutput() -> SharingView {
        return SharingViewController()
    }
    

    func makeConferenceOutput(withSettings conferenceSettings: ConferenceSettings) -> ConferenceView {
        return ConferenceViewController(conferenceSettings: conferenceSettings)
    }
    
    func makeStreamInitiatorOutput(withSettings conferenceSettings: ConferenceSettings) -> ConferenceView {
       return StreamInitiatorViewController(conferenceSettings: conferenceSettings)
    }
    
    func makeStreamParticipantOutput(withSettings conferenceSettings: ConferenceSettings) -> ConferenceView {
        return StreamParticipantViewController(conferenceSettings: conferenceSettings)
    }
}
