//
//  AuthorizationViewController.m
//  sample-videochat-webrtc
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "AuthorizationViewController.h"
#import <Quickblox/Quickblox.h>
#import "LoadingButton.h"
#import "UIViewController+InfoScreen.h"
#import "Profile.h"
#import "UITextField+Videochat.h"
#import "UIColor+Videochat.h"
#import "NSString+Videochat.h"
#import "AppDelegate.h"
#import "InputContainer.h"
#import "AuthModule.h"
#import "ConnectionModule.h"
#import "NSError+Videochat.h"

NSString *const FULL_NAME_DID_CHANGE = @"Full Name Did Change";
NSString *const LOGIN_HINT = @"Use your email or alphanumeric characters in a range from 3 to 50. First character must be a letter.";
NSString *const DISPLAYNAME_HINT = @"Use alphanumeric characters and spaces in a range from 3 to 20. Cannot contain more than one space in a row.";
NSString *const CHECK_INTERNET = @"Please check your Internet connection";
NSString *const ENTER_LOGIN_AND_DISPLAYNAME = @"Enter your login and display name";
NSString *const ENTER_CHAT = @"Enter to Video Chat";
NSString *const LOGIN = @"Login";
NSString *const DISPLAY_NAME = @"Display name";
NSString *const SIGNG = @"Signg up ...";
NSString *const LOGIN_USER = @"Login with current user ...";
NSString *const LOGIN_CHAT = @"Login into Video Chat ...";
NSString *const DISPLAYNAME_REGEX = @"^(?=.{3,20}$)(?!.*([\\s])\\1{1})[\\w\\s]+$";
NSString *const LOGIN_REGEX = @"^[a-zA-Z][a-zA-Z0-9]{2,49}$";
NSString *const EMAIL_REGEX = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,49}$";

@interface AuthorizationViewController () <InputContainerDelegate, AuthModuleDelegate, ConnectionModuleDelegate>
//MARK: - IBOutlets
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *loginInfoLabel;
@property (weak, nonatomic) IBOutlet LoadingButton *loginButton;
//MARK: - Properties
@property (strong, nonatomic) InputContainer *loginInputContainer;
@property (strong, nonatomic) InputContainer *displayNameInputContainer;
@property (assign, nonatomic) BOOL needReconnect;
@property (strong, nonatomic) NSArray<InputContainer *> *inputContainers;
@property (strong, nonatomic) AuthModule *authModule;
@property (strong, nonatomic) ConnectionModule *connection;
@end

@implementation AuthorizationViewController
#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.authModule = [[AuthModule alloc] init];
    self.authModule.delegate = self;
    self.connection = [[ConnectionModule alloc] init];
    self.connection.delegate = self;
    
    self.loginInputContainer = [[NSBundle mainBundle] loadNibNamed:@"InputContainer" owner:nil options:nil].firstObject;
    [self.loginInputContainer setupWithTitle:LOGIN hint:LOGIN_HINT regexes:@[LOGIN_REGEX, EMAIL_REGEX]];
    [self.containerView addSubview:self.loginInputContainer];
    self.loginInputContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [self.loginInputContainer.leftAnchor constraintEqualToAnchor:self.containerView.leftAnchor].active = YES;
    [self.loginInputContainer.rightAnchor constraintEqualToAnchor:self.containerView.rightAnchor].active = YES;
    [self.loginInputContainer.topAnchor constraintEqualToAnchor:self.loginInfoLabel.bottomAnchor constant:28.0f].active = YES;
    self.loginInputContainer.delegate = self;
    
    self.displayNameInputContainer = [[NSBundle mainBundle] loadNibNamed:@"InputContainer" owner:nil options:nil].firstObject;
    [self.displayNameInputContainer setupWithTitle:DISPLAY_NAME hint:DISPLAYNAME_HINT regexes:@[DISPLAYNAME_REGEX]];
    [self.containerView addSubview:self.displayNameInputContainer];
    self.displayNameInputContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [self.displayNameInputContainer.leftAnchor constraintEqualToAnchor:self.containerView.leftAnchor].active = YES;
    [self.displayNameInputContainer.rightAnchor constraintEqualToAnchor:self.containerView.rightAnchor].active = YES;
    [self.displayNameInputContainer.topAnchor constraintEqualToAnchor:self.loginInputContainer.bottomAnchor].active = YES;
    self.displayNameInputContainer.delegate = self;
    
    self.inputContainers = @[self.loginInputContainer, self.displayNameInputContainer];
    
    self.loginButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.loginButton.centerXAnchor constraintEqualToAnchor:self.containerView.centerXAnchor].active = YES;
    [self.loginButton.topAnchor constraintEqualToAnchor:self.displayNameInputContainer.bottomAnchor constant:20.0f].active = YES;
    [self.loginButton.widthAnchor constraintEqualToConstant:215.0f].active = YES;
    [self.loginButton.heightAnchor constraintEqualToConstant:44.0f].active = YES;

    self.navigationItem.title = ENTER_CHAT;
    
    [self addInfoButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self defaultConfiguration];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    Profile *profile = [[Profile alloc] init];
    if (profile.isFull) {
        [self clearInputFields];
    }
}

