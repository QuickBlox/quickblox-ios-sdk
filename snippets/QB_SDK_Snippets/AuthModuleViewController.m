//
//  AuthModuleViewController.m
//  QB_SDK_Samples
//
//  Created by Igor Khomenko on 6/5/12.
//  Copyright (c) 2012 Injoit. All rights reserved.
//

#import "AuthModuleViewController.h"

@interface AuthModuleViewController ()

@end

@implementation AuthModuleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Auth", @"Auth");
        self.tabBarItem.image = [UIImage imageNamed:@"circle"];
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(section == 0){
        return @"Session creation";
    }
    
    return @"Session destroy";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0){
        return 4;
    }
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    switch (indexPath.section) {
        // Session creation
        case 0:
            switch (indexPath.row) {
                // Create session
                case 0:
                    if(withContext){
                        [QBAuth createSessionWithDelegate:self context:testContext];
                    }else{
                        [QBAuth createSessionWithDelegate:self];
                    }
                    break;
                    
                // Create session with User auth
                case 1:{
                    QBASessionCreationRequest *extendedAuthRequest = [QBASessionCreationRequest request];
                    extendedAuthRequest.userLogin = @"supersample-ios"; // ID: 218651
                    extendedAuthRequest.userPassword = @"supersample-ios";
                    
                    if(withContext){
                        [QBAuth createSessionWithExtendedRequest:extendedAuthRequest delegate:self context:testContext];
                    }else{
                        [QBAuth createSessionWithExtendedRequest:extendedAuthRequest delegate:self];
                    }
                }
                    break;
                    
                // Create session with Social provider
                case 2:{
                    QBASessionCreationRequest *extendedAuthRequest = [QBASessionCreationRequest request];
                    extendedAuthRequest.socialProvider = @"facebook";
//                    extendedAuthRequest.scope = @[@"publish_stream"];
                    
                    if(withContext){
                        [QBAuth createSessionWithExtendedRequest:extendedAuthRequest delegate:self context:testContext];
                    }else{
                        [QBAuth createSessionWithExtendedRequest:extendedAuthRequest delegate:self];
                    }
                }
                    break;
                    
                // Create session with Social access token
                case 3:{
                    QBASessionCreationRequest *extendedAuthRequest = [QBASessionCreationRequest request];
                    extendedAuthRequest.socialProvider = @"facebook";
                    extendedAuthRequest.socialProviderAccessToken = @"CAAFox8fU5dUBAKg0dCytfoLHQHM3xrDPFLZBg8vdrlIhOFACbqjh3l3whr4riNrZCmhZAJFKoQrwzdXjETlgxEycGHV5yWF4BJA39KwfZAM2z1FWZAk9kLZAM11K7ZCGo0TZBZAjg3JeMip8o34OXzaRVqvcMtLzWr8z0uFRmyhr4LdNW9rGSHVfBue3P8eP7aVUNgvxqNeocl1w9ZAmyWTaxZA";
//                    extendedAuthRequest.socialProviderAccessTokenSecret = @"Hfv7UTtgLIGD89AkndSAdqloEpam16m48YSwhF6od7g";
                    
                    if(withContext){
                        [QBAuth createSessionWithExtendedRequest:extendedAuthRequest delegate:self context:testContext];
                    }else{
                        [QBAuth createSessionWithExtendedRequest:extendedAuthRequest delegate:self];
                    }

                }
                    break;
            }

            break;
            
        // Session destroy
        case 1:
            switch (indexPath.row) {
                // Destroy session
                case 0:
                    if(withContext){
                        [QBAuth destroySessionWithDelegate:self context:testContext];
                    }else{
                        [QBAuth destroySessionWithDelegate:self];
                    }
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
        // Session creation
        case 0:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"Create session";
                    break;
                case 1:
                    cell.textLabel.text = @"Create session with User";
                    break;
                case 2:
                    cell.textLabel.text = @"Create session with social provider";
                    break;
                case 3:
                    cell.textLabel.text = @"Create session with social access token";
                    break;
            }

            break;
            
        // Session destroy
        case 1:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"Destroy session"; 
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
        
        // Create session result
        if([result isKindOfClass:QBAAuthSessionCreationResult.class]){
            QBAAuthSessionCreationResult *res = (QBAAuthSessionCreationResult *)result;
            NSLog(@"QBAAuthSessionCreationResult, session=%@, \n token=%@, \n socialProviderToken=%@, \n socialProviderTokenExpiresAt=%@", res.session, res.token, res.socialProviderToken, res.socialProviderTokenExpiresAt);
            
            
        // Destroy session result
        }else if([result isKindOfClass:QBAAuthResult.class]){
            NSLog(@"Destroy session OK");
        
        }else{
            NSLog(@"Result OK, %@", [result class]);
        }
        
    }else{
        NSLog(@"Errors=%@, Result=%@", result.errors, result.class); 
    }
}

// QuickBlox queries delegate (with context)
- (void)completedWithResult:(Result *)result context:(void *)contextInfo{
    NSLog(@"completedWithResult, context=%@", contextInfo);
    
    [self completedWithResult:result];
}


@end
