//
//  AuthorizationViewController.m
//  samplechat
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
#import "Reachability.h"
#import "Log.h"
#import "UITextField+Chat.h"
#import "UIColor+Chat.h"
#import "NSString+Chat.h"
#import "AppDelegate.h"
#import "RootParentVC.h"

NSString *const QB_DEFAULT_PASSWORD = @"quickblox";
NSString *const SHOW_DIALOGS = @"ShowDialogsViewController";
NSString *const FULL_NAME_DID_CHANGE = @"Display Name Did Change";
NSString *const LOGIN_HINT = @"Use your email or alphanumeric characters in a range from 3 to 50. First character must be a letter.";
NSString *const USERNAME_HINT = @"Use alphanumeric characters and spaces in a range from 3 to 20. Cannot contain more than one space in a row.";
NSString *const CHECK_INTERNET = @"Please check your Internet connection";
NSString *const ENTER_LOGIN_USERNAME = @"Enter your login and display name";
NSString *const ENTER_CHAT = @"Enter to conference";
NSString *const LOGIN = @"Login";
NSString *const SIGNG = @"Signg up ...";
NSString *const LOGIN_USER = @"Login with current user ...";
NSString *const LOGIN_CHAT = @"Login into conference ...";

@interface AuthorizationViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *loginInfo;
@property (weak, nonatomic) IBOutlet UILabel *userNameDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *loginDescritptionLabel;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *loginTextField;
@property (weak, nonatomic) IBOutlet LoadingButton *loginButton;
@property (assign, nonatomic) BOOL needReconnect;
@property (strong, nonatomic) NSString *inputedLogin;
@property (strong, nonatomic) NSString *inputedUsername;
@end

@implementation AuthorizationViewController
#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.inputedLogin = @"";
    self.inputedUsername = @"";
    
    self.tableView.estimatedRowHeight = 86;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.tableView.delaysContentTouches = NO;
    
    self.navigationItem.title = NSLocalizedString(ENTER_CHAT, nil);
    
    //add Info Screen
    [self showInfoButton];
    [self setupViews];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self defaultConfiguration];
    //Update interface and start login if user exist
    Profile *profile = [[Profile alloc] init];
    if (profile.isFull) {
        self.userNameTextField.text = [profile fullName];
        self.loginTextField.text = [profile login];
        [self loginWithFullName:profile.fullName login:profile.login password:profile.password];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
      name:UIKeyboardWillHideNotification
    object:nil];
}

#pragma mark - Setup
- (void)setupViews {
    [self.loginTextField setPadding:12.0f isLeft:YES];
    [self.loginTextField addShadowToTextFieldWithColor:[UIColor colorWithHexString:@"#DFEBFF"] cornerRadius:4.0f];

    [self.userNameTextField setPadding:12.0f isLeft:YES];
    [self.userNameTextField addShadowToTextFieldWithColor:[UIColor colorWithHexString:@"#DFEBFF"] cornerRadius:4.0f];
}

- (void)defaultConfiguration {
    [self.loginButton hideLoading];
    [self.loginButton setTitle:NSLocalizedString(LOGIN, nil)
                      forState:UIControlStateNormal];
    
    self.loginButton.enabled = NO;
    self.userNameTextField.text = self.inputedUsername;
    self.loginTextField.text = self.inputedLogin;
    self.loginButton.enabled = ([self isValidLogin:self.loginTextField.text] && [self isValidUserName:self.userNameTextField.text]);
    self.loginDescritptionLabel.text = @"";
    self.userNameDescriptionLabel.text = @"";
    
    [self setupInputEnabled:YES];
    
    // Reachability
    void (^updateLoginInfo)(QBNetworkStatus status) = ^(QBNetworkStatus status) {
        
        NSString *loginInfo = (status == QBNetworkStatusNotReachable) ?
        NSLocalizedString(CHECK_INTERNET, nil):
        NSLocalizedString(ENTER_LOGIN_USERNAME, nil);
        [self updateLoginInfoText:loginInfo];
    };
    
    Reachability.instance.networkStatusBlock = ^(QBNetworkStatus status) {
        updateLoginInfo(status);
    };
    
    updateLoginInfo(Reachability.instance.networkStatus);
}

#pragma mark - KeyboardWillHideNotification
- (void)keyboardWillHide:(NSNotification *)notification  {
    if (self.userNameTextField.text.length == 0) {
        self.userNameDescriptionLabel.text = @"";
    }
    if (self.loginTextField.text.length == 0) {
        self.loginDescritptionLabel.text = @"";
    }
    [self.tableView reloadData];
}

