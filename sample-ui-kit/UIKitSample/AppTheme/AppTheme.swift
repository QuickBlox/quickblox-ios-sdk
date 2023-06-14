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
                                      image: QuickBloxUIKit.ThemeImage()),
                             AppTheme(color: CustomThemeColor1(),
                                      font: QuickBloxUIKit.ThemeFont(),
                                      image: QuickBloxUIKit.ThemeImage())
]

class AppTheme: ThemeProtocol, ObservableObject {
    @Published var color: ThemeColorProtocol
    @Published var font: ThemeFontProtocol
    @Published var image: ThemeImageProtocol
    
    init(color: ThemeColorProtocol,
         font: ThemeFontProtocol,
         image: ThemeImageProtocol) {
        self.color = color
        self.font = font
        self.image = image
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