#pragma mark - Setup
- (void)defaultConfiguration {
    [self.loginButton hideLoading];
    [self.loginButton setTitle:LOGIN
                      forState:UIControlStateNormal];
    self.loginButton.enabled = NO;
    [self setupInputEnabled:YES];
    self.loginInfoLabel.text = ENTER_LOGIN_AND_DISPLAYNAME;
}

- (void)clearInputFields {
    for (InputContainer *container in self.inputContainers) {
        [container clear];
    }
}

#pragma mark - Disable / Enable inputs
- (void)setupInputEnabled:(BOOL)enabled {
    for (InputContainer *container in self.inputContainers) {
        [container setInputEnabled:enabled];
    }
}

#pragma mark - UIControl Actions
- (IBAction)didPressLoginButton:(LoadingButton *)sender {
    NSString *displayName = self.displayNameInputContainer.text;
    NSString *login = self.loginInputContainer.text;
    if (sender.isAnimating == NO) {
        [self.authModule signUpWithFullName:displayName login:login];
        [self beginConnect];
    }
}

#pragma mark - Internal Methods
- (void)beginConnect {
    [self setEditing:NO];
    [self setupInputEnabled:NO];
    [self.loginButton showLoading];
}

#pragma mark - AuthModuleDelegate
- (void)authModule:(AuthModule *)authModule didSignUpUser:(QBUUser *)user {
    [Profile synchronizeUser:user];
    Profile *profile = [[Profile alloc] init];
    [authModule loginWithFullName:profile.fullName login:profile.login];
    self.loginInfoLabel.text = LOGIN_USER;
}

- (void)authModule:(AuthModule *)authModule didLoginUser:(QBUUser *)user {
    Profile *profile = [[Profile alloc] init];
    if ([user.fullName isEqualToString: profile.fullName] == NO) {
        [authModule updateFullName:profile.fullName];
        return;
    }
    [Profile synchronizeUser:user];
    [self.connection establish];
}

- (void)authModule:(AuthModule *)authModule didUpdateUpdateFullNameUser:(QBUUser *)user {
    self.loginInfoLabel.text = FULL_NAME_DID_CHANGE;
    [Profile synchronizeUser:user];
    [self.connection establish];
}

- (void)authModule:(AuthModule *)authModule didReceivedError:(NSError *)error {
    [self handleError:error];
}

#pragma mark - ConnectionModuleDelegate
- (void)connectionModuleDidConnect:(ConnectionModule *)connectionModule {
    if (self.onCompleteAuth) {
        self.onCompleteAuth();
    }
}

- (void)connectionModuleDidNotConnect:(ConnectionModule *)connectionModule withError:(NSError*)error {
    [self handleError:error];
}

#pragma mark - Handle errors
- (void)handleError:(NSError *)error {
    self.loginInfoLabel.text = error.localizedDescription;
    if (error.isNetworkError) {
        self.loginInfoLabel.text = CHECK_INTERNET;
    } else if (error.code == QBResponseStatusCodeUnAuthorized) {
        [Profile clear];
        [self defaultConfiguration];
    }
    [self setupInputEnabled:YES];
    [self.loginButton hideLoading];
}

#pragma mark - InputContainerDelegate
- (void)inputContainer:(nonnull InputContainer *)inputContainer didChangeValidState:(BOOL)isValid {
    if (isValid == NO) {
        [self.loginButton setEnabled: NO];
        return;
    }
    for (InputContainer *container in self.inputContainers) {
        if (!container.isValid) {
            [self.loginButton setEnabled: NO];
            return;
        }
    }
    [self.loginButton setEnabled: YES];
}

@end

