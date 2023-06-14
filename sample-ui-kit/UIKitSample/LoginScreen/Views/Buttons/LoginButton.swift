//
//  LoginButton.swift
//  QuickbloxSwiftUIChat
//
//  Created by Injoit.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI

struct LoginButton : View {
    @ObservedObject var theme: AppTheme
    
    let name: String
    @Binding  var isValidForm: Bool
    
     var onTapped: (() -> Void)
    
    init(_ name: String, isValidForm: Binding<Bool>, onTapped: @escaping () -> Void, theme: AppTheme) {
        self.name = name
        self._isValidForm = isValidForm
        self.onTapped = onTapped
        self.theme = theme
    }

     var body: some View {
        return Button {
            onTapped()
        } label: {
            Text(name)
                .foregroundColor(.white)
                .font(.system(size: 18))
                .frame(width: 215, height: 44, alignment: .center)
        }
        .disabled(isValid == false)
        .background(isValid ? theme.color.mainElements : theme.color.disabledElements)
        .cornerRadius(4)
        .shadow(color: isValid ? theme.color.mainElements.opacity(0.7) : .clear,
                radius: 14, x: 0, y: 9)
        .padding(.top, 36)
    }
    
    private var isValid: Bool {
        return isValidForm
    }
}
