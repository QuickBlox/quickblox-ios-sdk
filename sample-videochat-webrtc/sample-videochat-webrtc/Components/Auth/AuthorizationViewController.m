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

NSString *const DEFAULT_PASSWORD = @"quickblox";
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

@interface AuthorizationViewController () <InputContainerDelegate>
//MARK: - IBOutlets
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *loginInfoLabel;
@property (weak, nonatomic) IBOutlet LoadingButton *loginButton;
//MARK: - Properties
@property (strong, nonatomic) InputContainer *loginInputContainer;
@property (strong, nonatomic) InputContainer *displayNameInputContainer;
@property (assign, nonatomic) BOOL needReconnect;
@property (strong, nonatomic) NSArray<InputContainer *> *inputContainers;
@end

@implementation AuthorizationViewController
#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
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
- (void)showUsersScreen {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Users" bundle:nil];
    UIViewController *users = [storyboard instantiateViewControllerWithIdentifier:@"UsersViewController"];
    [self.navigationController pushViewController:users animated:NO];
}

- (void)defaultConfiguration {
    self.loginButton.isLoading = NO;
    [self.loginButton setTitle:LOGIN
                      forState:UIControlStateNormal];
    self.loginButton.enabled = NO;
    [self setupInputEnabled:YES];
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
    if (sender.isLoading == NO) {
        [self signUpWithDisplayName:displayName login:login];
    }
}

#pragma mark - Internal Methods
- (void)signUpWithDisplayName:(NSString *)displayName login:(NSString *)login {
    [self beginConnect];
    QBUUser *newUser = [[QBUUser alloc] init];
    newUser.login = login;
    newUser.fullName = displayName;
    newUser.password = DEFAULT_PASSWORD;
    
    self.loginInfoLabel.text = SIGNG;
    
    __weak __typeof(self)weakSelf = self;
    [QBRequest signUp:newUser successBlock:^(QBResponse * _Nonnull response, QBUUser * _Nonnull user) {
        __typeof(weakSelf)strongSelf = weakSelf;
        
        [strongSelf loginWithDisplayName:displayName login:login password:DEFAULT_PASSWORD];
        
    } errorBlock:^(QBResponse * _Nonnull response) {
        __typeof(weakSelf)strongSelf = weakSelf;
        if (response.status == QBResponseStatusCodeValidationFailed) {
            // The user with existent login was created earlier
            [strongSelf loginWithDisplayName:displayName login:login password:DEFAULT_PASSWORD];
            return;
        }
        [strongSelf handleError:response.error.error];
    }];
}

- (void)loginWithDisplayName:(NSString *)displayName login:(NSString *)login password:(NSString *)password {
    [self beginConnect];
    
    self.loginInfoLabel.text = LOGIN_USER;
    
    __weak __typeof(self)weakSelf = self;
    [QBRequest logInWithUserLogin:login
                         password:password
                     successBlock:^(QBResponse * _Nonnull response, QBUUser * _Nonnull user) {
        
        __typeof(weakSelf)strongSelf = weakSelf;
        
        [user setPassword:password];
        [Profile synchronizeUser:user];
        
        if ([user.fullName isEqualToString: displayName] == NO) {
            [strongSelf updateDisplayName:displayName login:login];
        } else {
            // connect to chat when login action is complete
            [strongSelf connectToChat:user];
        }
    } errorBlock:^(QBResponse * _Nonnull response) {
        __typeof(weakSelf)strongSelf = weakSelf;
        
        [strongSelf handleError:response.error.error];
        if (response.status == QBResponseStatusCodeUnAuthorized) {
            [Profile clear];
            [strongSelf defaultConfiguration];
        }
    }];
}

- (void)updateDisplayName:(NSString *)displayName login:(NSString *)login {
    QBUpdateUserParameters *updateUserParameter = [[QBUpdateUserParameters alloc] init];
    updateUserParameter.fullName = displayName;
    __weak __typeof(self)weakSelf = self;
    [QBRequest updateCurrentUser:updateUserParameter
                    successBlock:^(QBResponse * _Nonnull response, QBUUser * _Nonnull user) {
        __typeof(weakSelf)strongSelf = weakSelf;
        strongSelf.loginInfoLabel.text = FULL_NAME_DID_CHANGE;
        [Profile updateUser:user];
        // connect to chat when login action and update user action is complete
        [strongSelf connectToChat:user];
    } errorBlock:^(QBResponse * _Nonnull response) {
        __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf handleError:response.error.error];
    }];
}

- (void)connectToChat:(QBUUser *)user {
    self.loginInfoLabel.text = @"Login into chat ...";
    __weak __typeof(self)weakSelf = self;
    
    [QBChat.instance connectWithUserID:user.ID
                              password:DEFAULT_PASSWORD
                            completion:^(NSError * _Nullable error) {
        
        __typeof(weakSelf)strongSelf = weakSelf;
        
        if (error && error.code != -1000) {
            [strongSelf handleError:error];
        } else {
            //did Login action
            [strongSelf showUsersScreen];
        }
    }];
}

- (void)beginConnect {
    [self setEditing:NO];
    [self setupInputEnabled:NO];
    self.loginButton.isLoading = YES;
}

#pragma mark - Handle errors
- (void)handleError:(NSError *)error {
    NSString *infoText = error.localizedDescription;
    if (error.code == NSURLErrorNotConnectedToInternet) {
        infoText = CHECK_INTERNET;
    } else if (error.code == QBResponseStatusCodeUnAuthorized) {
        [Profile clear];
        [self defaultConfiguration];
    }
    [self setupInputEnabled:YES];
    self.loginButton.isLoading = NO;
    self.loginInfoLabel.text = infoText;
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

