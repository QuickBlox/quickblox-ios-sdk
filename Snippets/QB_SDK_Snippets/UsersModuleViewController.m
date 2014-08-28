//
//  SecondViewController.m
//  QB_SDK_Samples
//
//  Created by Igor Khomenko on 6/5/12.
//  Copyright (c) 2012 Injoit. All rights reserved.
//

#import "UsersModuleViewController.h"
#import "UsersDataSource.h"

@interface UsersModuleViewController ()
@property (nonatomic) UsersDataSource *dataSource;
@end

@implementation UsersModuleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Users", @"Users");
        self.tabBarItem.image = [UIImage imageNamed:@"circle"];
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.dataSource = [[UsersDataSource alloc] init];
    tableView.dataSource = self.dataSource;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    switch (indexPath.section) {
        // Sign In, Sign Out, Sign Up
        case 0:
            switch (indexPath.row) {
                // User Login with login
                case 0:{
                    if (useNewAPI) {
                       [QBRequest logInWithUserLogin:UserLogin1 password:UserPassword1 successBlock:^(QBResponse *response, QBUUser *user) {
                           NSLog(@"Successfull response!");
                       } errorBlock:^(QBResponse *response) {
                           NSLog(@"Response error: %@", response.error);
                       }];
                    } else {
                        if(withQBContext){
                            [QBUsers logInWithUserLogin:UserLogin1 password:UserPassword1 delegate:self context:testContext];
                        }else{
                            [QBUsers logInWithUserLogin:UserLogin1 password:UserPassword1  delegate:self];
                        }
                    }
                }
                    break;
                    
                // User Login with email
                case 1:{
                    if (useNewAPI) {
                        [QBRequest logInWithUserEmail:UserEmail1 password:UserPassword1 successBlock:^(QBResponse *response, QBUUser *user) {
                             NSLog(@"Successfull response!");
                        } errorBlock:^(QBResponse *response) {
                            NSLog(@"Response error: %@", response.error);
                        }];
                    } else {
                        if(withQBContext){;
                            [QBUsers logInWithUserEmail:UserEmail1 password:UserPassword1 delegate:self context:testContext];
                        }else{
                            [QBUsers logInWithUserEmail:UserEmail1 password:UserPassword1 delegate:self];
                        }
                    }
                }
                    break;
                
                // User Login with social provider
                case 2:{
                    if (useNewAPI) {
                        [QBRequest logInWithSocialProvider:@"facebook" scope:nil successBlock:^(QBResponse *response, QBUUser *user) {
                             NSLog(@"Successfull response!");
                        } errorBlock:^(QBResponse *response) {
                            NSLog(@"Response error: %@", response.error);
                        }];
                    } else {
                        if(withQBContext){;
                            [QBUsers logInWithSocialProvider:@"facebook" scope:nil delegate:self context:testContext];
                        }else{
                            [QBUsers logInWithSocialProvider:@"facebook" scope:nil  delegate:self];
                        }
                    }
                }
                    break;
                    
                // User Login with social access token
                case 3:{
                    if (useNewAPI) {
                        [QBRequest logInWithSocialProvider:@"facebook" accessToken:@"CAAEra8jNdnkBABAnhaesXZCceUvsKFywMg91gJueUdkproXpAp10ckxLZACTYblnxO7RmMroIV62VhmjdgHpcQFP2v8EKwOs7ZBWche562PlniDdEyeVFK0oIdkDWGRknbfvxo5NySLkK8tnVTVMAPqkNA8vpluIJtO1fYC2PJKiKZAgfhUMpGgD8J2y8UvP9YoSIKUmG5GY9ZCGBCPY4" accessTokenSecret:nil successBlock:^(QBResponse *response, QBUUser *user) {
                             NSLog(@"Successfull response!");
                        } errorBlock:^(QBResponse *response) {
                            NSLog(@"Response error: %@", response.error);
                        }];
                    } else {
                        if(withQBContext){;
                            [QBUsers logInWithSocialProvider:@"facebook" accessToken:@"CAAEra8jNdnkBABAnhaesXZCceUvsKFywMg91gJueUdkproXpAp10ckxLZACTYblnxO7RmMroIV62VhmjdgHpcQFP2v8EKwOs7ZBWche562PlniDdEyeVFK0oIdkDWGRknbfvxo5NySLkK8tnVTVMAPqkNA8vpluIJtO1fYC2PJKiKZAgfhUMpGgD8J2y8UvP9YoSIKUmG5GY9ZCGBCPY4" accessTokenSecret:nil delegate:self context:testContext];
                        }else{
                             [QBUsers logInWithSocialProvider:@"facebook" accessToken:@"AAAGmLYiu1lcBADxROiXg4okE80FQO1dJHglsbNT3amxmABnmBmhN6ACbgDqNC3H4Y9GmZAdoSfPUkI9O7ZBJvKQCewNZAp3SoxKCNIMwQZDZD" accessTokenSecret:nil delegate:self];
                        }
                    }
                }
                    break;
                    
                // User Logout
                case 4:{
                    if (useNewAPI) {
                        [QBRequest logOutWithSuccessBlock:^(QBResponse *response) {
                             NSLog(@"Successfull response!");
                        } errorBlock:^(QBResponse *response) {
                            NSLog(@"Response error: %@", response.error);
                        }];
                    } else {
                        if(withQBContext){
                            [QBUsers logOutWithDelegate:self context:testContext];
                        }else{
                            [QBUsers logOutWithDelegate:self];
                        }
                    }
                }
                    break;
                    
                // User Sign Up
                case 5:{
                    QBUUser *user = [QBUUser user];
                    user.email = @"ig223or@quickblox.com";
                    user.login = @"qwer3werwerwe22r";
                    user.password = @"qbuserr3453"; // 250813
                    user.customData = @"my data";
                    user.externalUserID = 63242344;
                    user.facebookID = @"12343443453463463";
                    user.twitterID = @"1422345345256";
                    user.fullName = @"22Javck Bold";
//                    user.email = @"Javck@mail.com";
                    user.phone = @"+0947773823";
//                    user.tags = [NSArray arrayWithObjects:@"man", @"travel", nil];
//                    user.website = @"www.mysite.com";

                    if (useNewAPI) {
                        [QBRequest signUp:user successBlock:^(QBResponse *response, QBUUser *user) {
                             NSLog(@"Successfull response!");
                        } errorBlock:^(QBResponse *response) {
                            NSLog(@"Response error: %@", response.error);
                        }];
                    } else {
                        if(withQBContext){
                            [QBUsers signUp:user delegate:self context:testContext];
                        }else{
                            [QBUsers signUp:user delegate:self];
                        }
                    }
                }
                    break;
                default:
                    break;
            }
            break;
            
        // Get
        case 1:
            switch (indexPath.row) {
                // Get all users
                case 0:{
                    if (useNewAPI) {
                        QBGeneralResponsePage *page = [QBGeneralResponsePage responsePageWithCurrentPage:1 perPage:10];
                        [QBRequest usersForPage:page successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users) {
                             NSLog(@"Successfull response!");
                        } errorBlock:^(QBResponse *response) {
                            NSLog(@"Response error: %@", response.error);
                        }];
                    } else {
                        if(withAdditionalRequest){
                            PagedRequest *pagedRequest = [PagedRequest request];
                            pagedRequest.perPage = 3;
                            pagedRequest.page = 2;
                            
                            if(withQBContext){
                                [QBUsers usersWithPagedRequest:pagedRequest delegate:self context:testContext];
                            }else{
                                [QBUsers usersWithPagedRequest:pagedRequest delegate:self];
                            }
                            
                        }else{
                            if(withQBContext){
                                [QBUsers usersWithDelegate:self context:testContext];
                            }else{
                                [QBUsers usersWithDelegate:self];
                            }
                        }
                    }
                }
                    break;
                    
                // Get users with extended requests
                case 1:{
                    if (useNewAPI) {
                        [QBRequest usersWithExtendedRequest:@{@"order" : @"desc date last_request_at"} page:[QBGeneralResponsePage responsePageWithCurrentPage:1 perPage:10] successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users) {
                            NSLog(@"Successfull response!");
                        } errorBlock:^(QBResponse *response) {
                            NSLog(@"Response error: %@", response.error);
                        }];
                    } else {
                        NSMutableDictionary *filters = [NSMutableDictionary dictionary];
                        filters[@"order"] = @"desc date last_request_at";
                        filters[@"page"] = @"2";
                        if(withQBContext){
                            [QBUsers usersWithExtendedRequest:filters delegate:self context:testContext];
                        }else{
                            [QBUsers usersWithExtendedRequest:filters delegate:self];
                        }
                    }
                }
                    break;
                    
                    
                // Get user with ID
                case 2:{
                    if (useNewAPI) {
                        [QBRequest userWithID:UserID1 successBlock:^(QBResponse *response, QBUUser *user) {
                            NSLog(@"Successfull response!");
                        } errorBlock:^(QBResponse *response) {
                            NSLog(@"Response error: %@", response.error);
                        }];
                    } else {
                        if(withQBContext){
                            [QBUsers userWithID:UserID1 delegate:self context:testContext];
                        }else{
                            [QBUsers userWithID:UserID1 delegate:self];
                        }
                    }
                }
                    break;
                    
                // Get users with ids
                case 3:{
                    if (useNewAPI) {
                        QBGeneralResponsePage* page = [QBGeneralResponsePage responsePageWithCurrentPage:1 perPage:10];
                        [QBRequest usersWithIDs:@[@(300),@(298)] page:page successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users) {
                             NSLog(@"Successfull response!");
                        } errorBlock:^(QBResponse *response) {
                            NSLog(@"Response error: %@", response.error);
                        }];
                    } else {
                        if(withAdditionalRequest){
                            PagedRequest *pagedRequest = [PagedRequest request];
                            pagedRequest.perPage = 3;
                            pagedRequest.page = 1;
                            
                            if(withQBContext){
                                [QBUsers usersWithIDs:@"300,298" pagedRequest:pagedRequest delegate:self context:testContext];
                            }else{
                                [QBUsers usersWithIDs:@"300,298" pagedRequest:pagedRequest delegate:self];
                            }
                            
                        }else{
                            if(withQBContext){
                                [QBUsers usersWithIDs:@"300,298" delegate:self context:testContext];
                            }else{
                                [QBUsers usersWithIDs:@"300,298" delegate:self];
                            }
                        }
                    }
                }
                    break;
                    
                // Get user by login
                case 4:{
                    if (useNewAPI) {
                        [QBRequest userWithLogin:@"Javck" successBlock:^(QBResponse *response, QBUUser *user) {
                             NSLog(@"Successfull response!");
                        } errorBlock:^(QBResponse *response) {
                            NSLog(@"Response error: %@", response.error);
                        }];
                    } else {
                        if(withQBContext){
                            [QBUsers userWithLogin:@"Javck" delegate:self context:testContext];
                        }else{
                            [QBUsers userWithLogin:@"Javck" delegate:self];
                        }
                    }

                }
                    break;
                    
                // Get users by logins
                case 5:{
                    if (useNewAPI) {
                        [QBRequest usersWithLogins:@[@"emma", @"Javck"] successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users) {
                             NSLog(@"Successfull response!");
                        } errorBlock:^(QBResponse *response) {
                            NSLog(@"Response error: %@", response.error);
                        }];
                    } else {
                        if(withAdditionalRequest){
                            PagedRequest *pagedRequest = [PagedRequest request];
                            pagedRequest.perPage = 3;
                            pagedRequest.page = 1;
                            
                            if(withQBContext){
                                [QBUsers usersWithLogins:@[@"emma", @"Javck"] pagedRequest:pagedRequest delegate:self context:testContext];
                            }else{
                                [QBUsers usersWithLogins:@[@"emma", @"Javck"] pagedRequest:pagedRequest delegate:self];
                            }
                            
                        }else{
                            if(withQBContext){
                                [QBUsers usersWithLogins:@[@"emma", @"Javck"] delegate:self context:testContext];
                            }else{
                                [QBUsers usersWithLogins:@[@"emma", @"Javck"] delegate:self];
                            }
                        }
                    }
                }
                    break;
                    
                // Get users by fullname
                case 6:{
                    if (useNewAPI) {
                        [QBRequest usersWithFullName:@"Javck Bold" successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users) {
                             NSLog(@"Successfull response!");
                        } errorBlock:^(QBResponse *response) {
                            NSLog(@"Response error: %@", response.error);
                        }];
                    } else {
                        if(withAdditionalRequest){
                            PagedRequest *pagedRequest = [PagedRequest request];
                            pagedRequest.perPage = 1;
                            pagedRequest.page = 1;
                            
                            if(withQBContext){
                                [QBUsers usersWithFullName:@"Javck Bold" pagedRequest:pagedRequest delegate:self context:testContext];
                            }else{
                                [QBUsers usersWithFullName:@"Javck Bold" pagedRequest:pagedRequest delegate:self];
                            }
                            
                        }else{
                            if(withQBContext){
                                [QBUsers usersWithFullName:@"Javck Bold" delegate:self context:testContext];
                            }else{
                                [QBUsers usersWithFullName:@"Javck Bold" delegate:self];
                            }
                        }
                    }
                }
                    break;
                    
                // Get user by facebook ID
                case 7:{
                    if (useNewAPI) {
                        [QBRequest userWithFacebookID:@"124343453463463" successBlock:^(QBResponse *response, QBUUser *user) {
                             NSLog(@"Successfull response!");
                        } errorBlock:^(QBResponse *response) {
                            NSLog(@"Response error: %@", response.error);
                        }];
                    } else {
                        if(withQBContext){
                            [QBUsers userWithFacebookID:@"124343453463463" delegate:self context:testContext];
                        }else{
                            [QBUsers userWithFacebookID:@"124343453463463" delegate:self];
                        }
                    }
                }
                    break;
                    
                // Get users by facebook IDs
                case 8:{
                    if (useNewAPI) {
                        QBGeneralResponsePage *page = [QBGeneralResponsePage responsePageWithCurrentPage:1 perPage:10];
                        [QBRequest usersWithFacebookIDs:@[@"424353563564544ffd",@"100000773956777"] page:page successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users) {
                             NSLog(@"Successfull response!");
                        } errorBlock:^(QBResponse *response) {
                            NSLog(@"Response error: %@", response.error);
                        }];
                    } else {
                        if(withAdditionalRequest){
                            PagedRequest *pagedRequest = [PagedRequest request];
                            pagedRequest.perPage = 10;
                            pagedRequest.page = 1;
                            
                            if(withQBContext){
                                [QBUsers usersWithFacebookIDs:@[@"424353563564544ffd",@"100000773956777"] pagedRequest:pagedRequest delegate:self context:testContext];
                            }else{
                                [QBUsers usersWithFacebookIDs:@[@"424353563564544ffd",@"100000773956777"] pagedRequest:pagedRequest delegate:self];
                            }
                            
                        }else{
                            if(withQBContext){
                                [QBUsers usersWithFacebookIDs:@[@"424353563564544ffd",@"100000773956777"] delegate:self context:testContext];
                            }else{
                                [QBUsers usersWithFacebookIDs:@[@"424353563564544ffd",@"100000773956777"] delegate:self];
                            }
                        }
                    }
                }
                    break;
                    
                // Get user by twitter ID
                case 9:{
                    if (useNewAPI) {
                        [QBRequest userWithTwitterID:@"142345256" successBlock:^(QBResponse *response, QBUUser *user) {
                             NSLog(@"Successfull response!");
                        } errorBlock:^(QBResponse *response) {
                            NSLog(@"Response error: %@", response.error);
                        }];
                    } else if(withQBContext){
                        [QBUsers userWithTwitterID:@"142345256" delegate:self context:testContext];
                    } else{
                        [QBUsers userWithTwitterID:@"142345256" delegate:self];
                    } 
                }
                    break;
                    
                // Get users by twitter IDs
                case 10:{
                    if (useNewAPI) {
                        QBGeneralResponsePage *page = [QBGeneralResponsePage responsePageWithCurrentPage:1 perPage:10];
                        [QBRequest usersWithTwitterIDs:@[@"2342355245346",@"789789789789"] page:page successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users) {
                             NSLog(@"Successfull response!");
                        } errorBlock:^(QBResponse *response) {
                            NSLog(@"Response error: %@", response.error);
                        }];
                    } else {
                        if(withAdditionalRequest){
                            PagedRequest *pagedRequest = [PagedRequest request];
                            pagedRequest.perPage = 10;
                            pagedRequest.page = 1;
                            
                            if(withQBContext){
                                [QBUsers usersWithTwitterIDs:@[@"2342355245346",@"789789789789"] pagedRequest:pagedRequest delegate:self context:testContext];
                            }else{
                                [QBUsers usersWithTwitterIDs:@[@"2342355245346",@"789789789789"] pagedRequest:pagedRequest delegate:self];
                            }
                            
                        }else{
                            if(withQBContext){
                                [QBUsers usersWithTwitterIDs:@[@"2342355245346",@"789789789789"] delegate:self context:testContext];
                            }else{
                                [QBUsers usersWithTwitterIDs:@[@"2342355245346",@"789789789789"] delegate:self];
                            }
                        }
                    }
                }
                    break;
                    
                // Get user by email
                case 11:{
                    if (useNewAPI) {
                        [QBRequest userWithEmail:@"Javck@mail.com" successBlock:^(QBResponse *response, QBUUser *user) {
                             NSLog(@"Successfull response!");
                        } errorBlock:^(QBResponse *response) {
                            NSLog(@"Response error: %@", response.error);
                        }];
                    } else {
                        if(withQBContext){
                            [QBUsers userWithEmail:@"Javck@mail.com" delegate:self context:testContext];
                        }else{
                            [QBUsers userWithEmail:@"Javck@mail.com" delegate:self];
                        }
                    }
                }
                    break;
                    
                // Get user by emails
                case 12:{
                    if (useNewAPI) {
                        QBGeneralResponsePage *page = [QBGeneralResponsePage responsePageWithCurrentPage:1 perPage:10];
                        [QBRequest usersWithEmails:@[@"Javck@mail.com", @"abc@gmail.com"] page:page successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users) {
                             NSLog(@"Successfull response!");
                        } errorBlock:^(QBResponse *response) {
                            NSLog(@"Response error: %@", response.error);
                        }];
                    } else {
                        if(withAdditionalRequest){
                            PagedRequest *pagedRequest = [PagedRequest request];
                            pagedRequest.perPage = 5;
                            pagedRequest.page = 1;
                            
                            if(withQBContext){
                                [QBUsers usersWithEmails:@[@"Javck@mail.com", @"abc@gmail.com"] pagedRequest:pagedRequest delegate:self context:testContext];
                            }else{
                                [QBUsers usersWithEmails:@[@"Javck@mail.com", @"abc@gmail.com"] pagedRequest:pagedRequest delegate:self];
                            }
                            
                        }else{
                            if(withQBContext){
                                [QBUsers usersWithEmails:@[@"Javck@mail.com", @"abc@gmail.com"] delegate:self context:testContext];
                            }else{
                                [QBUsers usersWithEmails:@[@"Javck@mail.com", @"abc@gmail.com"] delegate:self];
                            }
                        }
                    }
                }
                    break;
                    
                // Get users by tags
                case 13:{
                    if (useNewAPI) {
                        [QBRequest usersWithTags:@[@"man", @"travel"] successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users) {
                             NSLog(@"Successfull response!");
                        } errorBlock:^(QBResponse *response) {
                            NSLog(@"Response error: %@", response.error);
                        }];
                    } else {
                        if(withQBContext){
                            [QBUsers usersWithTags:[NSArray arrayWithObjects:@"man", nil] delegate:self context:testContext];
                        }else{
                            [QBUsers usersWithTags:[NSArray arrayWithObjects:@"man", @"travel", nil] delegate:self];
                        }
                    }
                }
                    break;
                    
                // Get user by external ID
                case 14:{
                    if (useNewAPI) {
                        [QBRequest userWithExternalID:555 successBlock:^(QBResponse *response, QBUUser *user) {
                             NSLog(@"Successfull response!");
                        } errorBlock:^(QBResponse *response) {
                            NSLog(@"Response error: %@", response.error);
                        }];
                    } else {
                        if(withQBContext){
                            [QBUsers userWithExternalID:555 delegate:self context:testContext];
                        }else{
                            [QBUsers userWithExternalID:555 delegate:self];
                        }
                    }
                }
                    break;
                default:
                    break;
            }
            
            break;
            
        // Edit
        case 2:
            switch (indexPath.row) {
                // Update user by ID
                case 0:{
                    QBUUser *user = [QBUUser user];
                    user.ID = testUserID1;
                    user.tags = [NSMutableArray arrayWithObjects:@"man2", @"travel2", nil];
                    user.website = @"www.mysite2.com";
                    user.phone = @"+78234234";
                    user.customData = @"my new data2";

                    if (useNewAPI) {
                        [QBRequest updateUser:user successBlock:^(QBResponse *response, QBUUser *user) {
                            NSLog(@"Successfull response!");
                        } errorBlock:^(QBResponse *response) {
                            NSLog(@"Response error: %@", response.error);
                        }];
                    } else {
                        if(withQBContext){
                            [QBUsers updateUser:user delegate:self context:testContext];
                        }else{
                            [QBUsers updateUser:user delegate:self];
                        }
                    }
                }
                    break;
                default:
                    break;
            }
            break;
            
        // Delete
        case 3:
            switch (indexPath.row) {
                // Delete user by ID
                case 0:{
                    if (useNewAPI) {
                        [QBRequest deleteUserWithID:3140 successBlock:^(QBResponse *response) {
                             NSLog(@"Successfull response!");
                        } errorBlock:^(QBResponse *response) {
                            NSLog(@"Error: %@", response.error);
                        }];
                    } else {
                        if(withQBContext){
                            [QBUsers deleteUserWithID:3140 delegate:self context:testContext];
                        }else{
                            [QBUsers deleteUserWithID:3140 delegate:self];
                        }
                    }
                }
                    break;
                    
                // Delete user by external ID
                case 1:{
                    if (useNewAPI) {
                        [QBRequest deleteUserWithExternalID:5551 successBlock:^(QBResponse *response) {
                             NSLog(@"Successfull response!");
                        } errorBlock:^(QBResponse *response) {
                            NSLog(@"Error: %@", response.error);
                        }];
                    } else {
                        if(withQBContext){
                            [QBUsers deleteUserWithExternalID:5551 delegate:self context:testContext];
                        }else{
                            [QBUsers deleteUserWithExternalID:5551 delegate:self];
                        }
                    }
                }
                    break;
                default:
                    break;
            }
            
            break;
            
        // Reset
        case 4:
            switch (indexPath.row) {
                // Reset User's password with email
                case 0:{
                    if (useNewAPI) {
                        [QBRequest resetUserPasswordWithEmail:UserEmail1 successBlock:^(QBResponse *response) {
                             NSLog(@"Successfull response!");
                        } errorBlock:^(QBResponse *response) {
                            NSLog(@"Response error: %@", response.error);
                        }];
                    } else {
                        if(withQBContext){
                            [QBUsers resetUserPasswordWithEmail:UserEmail1 delegate:self context:testContext];
                        }else{
                            [QBUsers resetUserPasswordWithEmail:UserEmail1 delegate:self];
                        }
                    }
                }
                    break;

                    break;
                default:
                    break;
            }
            
            break;
            
        default:
            break;
    }
}


