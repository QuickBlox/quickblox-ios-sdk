//
//  LoginTextField.swift
//  UIKitSample
//
//  Created by Injoit on 14.06.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI

public struct LoginTextField : View {
    @ObservedObject var theme: AppTheme
    
    @Binding public var login: String
    @Binding var isValidLogin: Bool
    
    public var body: some View {
        BaseTextField(textFieldName: "Login",
                      text: $login,
                      isValidText: $isValidLogin,
                      invalidTextHint: Hint.login.rawValue, theme: theme)
    }
}
