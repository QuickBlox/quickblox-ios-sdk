//
//  TextFieldName.swift
//  UIKitSample
//
//  Created by Injoit on 14.06.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI

struct TextFieldName: View {
    @ObservedObject var theme: AppTheme
    
    let name: String
    var body: some View {
        return Text(name)
            .font(.system(size: 13, weight: .light))
            .foregroundColor(theme.color.mainText)
            .frame(height: 15, alignment: .leading)
    }
}
