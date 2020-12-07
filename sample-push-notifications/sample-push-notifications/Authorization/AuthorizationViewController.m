//
//  AuthorizationViewController.m
//  sample-push-notifications
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "AuthorizationViewController.h"
#import <Quickblox/Quickblox.h>
#import "LoadingButton.h"
#import "SVProgressHUD.h"
#import "UIViewController+InfoScreen.h"
#import "Profile.h"
#import "UITextField+Chat.h"
#import "UIColor+Chat.h"
#import "NSString+Chat.h"
#import "AppDelegate.h"
#import "RootParentVC.h"
#import "InputContainer.h"

NSString *const QB_DEFAULT_PASSWORD = @"quickblox";
NSString *const FULL_NAME_DID_CHANGE = @"Full Name Did Change";
NSString *const LOGIN_HINT = @"Use your email or alphanumeric characters in a range from 3 to 50. First character must be a letter.";
NSString *const USERNAME_HINT = @"Use alphanumeric characters and spaces in a range from 3 to 20. Cannot contain more than one space in a row.";
NSString *const CHECK_INTERNET = @"Please check your Internet connection";
NSString *const ENTER_LOGIN_USERNAME = @"Enter your login and display name";
NSString *const ENTER_PUSHES = @"Enter to Pushes";
NSString *const LOGIN = @"Login";
NSString *const DISPLAY_NAME = @"Display name";
NSString *const SIGNG = @"Signg up ...";
NSString *const LOGIN_USER = @"Login with current user ...";
NSString *const USERNAME_REGEX = @"^(?=.{3,20}$)(?!.*([\\s])\\1{2})[\\w\\s]+$";
NSString *const LOGIN_REGEX = @"^[a-zA-Z][a-zA-Z0-9]{2,49}$";
NSString *const EMAIL_REGEX = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,49}$";

@interface AuthorizationViewController () <InputContainerDelegate>

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *loginInfoLabel;
@property (weak, nonatomic) IBOutlet LoadingButton *loginButton;
@property (strong, nonatomic) InputContainer *loginInputContainer;
@property (strong, nonatomic) InputContainer *usernameInputContainer;
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
    
    self.usernameInputContainer = [[NSBundle mainBundle] loadNibNamed:@"InputContainer" owner:nil options:nil].firstObject;
    [self.usernameInputContainer setupWithTitle:DISPLAY_NAME hint:USERNAME_HINT regexes:@[USERNAME_REGEX]];
    [self.containerView addSubview:self.usernameInputContainer];
    self.usernameInputContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [self.usernameInputContainer.leftAnchor constraintEqualToAnchor:self.containerView.leftAnchor].active = YES;
    [self.usernameInputContainer.rightAnchor constraintEqualToAnchor:self.containerView.rightAnchor].active = YES;
    [self.usernameInputContainer.topAnchor constraintEqualToAnchor:self.loginInputContainer.bottomAnchor].active = YES;
    self.usernameInputContainer.delegate = self;
    
    self.inputContainers = @[self.loginInputContainer, self.usernameInputContainer];
    
    self.loginButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.loginButton.centerXAnchor constraintEqualToAnchor:self.containerView.centerXAnchor].active = YES;
    [self.loginButton.topAnchor constraintEqualToAnchor:self.usernameInputContainer.bottomAnchor constant:20.0f].active = YES;
    [self.loginButton.widthAnchor constraintEqualToConstant:215.0f].active = YES;
    [self.loginButton.heightAnchor constraintEqualToConstant:44.0f].active = YES;

    self.navigationItem.title = ENTER_PUSHES;
    
    [self addInfoButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self defaultConfiguration];
}

#pragma mark - Setup
- (void)defaultConfiguration {
    [self.loginButton hideLoading];
    [self.loginButton setTitle:LOGIN
                      forState:UIControlStateNormal];
    self.loginButton.enabled = NO;
    [self setupInputEnabled:YES];
}

#pragma mark - Disable / Enable inputs
- (void)setupInputEnabled:(BOOL)enabled {
    for (InputContainer *container in self.inputContainers) {
        [container setInputEnabled:enabled];
    }
}

#pragma mark - UIControl Actions
- (IBAction)didPressLoginButton:(LoadingButton *)sender {
    NSString *fullName = self.usernameInputContainer.text;
    NSString *login = self.loginInputContainer.text;
    if (sender.isAnimating == NO) {
        [self signUpWithFullName:fullName login:login];
    }
}

#pragma mark - Internal Methods
/**
 *  Signup and login
 */
- (void)signUpWithFullName:(NSString *)fullName login:(NSString *)login {
    [self beginConnect];
    QBUUser *newUser = [[QBUUser alloc] init];
    newUser.login = login;
    newUser.fullName = fullName;
    newUser.password = QB_DEFAULT_PASSWORD;
    
    self.loginInfoLabel.text = SIGNG;
    
    __weak __typeof(self)weakSelf = self;
    [QBRequest signUp:newUser successBlock:^(QBResponse * _Nonnull response, QBUUser * _Nonnull user) {
        __typeof(weakSelf)strongSelf = weakSelf;
        
        [strongSelf loginWithFullName:fullName login:login password:QB_DEFAULT_PASSWORD];
        
    } errorBlock:^(QBResponse * _Nonnull response) {
        __typeof(weakSelf)strongSelf = weakSelf;
        if (response.status == QBResponseStatusCodeValidationFailed) {
            // The user with existent login was created earlier
            [strongSelf loginWithFullName:fullName login:login password:QB_DEFAULT_PASSWORD];
            return;
        }
        [strongSelf handleError:response.error.error];
    }];
}

/**
 *  login
 */
- (void)loginWithFullName:(NSString *)fullName login:(NSString *)login password:(NSString *)password {
    [self beginConnect];
    
    self.loginInfoLabel.text = LOGIN_USER;
    
    __weak __typeof(self)weakSelf = self;
    [QBRequest logInWithUserLogin:login
                         password:password
                     successBlock:^(QBResponse * _Nonnull response, QBUUser * _Nonnull user) {
        
        __typeof(weakSelf)strongSelf = weakSelf;
        
        [user setPassword:password];
        [Profile synchronizeUser:user];
        
        if ([user.fullName isEqualToString: fullName] == NO) {
            [strongSelf updateFullName:fullName login:login];
        } else {
            //did Login action
            [strongSelf.rootParentVC showPushesScreen];
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

/**
 *  Update User Full Name
 */
- (void)updateFullName:(NSString *)fullName login:(NSString *)login {
    QBUpdateUserParameters *updateUserParameter = [[QBUpdateUserParameters alloc] init];
    updateUserParameter.fullName = fullName;
    
    __weak __typeof(self)weakSelf = self;
    [QBRequest updateCurrentUser:updateUserParameter
                    successBlock:^(QBResponse * _Nonnull response, QBUUser * _Nonnull user) {
        __typeof(weakSelf)strongSelf = weakSelf;
        self.loginInfoLabel.text = FULL_NAME_DID_CHANGE;
        [Profile updateUser:user];
        //did Login action
        [strongSelf.rootParentVC showPushesScreen];
        
    } errorBlock:^(QBResponse * _Nonnull response) {
        __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf handleError:response.error.error];
    }];
}

- (void)beginConnect {
    [self setEditing:NO];
    [self setupInputEnabled:NO];
    [self.loginButton showLoading];
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
    [self.loginButton hideLoading];
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

#pragma mark - RootParentVC
- (RootParentVC*)rootParentVC {
    return (RootParentVC *)[[UIApplication sharedApplication] delegate].window.rootViewController;
}

@end
