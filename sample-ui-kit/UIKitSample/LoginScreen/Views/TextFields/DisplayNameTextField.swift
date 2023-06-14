//
//  DisplayNameTextField.swift
//  UIKitSample
//
//  Created by Injoit.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI

public struct DisplayNameTextField : View {
    @ObservedObject var theme: AppTheme
    
    @Binding public var displayName: String
    @Binding var isValidDisplayName: Bool
    
    public var body: some View {
        BaseTextField(textFieldName: "DisplayName",
                      text: $displayName,
                      isValidText: $isValidDisplayName,
                      invalidTextHint: Hint.displayName.rawValue, theme: theme)
    }
}


public struct PasswordTextField : View {
    @ObservedObject var theme: AppTheme
    
    @Binding public var password: String
    @Binding var isValidPassword: Bool
    
    public var body: some View {
        BaseTextField(textFieldName: "Password",
                      text: $password,
                      isValidText: $isValidPassword,
                      invalidTextHint: Hint.password.rawValue, theme: theme)
    }
}
