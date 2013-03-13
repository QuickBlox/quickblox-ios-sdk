//
//  SecondViewController.m
//  QB_SDK_Samples
//
//  Created by Igor Khomenko on 6/5/12.
//  Copyright (c) 2012 Injoit. All rights reserved.
//

#import "UsersModuleViewController.h"

@interface UsersModuleViewController ()

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
							
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 5;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(section == 0){
        return @"Sign In/Sign Out/Sign Up";
    }else if(section == 1){
        return @"Get";
    }else if(section == 2){
        return @"Edit";
    }else if(section == 3){
        return @"Delete";
    }
    
    return @"Reset";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0){
        return 6;
    }else if(section == 1){
        return 12;
    }else if(section == 2){
        return 1;
    }else if(section == 3){
        return 2;
    }
    
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    switch (indexPath.section) {
        // Sign In, Sign Out, Sign Up
        case 0:
            switch (indexPath.row) {
                // User Login with login
                case 0:{
                    
                    if(withContext){
                        [QBUsers logInWithUserLogin:@"iostest3355" password:@"iostest3355" delegate:self context:testContext];
                    }else{
                        [QBUsers logInWithUserLogin:@"iostest3355" password:@"iostest3355"  delegate:self];
                    }
                }
                    break;
                    
                // User Login with email
                case 1:{
                    
                    if(withContext){;
                        [QBUsers logInWithUserEmail:@"cptjack@portroyal.com" password:@"iostest2" delegate:self context:testContext];
                    }else{
                        [QBUsers logInWithUserEmail:@"cptjack@portroyal.com" password:@"iostest2" delegate:self];
                    }
                }
                    break;
                
                // User Login with social provider
                case 2:{
                    
                    if(withContext){;
                        [QBUsers logInWithSocialProvider:@"facebook" scope:@[@"publish_stream"] delegate:self context:testContext];
                    }else{
                        [QBUsers logInWithSocialProvider:@"facebook" scope:@[@"publish_stream"] delegate:self];
                    }
                }
                    break;
                    
                // User Login with social access token
                case 3:{
                    
                    if(withContext){;
                        [QBUsers logInWithSocialProvider:@"facebook" accessToken:@"AAAGmLYiu1lcBADxROiXg4okE80FQO1dJHglsbNT3amxmABnmBmhN6ACbgDqNC3H4Y9GmZAdoSfPUkI9O7ZBJvKQCewNZAp3SoxKCNIMwQZDZD" accessTokenSecret:nil delegate:self context:testContext];
                    }else{
                         [QBUsers logInWithSocialProvider:@"facebook" accessToken:@"AAAGmLYiu1lcBADxROiXg4okE80FQO1dJHglsbNT3amxmABnmBmhN6ACbgDqNC3H4Y9GmZAdoSfPUkI9O7ZBJvKQCewNZAp3SoxKCNIMwQZDZD" accessTokenSecret:nil delegate:self];
                    }
                }
                    break;
                    
                // User Logout
                case 4:{
                    if(withContext){
                        [QBUsers logOutWithDelegate:self context:testContext];
                    }else{
                        [QBUsers logOutWithDelegate:self];
                    }
                }
                    break;
                    
                // User Sign Up
                case 5:{
                    QBUUser *user = [QBUUser user];
                    user.login = @"iostest3355";
                    user.password = @"iostest3355";
                    user.externalUserID = 1234;
                    user.facebookID = @"124343453463463";
                    user.twitterID = @"142345256";
                    user.fullName = @"Javck Bold";
                    user.email = @"Javck@mail.com";
                    user.phone = @"0947773823";
                    user.tags = [NSArray arrayWithObjects:@"man", @"travel", nil];
                    user.website = @"www.mysite.com";
                    
                    if(withContext){
                        [QBUsers signUp:user delegate:self context:testContext];
                    }else{
                        [QBUsers signUp:user delegate:self];
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
                    if(withAdditionalRequest){
                        PagedRequest *pagedRequest = [PagedRequest request];
                        pagedRequest.perPage = 3;
                        pagedRequest.page = 2;
                        
                        if(withContext){
                            [QBUsers usersWithPagedRequest:pagedRequest delegate:self context:testContext];
                        }else{
                            [QBUsers usersWithPagedRequest:pagedRequest delegate:self];
                        }

                    }else{
                        if(withContext){
                            [QBUsers usersWithDelegate:self context:testContext];
                        }else{
                            [QBUsers usersWithDelegate:self];
                        }
                    } 
                }
                    break;
                    
                // Get user by ID
                case 1:{
                    if(withContext){
                        [QBUsers userWithID:14605 delegate:self context:testContext];
                    }else{
                        [QBUsers userWithID:14605 delegate:self];
                    }  
                }
                    break;
                    
                // Get users with ids
                case 2:{
                    if(withAdditionalRequest){
                        PagedRequest *pagedRequest = [PagedRequest request];
                        pagedRequest.perPage = 3;
                        pagedRequest.page = 1;
                        
                        if(withContext){
                            [QBUsers usersWithIDs:@"300,298" pagedRequest:pagedRequest delegate:self context:testContext];
                        }else{
                            [QBUsers usersWithIDs:@"300,298" pagedRequest:pagedRequest delegate:self];
                        }
                        
                    }else{
                        if(withContext){
                            [QBUsers usersWithIDs:@"300,298" delegate:self context:testContext];
                        }else{
                            [QBUsers usersWithIDs:@"300,298" delegate:self];
                        }
                    }
                }
                    break;
                    
                // Get user by login
                case 3:{
                    if(withContext){
                        [QBUsers userWithLogin:@"Javck" delegate:self context:testContext];
                    }else{
                        [QBUsers userWithLogin:@"Javck" delegate:self];
                    }
                }
                    break;
                    
                // Get user by logins
                case 4:{
                    if(withAdditionalRequest){
                        PagedRequest *pagedRequest = [PagedRequest request];
                        pagedRequest.perPage = 3;
                        pagedRequest.page = 1;

                        if(withContext){
                            [QBUsers usersWithLogins:@[@"emma", @"Javck"] pagedRequest:pagedRequest delegate:self context:testContext];
                        }else{
                            [QBUsers usersWithLogins:@[@"emma", @"Javck"] pagedRequest:pagedRequest delegate:self];
                        }
                        
                    }else{
                        if(withContext){
                            [QBUsers usersWithLogins:@[@"emma", @"Javck"] delegate:self context:testContext];
                        }else{
                            [QBUsers usersWithLogins:@[@"emma", @"Javck"] delegate:self];
                        }
                    }
                }
                    break;
                    
                // Get users by fullname
                case 5:{
                    if(withAdditionalRequest){
                        PagedRequest *pagedRequest = [PagedRequest request];
                        pagedRequest.perPage = 1;
                        pagedRequest.page = 1;
                        
                        if(withContext){
                            [QBUsers usersWithFullName:@"Javck Bold" pagedRequest:pagedRequest delegate:self context:testContext];
                        }else{
                            [QBUsers usersWithFullName:@"Javck Bold" pagedRequest:pagedRequest delegate:self];
                        }
  
                    }else{
                        if(withContext){
                            [QBUsers usersWithFullName:@"Javck Bold" delegate:self context:testContext];
                        }else{
                            [QBUsers usersWithFullName:@"Javck Bold" delegate:self];
                        }
                    } 
                }
                    break;
                    
                // Get user by facebook ID
                case 6:{
                    if(withContext){
                        [QBUsers userWithFacebookID:@"124343453463463" delegate:self context:testContext];
                    }else{
                        [QBUsers userWithFacebookID:@"124343453463463" delegate:self];
                    }
                }
                    break;
                    
                // Get user by twitter ID
                case 7:{
                    if(withContext){
                        [QBUsers userWithTwitterID:@"142345256" delegate:self context:testContext];
                    }else{
                        [QBUsers userWithTwitterID:@"142345256" delegate:self];
                    } 
                }
                    break;
                    
                // Get user by email
                case 8:{
                    if(withContext){
                        [QBUsers userWithEmail:@"Javck@mail.com" delegate:self context:testContext];
                    }else{
                        [QBUsers userWithEmail:@"Javck@mail.com" delegate:self];
                    }
                }
                    break;
                    
                // Get user by emails
                case 9:{
                    if(withAdditionalRequest){
                        PagedRequest *pagedRequest = [PagedRequest request];
                        pagedRequest.perPage = 5;
                        pagedRequest.page = 1;
                        
                        if(withContext){
                            [QBUsers usersWithEmails:@[@"Javck@mail.com", @"abc@gmail.com"] pagedRequest:pagedRequest delegate:self context:testContext];
                        }else{
                            [QBUsers usersWithEmails:@[@"Javck@mail.com", @"abc@gmail.com"] pagedRequest:pagedRequest delegate:self];
                        }
                        
                    }else{
                        if(withContext){
                            [QBUsers usersWithEmails:@[@"Javck@mail.com", @"abc@gmail.com"] delegate:self context:testContext];
                        }else{
                            [QBUsers usersWithEmails:@[@"Javck@mail.com", @"abc@gmail.com"] delegate:self];
                        }
                    }
                }
                    break;
                    
                // Get users by tags
                case 10:{
                    if(withContext){
                        [QBUsers usersWithTags:[NSArray arrayWithObjects:@"man", nil] delegate:self context:testContext];
                    }else{
                        [QBUsers usersWithTags:[NSArray arrayWithObjects:@"man", @"travel", nil] delegate:self];
                    }
                }
                    break;
                    
                // Get user by external ID
                case 11:{
                    if(withContext){
                        [QBUsers userWithExternalID:555 delegate:self context:testContext];
                    }else{
                        [QBUsers userWithExternalID:555 delegate:self];
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
                    user.ID = 300;
                    user.externalUserID = 555;
                    user.tags = [NSArray arrayWithObjects:@"man", @"travel", nil];
                    user.website = @"www.mysite.com";
                    
                    if(withContext){
                        [QBUsers updateUser:user delegate:self context:testContext];
                    }else{
                        [QBUsers updateUser:user delegate:self];
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
                    if(withContext){
                        [QBUsers deleteUserWithID:48456 delegate:self context:testContext];
                    }else{
                        [QBUsers deleteUserWithID:48456 delegate:self];
                    } 
                }
                    break;
                    
                // Delete user by external ID
                case 1:{
                    if(withContext){
                        [QBUsers deleteUserWithExternalID:5551 delegate:self context:testContext];
                    }else{
                        [QBUsers deleteUserWithExternalID:5551 delegate:self];
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
                    if(withContext){
                        [QBUsers resetUserPasswordWithEmail:@"khig@gmail.com" delegate:self context:testContext];
                    }else{
                        [QBUsers resetUserPasswordWithEmail:@"khig@gmail.com" delegate:self];
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

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *reuseIdentifier = [NSString stringWithFormat:@"%d", indexPath.row];
    
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if(cell == nil){
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    switch (indexPath.section) {
            // Sign In, Sign Out, Sign Up
        case 0:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"User Login with login";
                    break;
                case 1:
                    cell.textLabel.text = @"User Login with email";
                    break;
                case 2:
                    cell.textLabel.text = @"User Login with social provider";
                    break;
                case 3:
                    cell.textLabel.text = @"User Login with social access token";
                    break;
                case 4:
                    cell.textLabel.text = @"User Logout";
                    break;
                case 5:
                    cell.textLabel.text = @"User Sign Up"; 
                    break;
                default:
                    break;
            }
            break;
            
        // Get
        case 1:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"Get all users";
                    break;
                case 1:
                    cell.textLabel.text = @"Get user by ID";
                    break;
                case 2:
                    cell.textLabel.text = @"Get users with ids";
                    break;
                case 3:
                    cell.textLabel.text = @"Get user by login";
                    break;
                case 4:
                    cell.textLabel.text = @"Get user by logins";
                    break;
                case 5:
                    cell.textLabel.text = @"Get users by fullname";
                    break;
                case 6:
                    cell.textLabel.text = @"Get user by facebook ID";
                    break;
                case 7:
                    cell.textLabel.text = @"Get user by twitter ID";
                    break;
                case 8:
                    cell.textLabel.text = @"Get user by email";
                    break;
                case 9:
                    cell.textLabel.text = @"Get user by emails";
                    break;
                case 10:
                    cell.textLabel.text = @"Get users by tags";
                    break;
                case 11:
                    cell.textLabel.text = @"Get user by external ID";
                    break;
                default:
                    break;
            }
            
            break;
            
        // Edit
        case 2:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"Update user by ID";
                    break;
                default:
                    break;
            }
            break;
            
        // Delete
        case 3:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"Delete user by ID";
                    break;
                case 1:
                    cell.textLabel.text = @"Delete user by external ID";
                    break;
                default:
                    break;
            }

            break;
            
        // Reset
        case 4:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"Reset user's password with email";
                    break;
                default:
                    break;
            }
            
            break;
            
        default:
            break;
    }
    
    return cell;
}

// QuickBlox queries delegate
- (void)completedWithResult:(Result *)result{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    // success result
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
            NSLog(@"QBUUserResult, user=%@", res.user);
            
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
}

// QuickBlox queries delegate (with context)
- (void)completedWithResult:(Result *)result context:(void *)contextInfo{
    NSLog(@"completedWithResult, context=%@", contextInfo);
    
    [self completedWithResult:result];
}

@end