#pragma mark - Disable / Enable inputs
- (void)setupInputEnabled:(BOOL)enabled {
    self.loginTextField.enabled = enabled;
    self.userNameTextField.enabled = enabled;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

#pragma mark - UIControl Actions
- (IBAction)didPressLoginButton:(LoadingButton *)sender {
    NSString *fullName = self.userNameTextField.text;
    NSString *login = self.loginTextField.text;
    
    if (sender.isAnimating == NO) {
        [self signUpWithFullName:fullName login:login];
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.isFirstResponder) {
        [textField resignFirstResponder];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self validateTextField:textField];
}

- (IBAction)editingDidEnd:(UITextField *)sender {
    [sender addShadowToTextFieldWithColor:[UIColor colorWithHexString:@"#DFEBFF"] cornerRadius:4.0f];
}

- (IBAction)editingDidBegin:(UITextField *)sender {
    [sender addShadowToTextFieldWithColor:[UIColor colorWithHexString:@"#ACBFE2"] cornerRadius:4.0f];
}

- (IBAction)editingChanged:(UITextField *)sender {
    if (self.userNameTextField.isFirstResponder) {
        if (self.userNameTextField.text.length > 1 && [self.userNameTextField.text endsInWhitespaceCharacter]) {
            if ([self.userNameTextField.text hasSuffix:@"  "]) {
                self.userNameTextField.text = self.inputedUsername;
            }
        }
    }
    [self validateTextField:sender];
    self.loginButton.enabled = [self isValidUserName:self.userNameTextField.text] && [self isValidLogin:self.loginTextField.text];
    if (self.userNameTextField.text.length) {
        self.inputedUsername = self.userNameTextField.text;
    }
    if (self.loginTextField.text.length) {
        self.inputedLogin = self.loginTextField.text;
    }
}

- (void)validateTextField:(UITextField *)textField {
    if (textField == self.loginTextField) {
        if ([self isValidChangedLogin:self.loginTextField.text] == NO) {
            self.loginDescritptionLabel.text = NSLocalizedString(LOGIN_HINT, nil);
        } else {
            self.loginDescritptionLabel.text = @"";
        }
        
        if (self.userNameTextField.text.length == 0) {
            self.userNameDescriptionLabel.text = @"";
        } else if ([self isValidChangedUserName:self.userNameTextField.text] == NO) {
            self.userNameDescriptionLabel.text = NSLocalizedString(USERNAME_HINT, nil);
        } else {
            self.userNameDescriptionLabel.text = @"";
        }
    }
    if (textField == self.userNameTextField) {
        if ([self isValidChangedUserName:self.userNameTextField.text] == NO) {
            self.userNameDescriptionLabel.text = NSLocalizedString(USERNAME_HINT, nil);
        } else {
            self.userNameDescriptionLabel.text = @"";
        }
        
        if (self.loginTextField.text.length == 0) {
            self.loginDescritptionLabel.text = @"";
        } else if ([self isValidChangedLogin:self.loginTextField.text] == NO) {
            self.loginDescritptionLabel.text = NSLocalizedString(LOGIN_HINT, nil);
        } else {
            self.loginDescritptionLabel.text = @"";
        }
    }
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
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
    
    [self updateLoginInfoText:SIGNG];
    
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
    
    [self updateLoginInfoText:LOGIN_USER];
    
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
                             [strongSelf connectToChat:user];
                         }
                         
                     } errorBlock:^(QBResponse * _Nonnull response) {
                         __typeof(weakSelf)strongSelf = weakSelf;
                         
                         [strongSelf handleError:response.error.error];
                         if (response.status == QBResponseStatusCodeUnAuthorized) {
                             // Clean profile
                             [Profile clearProfile];
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
                        [strongSelf updateLoginInfoText: FULL_NAME_DID_CHANGE];
                        [Profile updateUser:user];
                        [strongSelf connectToChat:user];
                        
                    } errorBlock:^(QBResponse * _Nonnull response) {
                        __typeof(weakSelf)strongSelf = weakSelf;
                        [strongSelf handleError:response.error.error];
                    }];
}

/**
 *  connectToChat
 */
