//
//  EnterToChatView.swift
//  UIKitSample
//
//  Created by Injoit on 14.06.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxUIKit
import Quickblox

struct EnterConstant {
    static let enterToChat = "Enter to SwiftUIChat"
}

struct EnterToChatView: View {
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var theme: AppTheme
    
    @State var isPresented = false
    
    init(theme: AppTheme) {
        self.theme = theme
        QuickBloxUIKit.settings.theme = theme
    }
    
    var body: some View {
        ZStack {
            theme.color.mainBackground.ignoresSafeArea()
            
            VStack {
                Spacer()
                Button("Change Theme/ Go back") {
                    dismiss()
                }
                .padding()
                .background(theme.color.incomingBackground)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                Spacer()
                
                // Button to enter the QuickBlox IOS UI Kit.
                Button(action: {
                    withAnimation {
                        self.isPresented = true
                    }
                }, label: {
                    Text(EnterConstant.enterToChat)
                })
                .padding()
                .background(theme.color.mainElements)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
        .fullScreenCover(isPresented: $isPresented) {
            QuickBloxUIKit.dialogsView() // The entry point to the QuickBlox iOS UI Kit.
        }
        .navigationBarTitle(EnterConstant.enterToChat, displayMode: .inline)
        .navigationBarHidden(true)
    }
}
