//
//  ThemeSelectBar.swift
//  UIKitSample
//
//  Created by Injoit on 14.06.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxUIKit

struct ThemeSelectBar: View {
    @ObservedObject var theme: AppTheme
    
    @Binding var selectedSegment: ThemeType?
    public var displayedTypes: [ThemeType] = [.CustomTheme, .QBTheme]
    
    var body: some View {
        NavigationView {
            ZStack {
                theme.color.mainBackground.ignoresSafeArea()
                HStack(spacing: 40) {
                    ForEach(displayedTypes, id:\.self) { theme in
                        VStack(spacing: 8) {
                            Text(theme.rawValue)
                                .font(.footnote)
                                .foregroundColor(Color.primary)
                            ZStack(alignment: .center) {
                                Rectangle()
                                    .frame(width: 124, height: 124)
                                    .cornerRadius(10)
                                Button {
                                    selectedSegment = theme
                                } label: {
                                    
                                    theme.image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 120, height: 120)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                }
                .frame(height: 144)
                
            }
        }
    }
}

enum ThemeType: String {
    case QBTheme
    case CustomTheme
    
    var image: Image {
        switch self {
        case .QBTheme: return Image("QBTheme")
        case .CustomTheme: return Image("CustomTheme")
        }
    }
}
