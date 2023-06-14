//
//  BaseTextField.swift
//  UIKitSample
//
//  Created by Injoit.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI

struct BaseTextField: View {
    
    @ObservedObject var theme: AppTheme
    @Binding var isValidText: Bool
    @Binding var text: String
   
    @State private var isFocused: Bool = false
    private var invalidTextHint: String
    private var textFieldName: String
    private var hint: String {
        if isFocused == false {
            return ""
        }
        return isValidText ? "" : invalidTextHint
    }
    
    private var accentColor: Color = .black
    
     init(textFieldName: String, text: Binding<String>, isValidText: Binding<Bool>, invalidTextHint: String, theme: AppTheme) {
         self.theme = theme
        self.textFieldName = textFieldName
        self._text = text
        self._isValidText = isValidText
        self.invalidTextHint = invalidTextHint
    }
    
     var body: some View {
        return VStack(alignment: .leading, spacing: 11) {
            TextFieldName(theme: theme, name: textFieldName)
            
            TextField("", text: $text, onEditingChanged: {isEdit in
                            isFocused = isEdit
                        })
            .accentColor(.blue)
                        .onChange(of: text, perform: { newValue in
                            self.text = newValue
                        })
                        .font(.system(size: 17, weight: .thin))
                        .foregroundColor(theme.color.mainText)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                        .frame(height: 44)
                        .padding(.horizontal, 12)
                        .background(theme.color.inputBackground)
                        .cornerRadius(4.0)
                        .shadow(color: isFocused == true ? accentColor.opacity(0.2) : accentColor.opacity(0.0),
                                radius: 4, x: 0, y: 8)

            
            TextFieldHint(hint: hint)
        }
    }
}