#pragma mark -
#pragma mark QBActionStatusDelegate

// QuickBlox queries delegate
- (void)completedWithResult:(Result *)result{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
//    // success result
    if(result.success){
    
        // User Login
        if([result isKindOfClass:QBUUserLogInResult.class]){
            QBUUserLogInResult *res = (QBUUserLogInResult *)result;
            NSLog(@"QBUUserLogInResult, user=%@, \n socialProviderToken=%@, \n socialProviderTokenExpiresAt=%@", res.user, res.socialProviderToken, res.socialProviderTokenExpiresAt);
            
        // User Logout
        }else if([result isKindOfClass:QBUUserLogOutResult.class]){
            QBUUserLogOutResult *res = (QBUUserLogOutResult *)result;
            NSLog(@"QBUUserLogOutResult=%@", res);

        // Create user/
        }else if([result isKindOfClass:QBUUserResult.class]){
            QBUUserResult *res = (QBUUserResult *)result;
            NSLog(@"QBUUserResult, userID=%lu", (unsigned long)res.user.ID);
            
            static NSMutableString *usersStr;
            
            // success result
            if(result.success){
                NSString *user = [NSString stringWithFormat:@"%lu-1@chat.gaydar.quickblox.com;%@", (unsigned long)res.user.ID, res.user.login];
                if(usersStr == nil){
                    usersStr = [[NSMutableString alloc] init];
                    [usersStr appendString:@"\n"];
                }
                [usersStr appendFormat:@"%@\n", user];
            }else{
                NSLog(@"Errors=%@", result.errors); 
            }
            
      
            
        // Get all users
        }else if([result isKindOfClass:QBUUserPagedResult.class]){
            QBUUserPagedResult *res = (QBUUserPagedResult *)result;
            NSLog(@"QBUUserPagedResult, users=%@", res.users);

            
            // Reset password
        }else if([result isKindOfClass:Result.class]){
            NSLog(@"Reset password OK");
        }

    }else{
        NSLog(@"Errors=%@", result.errors); 
    }
    
    NSLog(@"[QBBaseModule sharedModule].tokenExpirationDate=%@", [QBBaseModule sharedModule].tokenExpirationDate);
    
    
}

// QuickBlox queries delegate (with context)
- (void)completedWithResult:(Result *)result context:(void *)contextInfo{
    NSLog(@"completedWithResult, context=%@", contextInfo);
    
    [self completedWithResult:result];
}

@end
