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
                                      font: CustomThemeFont(),
                                      image: CustomImageTheme(),
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

public class CustomThemeFont: ThemeFontProtocol {
    public var headline: Font = .custom("Menlo", size: 17)
    public var footnote: Font = .custom("Menlo", size: 13)
    public var caption: Font = .custom("Menlo", size: 12)
    public var caption2: Font = .custom("Menlo", size: 11)
    public var callout: Font = .custom("Menlo", size: 17)
    public var largeTitle: Font = .custom("Menlo", size: 34)
    public var title1: Font = .custom("Menlo", size: 28)
    public var title3: Font = .custom("Menlo", size: 20)
    
    public init() {}
}

public class CustomImageTheme: ThemeImageProtocol {
    public var avatarUser: Image = Image("AvatarUser")
    public var avatarGroup: Image = Image("AvatarGroup")
    public var avatarPublic: Image = Image("AvatarPublic")
    public var user: Image = Image(systemName: "person")
    public var groupChat: Image = Image(systemName: "person.3") // default: person.2
    public var publicChannel: Image = Image(systemName: "megaphone")
    public var leave: Image = Image(systemName: "person.fill.xmark") // default: rectangle.portrait.and.arrow.forward
    public var leavePNG: Image = Image("Leave")
    public var newChat: Image = Image(systemName: "square.and.pencil")
    public var back: Image = Image(systemName: "chevron.backward")
    public var close: Image = Image(systemName: "xmark")
    public var conference: Image = Image(systemName: "person.3")
    public var chat: Image = Image(systemName: "message")
    public var camera: Image = Image(systemName: "camera")
    public var avatarCamera: Image = Image("AvatarCamera")
    public var checkmark: Image = Image(systemName: "checkmark")
    public var attachmentPlaceholder: Image = Image("attachmentPlaceholder")
    public var info: Image = Image(systemName: "info.circle")
    public var bell: Image = Image(systemName: "bell")
    public var magnifyingglass: Image = Image(systemName: "magnifyingglass.circle") // default: magnifyingglass
    public var chevronForward: Image = Image(systemName: "chevron.forward")
    public var trash: Image = Image(systemName: "trash")
    public var plus: Image = Image(systemName: "plus.app")
    public var mic: Image = Image(systemName: "mic")
    public var smiley: Image = Image(systemName: "smiley")
    public var paperclip: Image = Image(systemName: "paperclip")
    public var paperplane: Image = Image(systemName: "paperplane.fill")
    public var keyboard: Image = Image(systemName: "keyboard")
    public var record: Image = Image(systemName: "record.circle")
    public var wave: Image = Image("wave")
    public var play: Image = Image(systemName: "play.fill")
    public var pause: Image = Image(systemName: "pause.fill")
    public var photo: Image = Image(systemName: "photo")
    public var delivered: Image = Image("delivered")
    public var read: Image = Image("delivered")
    public var send: Image = Image("send")
    public var doctext: Image = Image(systemName: "doc.text.fill")
    public var speakerwave: Image = Image(systemName: "speaker.wave.1.fill")
    public var message: Image = Image(systemName: "message")
    public var robot: Image = Image("Robot")
    public var translate: Image = Image("Translate")
    
    public init() {}
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
    public var invalidAIAnswerAssist: String = String(localized: "alert.message.invalidAIAnswerAssist")
    public var invalidAITranslate: String = String(localized: "alert.message.invalidAITranslate")
    public var invalidAIRephrase: String = String(localized: "alert.message.invalidAIRephrase")

    public var maxSize: String = String(localized: "attachment.maxSize.title")
    public var maxSizeHint: String = String(localized: "attachment.maxSize.hint")
    public var fileTitle: String  = String(localized: "attachment.title.file")
    public var gif: String = String(localized: "attachment.title.gif")
    
    public var showOriginal: String = String(localized: "ai.translate.showOriginal")
    public var showTranslation: String = String(localized: "ai.translate.showTranslation")
    public var answerAssistTitle: String = String(localized: "ai.answerAssist.title")
    
    public var permissionCameraTitle: String = String(localized: "permission.camera.title")
    public var permissionCameraMessage: String = String(localized: "permission.camera.message")
    public var permissionMicrophoneTitle: String = String(localized: "permission.microphone.title")
    public var permissionMicrophoneMessage: String = String(localized: "permission.microphone.message")
    public var permissionActionCancel: String = String(localized: "permission.actions.cancel")
    public var permissionActionSettings: String = String(localized: "permission.actions.settings")
    
    public var createdGroupChat: String = String(localized: "utils.string.createdGroupChat")
    public var dialogRenamedByUser: String = String(localized: "utils.string.dialogRenamedByUser")
    public var avatarWasChanged: String = String(localized: "utils.string.avatarWasChanged")
    public var addedBy: String = String(localized: "utils.string.addedBy")
    public var removedBy: String = String(localized: "utils.string.removedBy")
    public var hasLeft: String = String(localized: "utils.string.hasLeft")

    public init() {}
}
