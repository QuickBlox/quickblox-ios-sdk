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
#import <UserNotifications/UserNotifications.h>

NSString *const QB_DEFAULT_PASSWORD = @"quickblox";
NSString *const SHOW_DIALOGS = @"ShowDialogsViewController";
NSString *const FULL_NAME_DID_CHANGE = @"Full Name Did Change";

@interface AuthorizationViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *loginInfo;
@property (weak, nonatomic) IBOutlet UILabel *userNameDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *loginDescritptionLabel;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *loginTextField;
@property (weak, nonatomic) IBOutlet LoadingButton *loginButton;
@property (assign, nonatomic) BOOL needReconnect;

@end

@implementation AuthorizationViewController
#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.estimatedRowHeight = 80;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.tableView.delaysContentTouches = NO;
    
    self.navigationItem.title = NSLocalizedString(@"Enter to chat", nil);
    
    //add Info Screen
    [self showInfoButton];
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

#pragma mark - Setup
- (void)defaultConfiguration {
    [self.loginButton hideLoading];
    [self.loginButton setTitle:NSLocalizedString(@"Login", nil)
                      forState:UIControlStateNormal];
    
    self.loginButton.enabled = NO;
    self.userNameTextField.text = @"";
    self.loginTextField.text = @"";
    
    [self setupInputEnabled:YES];
    
    // Reachability
    void (^updateLoginInfo)(QBNetworkStatus status) = ^(QBNetworkStatus status) {
        
        NSString *loginInfo = (status == QBNetworkStatusNotReachable) ?
        NSLocalizedString(@"Please check your Internet connection", nil):
        NSLocalizedString(@"Please enter your login and username.", nil);
        [self updateLoginInfoText:loginInfo];
    };
    
    Reachability.instance.networkStatusBlock = ^(QBNetworkStatus status) {
        updateLoginInfo(status);
    };
    
    updateLoginInfo(Reachability.instance.networkStatus);
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
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self validateTextField:textField];
}

- (IBAction)editingChanged:(UITextField *)sender {
    [self validateTextField:sender];
    self.loginButton.enabled = [self isValidUserName:self.userNameTextField.text] && [self isValidLogin:self.loginTextField.text];
}

- (void)validateTextField:(UITextField *)textField {
    if (textField == self.userNameTextField && [self isValidUserName:self.userNameTextField.text] == NO) {
        
        self.loginDescritptionLabel.text = @"";
        self.userNameDescriptionLabel.text =
        NSLocalizedString(@"Field should contain alphanumeric characters only in a range 3 to 20. The first character must be a letter.", nil);
    } else if (textField == self.loginTextField && [self isValidLogin:self.loginTextField.text] == NO) {
        
        self.userNameDescriptionLabel.text = @"";
        self.loginDescritptionLabel.text =
        NSLocalizedString(@"Field should contain alphanumeric characters only in a range 8 to 15, without space. The first character must be a letter.", nil);
    } else {
        self.userNameDescriptionLabel.text = @"";
        self.loginDescritptionLabel.text = self.userNameDescriptionLabel.text;
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
    
    [self updateLoginInfoText:@"Signg up ..."];
    
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
    
    [self updateLoginInfoText:@"Login with current user ..."];
    
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
    
    [self updateLoginInfoText:@"Login into chat ..."];
    
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
                                    [self registerForRemoteNotifications];
                                    [strongSelf performSegueWithIdentifier:SHOW_DIALOGS sender:nil];
                                }
                            }];
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

- (void)registerForRemoteNotifications {
    // Enable push notifications
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound |
                                             UNAuthorizationOptionAlert |
                                             UNAuthorizationOptionBadge)
                          completionHandler:^(BOOL granted, NSError * _Nullable error) {
                              if (error) {
                                  Log(@"%@ registerForRemoteNotifications error: %@",NSStringFromClass([AuthorizationViewController class]),
                                      error.localizedDescription);
                                  return;
                              }
                              [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings *settings) {
                                  if (settings.authorizationStatus != UNAuthorizationStatusAuthorized) {
                                      return;
                                  }
                                  
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      [[UIApplication sharedApplication] registerForRemoteNotifications];
                                  });
                              }];
                          }];
}

#pragma mark - Handle errors
- (void)handleError:(NSError *)error {
    NSString *infoText = error.localizedDescription;
    if (error.code == NSURLErrorNotConnectedToInternet) {
        infoText = NSLocalizedString(@"Please check your Internet connection", nil);
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
    NSCharacterSet *characterSet = [NSCharacterSet whitespaceCharacterSet];
    NSString *userName = [fullName stringByTrimmingCharactersInSet:characterSet];
    NSString *userNameRegex = @"^[^_][\\w\\u00C0-\\u1FFF\\u2C00-\\uD7FF\\s]{2,19}$";
    NSPredicate *userNamePredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", userNameRegex];
    BOOL userNameIsValid = [userNamePredicate evaluateWithObject:userName];
    
    return userNameIsValid;
}

- (BOOL)isValidLogin:(NSString *)login {
    NSCharacterSet *characterSet = [NSCharacterSet whitespaceCharacterSet];
    NSString *tag = [login stringByTrimmingCharactersInSet:characterSet];
    NSString *tagRegex = @"^[a-zA-Z][a-zA-Z0-9]{7,14}$";
    NSPredicate *tagPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", tagRegex];
    BOOL tagIsValid = [tagPredicate evaluateWithObject:tag];
    
    return tagIsValid;
}

@end
