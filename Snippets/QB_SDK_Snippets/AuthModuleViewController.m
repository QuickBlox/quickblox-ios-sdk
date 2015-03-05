//
//  AuthModuleViewController.m
//  QB_SDK_Samples
//
//  Created by Igor Khomenko on 6/5/12.
//  Copyright (c) 2012 Injoit. All rights reserved.
//

#import "AuthModuleViewController.h"
#import "AuthDataSource.h"


@interface AuthModuleViewController ()
@property (nonatomic) AuthDataSource *dataSource;
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

- (void)viewDidLoad{
    [super viewDidLoad];
    self.dataSource = [[AuthDataSource alloc] init];
    tableView.dataSource = self.dataSource;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    switch (indexPath.section) {
        // Session creation
        case 0:
            switch (indexPath.row) {
                // Create session
                case 0:
                    if (useNewAPI) {
                        [QBRequest createSessionWithSuccessBlock:^(QBResponse *response, QBASession *session) {
                            NSLog(@"Successfull response!");
                        } errorBlock:^(QBResponse *response) {
                            NSLog(@"Response error: %@", response.error);
                        }];
                    } else {
                        if (withQBContext) {
                            [QBAuth createSessionWithDelegate:self context:testContext];
                        } else {
                            [QBAuth createSessionWithDelegate:self];
                        }
                    }
                    break;
                    
                // Create session with User auth
                case 1:{
                    if (useNewAPI) {
                        QBSessionParameters *parameters = [[QBSessionParameters alloc] init];
                        parameters.userLogin = UserLogin1;
//                        parameters.userEmail = UserEmail1;
                        parameters.userPassword = UserPassword1;
                        
                        [QBRequest createSessionWithExtendedParameters:parameters successBlock:^(QBResponse *response, QBASession *session) {
                            NSLog(@"Successfull response!");
                        } errorBlock:^(QBResponse *response) {
                            NSLog(@"Response error: %@", response.error);
                        }];
                    } else {
                        
                        QBASessionCreationRequest *extendedAuthRequest = [QBASessionCreationRequest request];
                        extendedAuthRequest.userLogin = UserLogin1;
                        extendedAuthRequest.userPassword = UserPassword1;
                        
                        if(withQBContext){
                            [QBAuth createSessionWithExtendedRequest:extendedAuthRequest delegate:self context:testContext];
                        }else{
                            [QBAuth createSessionWithExtendedRequest:extendedAuthRequest delegate:self];
                        }
                    }
                }
                    break;
                    
                // Create session with Social provider
                case 2:{
                    if (useNewAPI) {
                        QBSessionParameters *parameters = [[QBSessionParameters alloc] init];
                        parameters.socialProvider = @"facebook";
                        
                        [QBRequest createSessionWithExtendedParameters:parameters successBlock:^(QBResponse *response, QBASession *session) {
                            NSLog(@"Successfull response!");
                        } errorBlock:^(QBResponse *response) {
                            NSLog(@"Response error: %@", response.error);
                        }];
                    } else {
                        QBASessionCreationRequest *extendedAuthRequest = [QBASessionCreationRequest request];
                        extendedAuthRequest.socialProvider = @"facebook";
                        //                    extendedAuthRequest.scope = @[@"publish_stream"];
                        
                        if(withQBContext){
                            [QBAuth createSessionWithExtendedRequest:extendedAuthRequest delegate:self context:testContext];
                        }else{
                            [QBAuth createSessionWithExtendedRequest:extendedAuthRequest delegate:self];
                        }
                    }
                }
                    break;
                    
                // Create session with Social access token
                case 3:{
                    if (useNewAPI) {
                        QBSessionParameters *parameters = [[QBSessionParameters alloc] init];
                        parameters.socialProvider = @"facebook";
                        parameters.socialProviderAccessToken = @"CAAEra8jNdnkBABAnhaesXZCceUvsKFywMg91gJueUdkproXpAp10ckxLZACTYblnxO7RmMroIV62VhmjdgHpcQFP2v8EKwOs7ZBWche562PlniDdEyeVFK0oIdkDWGRknbfvxo5NySLkK8tnVTVMAPqkNA8vpluIJtO1fYC2PJKiKZAgfhUMpGgD8J2y8UvP9YoSIKUmG5GY9ZCGBCPY4";
                        
                        [QBRequest createSessionWithExtendedParameters:parameters successBlock:^(QBResponse *response, QBASession *session) {
                            NSLog(@"Successfull response!");
                        } errorBlock:^(QBResponse *response) {
                            NSLog(@"Response error: %@", response.error);
                        }];
                    } else {
                        QBASessionCreationRequest *extendedAuthRequest = [QBASessionCreationRequest request];
                        extendedAuthRequest.socialProvider = @"facebook";
                        extendedAuthRequest.socialProviderAccessToken = @"CAAEra8jNdnkBABAnhaesXZCceUvsKFywMg91gJueUdkproXpAp10ckxLZACTYblnxO7RmMroIV62VhmjdgHpcQFP2v8EKwOs7ZBWche562PlniDdEyeVFK0oIdkDWGRknbfvxo5NySLkK8tnVTVMAPqkNA8vpluIJtO1fYC2PJKiKZAgfhUMpGgD8J2y8UvP9YoSIKUmG5GY9ZCGBCPY4";
                        
    //                    extendedAuthRequest.socialProvider = @"twitter";
    //                    extendedAuthRequest.socialProviderAccessToken = @"183566025-TxJG7zCQAVNs6WRaRIVBXPxfaIvHXRIts9lGF1Zw";
    //                    extendedAuthRequest.socialProviderAccessTokenSecret = @"Hfv7UTtgLIGD89AkndSAdqloEpam16m48YSwhF6od7g";
                        
                        if(withQBContext){
                            [QBAuth createSessionWithExtendedRequest:extendedAuthRequest delegate:self context:testContext];
                        }else{
                            [QBAuth createSessionWithExtendedRequest:extendedAuthRequest delegate:self];
                        }
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
                    if (useNewAPI) {
                        [QBRequest destroySessionWithSuccessBlock:^(QBResponse *response) {
                            NSLog(@"Successfull response!");
                        } errorBlock:^(QBResponse *response) {
                            NSLog(@"Response error: %@", response.error);
                        }];
                    } else {
                        if(withQBContext){
                            [QBAuth destroySessionWithDelegate:self context:testContext];
                        }else{
                            [QBAuth destroySessionWithDelegate:self];
                        }
                        break;
                    }
            }

            break;
            
        default:
            break;
    }
}

// QuickBlox queries delegate
- (void)completedWithResult:(QBResult *)result{
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
- (void)completedWithResult:(QBResult *)result context:(void *)contextInfo{
    NSLog(@"completedWithResult, context=%@", contextInfo);
    
    [self completedWithResult:result];
}

-(void)setProgress:(float)progress{
    NSLog(@"setProgress %f", progress);
}


@end
