//
//  AppTheme.swift
//  UIKitSample
//
//  Created by Injoit on 15.04.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxUIKit

var appThemes: [AppTheme] = [AppTheme(color: QuickBloxUIKit.ThemeColor(),
                                      font: QuickBloxUIKit.ThemeFont(),
                                      image: QuickBloxUIKit.ThemeImage(),
                                      string: CustomThemeString()),
                             AppTheme(color: CustomThemeColor1(),
                                      font: QuickBloxUIKit.ThemeFont(),
                                      image: QuickBloxUIKit.ThemeImage(),
                                      string: CustomThemeString())
]

class AppTheme: ThemeProtocol, ObservableObject {
    @Published var color: ThemeColorProtocol
    @Published var font: ThemeFontProtocol
    @Published var image: ThemeImageProtocol
    @Published var string: ThemeStringProtocol
    
    init(color: ThemeColorProtocol,
         font: ThemeFontProtocol,
         image: ThemeImageProtocol,
         string: ThemeStringProtocol) {
        self.color = color
        self.font = font
        self.image = image
        self.string = string
    }
}

class CustomThemeColor1: ThemeColorProtocol, ObservableObject {
    var mainElements: Color = Color("MainElements1")
    var secondaryElements: Color = Color("SecondaryElements1")
    var tertiaryElements: Color = Color("TertiaryElements1")
    var disabledElements: Color = Color("DisabledElements1")
    var mainText: Color = Color("MainText1")
    var secondaryText: Color = Color("SecondaryText1")
    var caption: Color = Color("Caption1")
    var mainBackground: Color = Color("MainBackground1")
    var secondaryBackground: Color = Color("SecondaryBackground1")
    var tertiaryBackground: Color = Color("TertiaryBackground1")
    var incomingBackground: Color = Color("IncomingBackground1")
    var outgoingBackground: Color = Color("OutgoingBackground1")
    var dropdownBackground: Color = Color("DropdownBackground1")
    var inputBackground: Color = Color("InputBackground1")
    var divider: Color = Color("Divider1")
    var error: Color = Color("Error1")
    var success: Color = Color("Success1")
    var highLight: Color = Color("HighLight1")
    var system: Color = Color("System1")
    
    init() {}
}

public class CustomThemeString: ThemeStringProtocol {
    public var dialogsEmpty: String = String(localized: "dialog.items.empty")
    public var usersEmpty: String = String(localized: "dialog.members.empty")
    public var messegesEmpty: String = String(localized: "dialog.messages.empty")

    public var privateDialog: String = String(localized: "dialog.type.private")
    public var groupDialog: String = String(localized: "dialog.type.group")
    public var publicDialog: String = String(localized: "dialog.type.group")

    public var typingOne: String = String(localized: "dialog.typing.one")
    public var typingTwo: String = String(localized: "dialog.typing.two")
    public var typingFour: String = String(localized: "dialog.typing.four")

    public var enterName: String = String(localized: "alert.actions.enterName")
    public var nameHint: String = String(localized: "dialog.name.hint")
    public var create: String = String(localized: "dialog.name.create")
    public var next: String = String(localized: "dialog.name.next")
    public var search: String = String(localized: "dialog.name.search")
    public var edit: String = String(localized: "dialog.info.edit")
    public var members: String = String(localized: "dialog.info.members")
    public var notification: String = String(localized: "dialog.info.notification")
    public var searchInDialog: String = String(localized: "dialog.info.searchInDialog")
    public var leaveDialog: String = String(localized: "dialog.info.leaveDialog")

    public var you: String = String(localized: "dialog.info.you")
    public var admin: String = String(localized: "dialog.info.admin")
    public var typeMessage: String = String(localized: "dialog.action.typeMessage")

    public var dialogs: String = String(localized: "screen.title.dialogs")
    public var dialog: String = String(localized: "screen.title.dialog")
    public var dialogType: String = String(localized: "screen.title.dialogType")
    public var newDialog: String = String(localized: "screen.title.newDialog")
    public var createDialog: String = String(localized: "screen.title.createDialog")
    public var addMembers: String = String(localized: "screen.title.addMembers")
    public var dialogInformation: String = String(localized: "screen.title.dialogInformation")

    public var add: String = String(localized: "alert.actions.add")
    public var dialogName: String = String(localized: "alert.actions.dialogName")
    public var changeImage: String = String(localized: "alert.actions.changeImage")
    public var changeDialogName: String = String(localized: "alert.actions.changeDialogName")

    public var photo: String = String(localized: "alert.actions.photo")
    public var removePhoto: String = String(localized: "alert.actions.removePhoto")
    public var camera: String = String(localized: "alert.actions.camera")
    public var gallery: String = String(localized: "alert.actions.gallery")
    public var file: String = String(localized: "alert.actions.file")

    public var remove: String = String(localized: "alert.actions.remove")
    public var cancel: String = String(localized: "alert.actions.cancel")
    public var ok: String = String(localized: "alert.actions.ok")
    public var removeUser: String = String(localized: "alert.message.removeUser")
    public var questionMark: String = String(localized: "alert.message.questionMark")
    public var errorValidation: String = String(localized: "alert.message.errorValidation")
    public var addUser: String = String(localized: "alert.message.addUser")
    public var toDialog: String = String(localized: "alert.message.toDialog")
    public var noResults: String = String(localized: "alert.message.noResults")
    public var noMembers: String = String(localized: "alert.message.noMembers")

    public var maxSize: String = String(localized: "attachment.maxSize.title")
    public var maxSizeHint: String = String(localized: "attachment.maxSize.hint")
    public var fileTitle: String  = String(localized: "attachment.title.file")
    public var gif: String = String(localized: "attachment.title.gif")

    public init() {}
}
