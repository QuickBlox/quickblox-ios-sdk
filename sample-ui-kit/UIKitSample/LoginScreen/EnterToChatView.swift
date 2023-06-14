//
//  EnterToChatView.swift
//  UIKitSample
//
//  Created by Injoit.
//

import SwiftUI
import QuickBloxUIKit
import Quickblox

struct EnterConstant {
    static let enterToChat = "Enter to SwiftUIChat"
}

struct ShowQuickBlox: View {
    var body: some View {
        QuickBloxUIKit.dialogsView()
    }
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
            QuickBloxUIKit.dialogsView()
        }
        .navigationBarTitle(EnterConstant.enterToChat, displayMode: .inline)
        .navigationBarHidden(true)
    }
}
