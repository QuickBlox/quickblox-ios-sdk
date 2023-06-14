//
//  TextFieldName.swift
//  QuickbloxSwiftUIChat
//
//  Created by Injoit.
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