- (void)connectToChat:(QBUUser *)user {
    
    [self updateLoginInfoText:LOGIN_CHAT];
    
    __weak __typeof(self)weakSelf = self;
    
    [QBChat.instance connectWithUserID:user.ID
                              password:QB_DEFAULT_PASSWORD
                            completion:^(NSError * _Nullable error) {
                                
                                __typeof(weakSelf)strongSelf = weakSelf;
                                
                                if (error) {
                                    if (error.code == QBResponseStatusCodeUnAuthorized) {
                                        // Clean profile
                                        [Profile clearProfile];
                                        [strongSelf defaultConfiguration];
                                    } else {
                                        [strongSelf handleError:error];
                                    }
                                } else {
                                    //did Login action
//                                    [self registerForRemoteNotifications];
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [(RootParentVC *)[strongSelf shared].window.rootViewController switchToDialogsScreen];
                                    });
                                    self.inputedUsername = @"";
                                    self.inputedLogin = @"";
                                }
                            }];
}

- (AppDelegate*)shared {
    return (AppDelegate*) [[UIApplication sharedApplication] delegate];
}

- (void)beginConnect {
    [self setEditing:NO];
    [self setupInputEnabled:NO];
    [self.loginButton showLoading];
}

- (void)updateLoginInfoText:(NSString *)text {
    if ([text isEqualToString:self.loginInfo.text] == NO) {
        self.loginInfo.text = text;
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    }
}

//- (void)registerForRemoteNotifications {
//    // Enable push notifications
//    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
//
//    [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound |
//                                             UNAuthorizationOptionAlert |
//                                             UNAuthorizationOptionBadge)
//                          completionHandler:^(BOOL granted, NSError * _Nullable error) {
//                              if (error) {
//                                  Log(@"%@ registerForRemoteNotifications error: %@",NSStringFromClass([AuthorizationViewController class]),
//                                      error.localizedDescription);
//                                  return;
//                              }
//                              [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings *settings) {
//                                  if (settings.authorizationStatus != UNAuthorizationStatusAuthorized) {
//                                      return;
//                                  }
//
//                                  dispatch_async(dispatch_get_main_queue(), ^{
//                                      [[UIApplication sharedApplication] registerForRemoteNotifications];
//                                  });
//                              }];
//                          }];
//}

#pragma mark - Handle errors
- (void)handleError:(NSError *)error {
    NSString *infoText = error.localizedDescription;
    if (error.code == NSURLErrorNotConnectedToInternet) {
        infoText = NSLocalizedString(CHECK_INTERNET, nil);
    }
    [self setupInputEnabled:YES];
    [self.loginButton hideLoading];
    [self validateTextField:self.userNameTextField];
    [self validateTextField:self.loginTextField];
    BOOL isEnabled = [self isValidUserName:self.userNameTextField.text] && [self isValidLogin:self.loginTextField.text];
    [self.loginButton setEnabled: isEnabled];
    [self updateLoginInfoText: infoText];
}


#pragma mark - Validation helpers
- (BOOL)isValidUserName:(NSString *)fullName {
    NSString *userNameRegex = @"^[a-zA-Z][a-zA-Z 0-9]{2,19}$";
    NSPredicate *userNamePredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", userNameRegex];
    BOOL userNameIsValid = [userNamePredicate evaluateWithObject:fullName];
    
    return userNameIsValid;
}

- (BOOL)isValidChangedUserName:(NSString *)fullName {
//    NSString *userNameRegex = @"^[a-zA-Z]+([_ -]?[a-zA-Z 0-9]){2,19}$";
    NSString *userNameRegex = @"^[a-zA-Z][a-zA-Z 0-9]{2,19}$";
    NSPredicate *userNamePredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", userNameRegex];
    BOOL userNameIsValid = [userNamePredicate evaluateWithObject:fullName];
    
    return userNameIsValid;
}

- (BOOL)isValidLogin:(NSString *)login {
    NSString *tagRegex = @"^[a-zA-Z][a-zA-Z0-9]{2,49}$";
    NSString *tagRegexEmail = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,49}$";
    NSPredicate *tagPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", tagRegex];
    NSPredicate *tagPredicateEmail = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", tagRegexEmail];
    BOOL tagIsValid = [tagPredicate evaluateWithObject:login];
    BOOL tagIsValidEmail = [tagPredicateEmail evaluateWithObject:login];
    if (tagIsValid || tagIsValidEmail) {
        return YES;
    }
    return NO;
}

- (BOOL)isValidChangedLogin:(NSString *)login {
    NSString *tagRegex = @"^[a-zA-Z][a-zA-Z0-9]{2,49}$";
    NSString *tagRegexEmail = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,49}$";
    NSPredicate *tagPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", tagRegex];
    NSPredicate *tagPredicateEmail = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", tagRegexEmail];
    BOOL tagIsValid = [tagPredicate evaluateWithObject:login];
    BOOL tagIsValidEmail = [tagPredicateEmail evaluateWithObject:login];
    if (tagIsValid || tagIsValidEmail) {
        return YES;
    }
    return NO;
}

@end
