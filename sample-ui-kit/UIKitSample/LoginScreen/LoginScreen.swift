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
    
    static let  authorization = "Authorization Processing..."
    static let authorized = "Authorization Successful!"
    static let unAuthorized = "Authorization Failed"
}

enum Hint: String {
    case login = "Use your email or alphanumeric characters in a range from 3 to 50. First character must be a letter."
    case displayName = "Use alphanumeric characters and spaces in a range from 3 to 20. Cannot contain more than one space in a row."
    case password = "Use alphanumeric characters in a range from 8 to 12. First character must be a letter."
}

struct LoginScreen: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var viewModel: LoginViewModal
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
    
    private let openWithTabBar: Bool = true //Setting this variable to true will show an example of choosing a color theme of the user's choice and with TabBar
    
    init(viewModel: LoginViewModal = LoginViewModal()) {
        _viewModel = StateObject(wrappedValue: viewModel)
        viewModel.authState = QBSession.current.currentUser != nil
        ? AuthState.authorized : AuthState.unAuthorized
        setupFeatures()
    }
    
    var body: some View {
        
        container()
            .environmentObject(viewModel)
        
        //Option to open UIKit directly after user authorization in the QuickBlox system.
        // Upon successful authorization, when viewModel.authState == .authorized the UIKit’s Dialogues screen will automatically open.
            .if(openWithTabBar == false && viewModel.authState == .authorized, transform: { view in
                // The entry point to the QuickBlox iOS UI Kit.
                QuickBloxUIKit.dialogsView(onExit: {
                    // Handling an event when exiting the QuickBloxUIKit e.g. disconnect and logout
                    viewModel.disconnect()
                })
            })
    }
    
    @ViewBuilder
    private func container() -> some View {
        switch viewModel.authState {
        case .unAuthorized, .authorization:
            authView()
        case .authorized:
            
            TabView(selection: $selectedTabIndex) {
                
                QuickBloxUIKit.dialogsView(onAppear: { appear in
                    if selectedTabIndex == "chats" {
                        tabBarVisibility = appear == true ? Visibility.visible : Visibility.hidden
                    }
                })
                .toolbar(tabBarVisibility, for: .tabBar)
                .toolbarBackground(theme.color.mainBackground, for: .tabBar)
                .toolbarBackground(tabBarVisibility, for: .tabBar)
                .tag("chats")
                .tabItem {
                    Label("Chats", systemImage: "bubble.left.and.bubble.right.fill")
                }
                
                settingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape")
                    }.tag("settings")
                
                disconnectView()
                    .tabItem {
                        Label(viewModel.authState == .unAuthorized ? "Enter" : "Exit",
                              systemImage: viewModel.authState == .unAuthorized
                              ? "figure.walk.arrival" : "figure.walk.departure")
                    }.tag("auth")
                
                    .onChange(of: viewModel.authState) { authState in
                        self.selectedTabIndex = authState == .authorized ? "chats" : "auth"
                    }
            }
            .accentColor(theme.color.mainElements)
            .onAppear {
                selectedTabIndex = QBSession.current.currentUser != nil ? "chats" : "auth"
                viewModel.authState = QBSession.current.currentUser != nil
                ? AuthState.authorized : AuthState.unAuthorized
                theme = appThemes[UserDefaults.standard.integer(forKey: "Theme")]
                setupSettings()
                tabBarVisibility = .visible
            }
        }
    }
    
    @ViewBuilder
    private func disconnectView() -> some View {
        ZStack {
            theme.color.mainBackground.ignoresSafeArea()
            Button("Disconnect") {
                viewModel.disconnect()
            }
            .padding()
            .background(theme.color.incomingBackground)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .onAppear {
            theme = appThemes[UserDefaults.standard.integer(forKey: "Theme")]
            tabBarVisibility = Visibility.visible
        }
    }
    
    @ViewBuilder
    private func authView() -> some View {
        NavigationView {
            ZStack {
                theme.color.mainBackground.ignoresSafeArea()
                if viewModel.isSignUped {
                    loginView()
                } else {
                    signUpView()
                }
            }
            .onAppear {
                theme = appThemes[UserDefaults.standard.integer(forKey: "Theme")]
                tabBarVisibility = Visibility.hidden
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
                viewModel.signUp(withLogin: viewModel.login,
                               displayName: viewModel.displayName,
                               password: viewModel.password)
            }, theme: theme)
            
            .onChange(of: viewModel.authState) { authState in
                switch authState {
                case .authorization: loginInfo = LoginConstant.authorization
                case .authorized: loginInfo = LoginConstant.authorized
                case .unAuthorized: loginInfo = LoginConstant.unAuthorized
                }
            }
            
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
        .onAppear {
            tabBarVisibility = Visibility.hidden
        }
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
                viewModel.login(withLogin: viewModel.login,
                              password: viewModel.password)
            }, theme: theme)
            
            .onChange(of: viewModel.authState) { authState in
                switch authState {
                case .authorization: loginInfo = LoginConstant.authorization
                case .authorized: loginInfo = LoginConstant.authorized
                case .unAuthorized: loginInfo = LoginConstant.unAuthorized
                }
            }
            
            Spacer()
            
            Button("SignUp") {
                viewModel.isSignUped = false
                loginInfo = LoginConstant.signUp
            }
            .padding()
            .background(theme.color.incomingBackground)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding()
        .onAppear {
            tabBarVisibility = Visibility.hidden
        }
    }
    
    @ViewBuilder
    private func settingsView() -> some View {
        ThemeSelectBar(theme: theme, selectedSegment: $selectedSegment)
            .onChange(of: selectedSegment) { selectedSegment in
                if let selectedSegment {
                    theme = switchTheme(selectedSegment)
                    setupSettings()
                }
            }
            .onAppear {
                tabBarVisibility = Visibility.visible
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
    
    private func setupSettings() {
        // Setup Custom Theme
        QuickBloxUIKit.settings.theme = theme
        
        // Hide backButton for Dialogs Screen
        if openWithTabBar == true {
            QuickBloxUIKit.settings.dialogsScreen.header.leftButton.hidden = true
        }
        
        // Setup Background Image for Dialog Screen
        QuickBloxUIKit.settings.dialogScreen.backgroundImage = Image("dialogBackground")
        QuickBloxUIKit.settings.dialogScreen.backgroundImageColor = theme.color.divider
    }
    
    private func setupFeatures() {
        QuickBloxUIKit.feature.ai.apiKey = ""
        QuickBloxUIKit.feature.ai.ui = AIUISettings(theme)
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
