//
//  LoginScreen.swift
//  UIKitSample
//
//  Created by Injoit on 14.06.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import Quickblox
import QuickBloxUIKit

struct LoginConstant {
    static let enterToChat = "Login to Chat"
    static let login = "Enter your login and password"
    static let signUp = "Enter your login, display name and password"
}

enum Hint: String {
    case login = "Use your email or alphanumeric characters in a range from 3 to 50. First character must be a letter."
    case displayName = "Use alphanumeric characters and spaces in a range from 3 to 20. Cannot contain more than one space in a row."
    case password = "Use alphanumeric characters in a range from 8 to 12. First character must be a letter."
}

struct LoginScreen: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var viewModel: LoginViewModal
    @StateObject private var connect: Connect
    @State public var theme: AppTheme = appThemes[UserDefaults.standard.integer(forKey: "Theme")]
    @State private var loginInfo = LoginConstant.login
    @State private var selectedTabIndex: String = "chats" {
        didSet {
            dialogsPresented = selectedTabIndex == "chats"
        }
    }
    @State private var tabBarVisibility: Visibility = .visible
    @State private var dialogsPresented: Bool = false
    
    @State var selectedSegment: ThemeType?
    
    init(viewModel: LoginViewModal = LoginViewModal(), connect: Connect = Connect()) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _connect = StateObject(wrappedValue: connect)
        QuickBloxUIKit.feature.ai.openAIAPIKey = ""
        QuickBloxUIKit.settings.theme = theme
    }
    
    var body: some View {
        
        TabView(selection: $selectedTabIndex) {
            
            QuickBloxUIKit.dialogsView(onAppear: { appear in
                if selectedTabIndex == "chats" {
                    tabBarVisibility = appear == true ? Visibility.visible : Visibility.hidden
                }
            })
            .toolbar(tabBarVisibility, for: .tabBar)
            .tag("chats")
            .tabItem {
                Label("Chats", systemImage: "bubble.left.and.bubble.right.fill")
            }
            
            settingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }.tag("settings")
            
            authView()
                .tabItem {
                    Label(connect.authState == .unAuthorized ? "Enter" : "Exit",
                          systemImage: connect.authState == .unAuthorized
                          ? "figure.walk.arrival" : "figure.walk.departure")
                }.tag("auth")
            
                .onChange(of: connect.authState) { authState in
                    self.selectedTabIndex = authState == .authorized ? "chats" : "auth"
                }
                
        }
        .accentColor(theme.color.mainElements)
        .onAppear {
            QuickBloxUIKit.settings.dialogsScreen.header.leftButton.hidden = true
            self.selectedTabIndex = QBSession.current.currentUser != nil ? "chats" : "auth"
            self.connect.authState = QBSession.current.currentUser != nil
            ? AuthState.authorized : AuthState.unAuthorized
            theme = appThemes[UserDefaults.standard.integer(forKey: "Theme")]
        }
    }
    
    @ViewBuilder
    private func authView() -> some View {
        NavigationView {
            ZStack {
                theme.color.mainBackground.ignoresSafeArea()
                
                switch connect.authState {
                case .authorized:
                    
                    Button("Disconnect") {
                        connect.disconnect()
                    }
                    .padding()
                    .background(theme.color.incomingBackground)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    case .unAuthorized:
                    if viewModel.isSignUped {
                        loginView()
                    } else {
                        signUpView()
                    }
                }
            }
            .onAppear {
                theme = appThemes[UserDefaults.standard.integer(forKey: "Theme")]
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarTitle(LoginConstant.enterToChat, displayMode: .inline)
            .navigationBarHidden(true)
        }
    }
    
    @ViewBuilder
    private func signUpView() -> some View {
        VStack(spacing: 18) {
            InfoText(loginInfo: $loginInfo).padding(.top, 44)
            
            LoginTextField(theme: theme,
                           login: $viewModel.login,
                           isValidLogin: $viewModel.isValidLogin)
            
            DisplayNameTextField(theme: theme,
                                 displayName: $viewModel.displayName,
                                 isValidDisplayName: $viewModel.isValidDisplayName)
            
            PasswordTextField(theme: theme,
                              password: $viewModel.password,
                              isValidPassword: $viewModel.isValidPassword)
            
            LoginButton("SignUp",
                        isValidForm: $viewModel.isSignUpValidForm,
                        onTapped: {
                connect.signUp(withLogin: viewModel.login,
                               displayName: viewModel.displayName,
                               password: viewModel.password)
            }, theme: theme)
            
            Spacer()
            
            Button("Login") {
                viewModel.isSignUped = true
                loginInfo = LoginConstant.login
            }
            .padding()
            .background(theme.color.incomingBackground)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
        }
        .padding()
    }
    
    @ViewBuilder
    private func loginView() -> some View {
        VStack(spacing: 18) {
                InfoText(loginInfo: $loginInfo).padding(.top, 44)
                
                LoginTextField(theme: theme,
                               login: $viewModel.login,
                               isValidLogin: $viewModel.isValidLogin)
                
                PasswordTextField(theme: theme,
                                  password: $viewModel.password,
                                  isValidPassword: $viewModel.isValidPassword)
                
                LoginButton("Login",
                            isValidForm: $viewModel.isLoginValidForm,
                            onTapped: {
                    connect.login(withLogin: viewModel.login,
                                  password: viewModel.password)
                }, theme: theme)
                
                Spacer()
                
                Button("SignUp") {
                    viewModel.isSignUped = false
                    loginInfo = LoginConstant.signUp
                }
                .padding()
                .background(theme.color.incomingBackground)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }.padding()
    }
    
    @ViewBuilder
    private func settingsView() -> some View {
        ThemeSelectBar(theme: theme, selectedSegment: $selectedSegment)
            .onChange(of: selectedSegment) { selectedSegment in
                if let selectedSegment {
                    theme = switchTheme(selectedSegment)
                    QuickBloxUIKit.settings.theme = theme
                }
            }
    }
    
    private func switchTheme(_ themeType: ThemeType) -> AppTheme {
        UserDefaults.standard.set(themeType.rawValue, forKey: "Theme")
        switch themeType {
        case .CustomTheme:
            UserDefaults.standard.set(1, forKey: "Theme")
            return appThemes[1]
        default:
            UserDefaults.standard.set(0, forKey: "Theme")
            return appThemes[0]
        }
    }
    
    private struct InfoText: View {
        @Binding var loginInfo: String
        var body: some View {
            return Text(loginInfo)
                .font(.system(size: 16, weight: .light))
                .foregroundColor(.primary)
        }
    }
}

struct LoginScreen_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LoginScreen()
            LoginScreen()
                .preferredColorScheme(.dark)
        }
    }
}
