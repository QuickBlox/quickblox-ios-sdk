//
// Created by Anton Sokolchenko on 3/30/16.
// Copyright (c) 2016 QuickBlox Team. All rights reserved.
//

#import "LoginViewControllerManager.h"
#import "LoginViewController.h"
#import "SVProgressHUD.h"
#import "LoginHelper.h"
#import "SampleCoreManager.h"
#import "SampleCore.h"
#import "UsersDataSourceProtocol.h"
#import "OutgoingCallViewController.h"

@interface LoginViewControllerManager()
@property (nonatomic, strong) QBUUser *user;

@property (nonatomic, strong) NSArray *tags;
@property (nonatomic, strong) NSString *userName;
@end

@implementation LoginViewControllerManager

static NSString *const kOutgoingCallViewControllerWithTagIdentifier = @"OutgoingCallViewControllerWithTagID";

- (void)loginWithCachedUser:(QBUUser *)cachedUser {
	self.user = cachedUser;
	
	[self.input setTags:cachedUser.tags];
	[self.input setUserName:cachedUser.fullName];
	
	// MARK: Step 0
	[self loginWithCurrentUser];
}

- (void)loginWithCurrentUser {
    __weak __typeof(self)weakSelf = self;

    void (^errorBlock)(QBResponse *) = ^(QBResponse *response){
        if (response.error) {
            NSLog(@"Error %@", response.error);
        }
        [SVProgressHUD dismiss];
        [weakSelf.input enableInput];
    };

	self.tags = self.input.tags;
	
	self.userName = [self.input.userName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

	if (!self.user) { // no cache information about user
		self.user = [QBUUser user];
		self.user.login = self.userName;
		self.user.tags = [self.tags mutableCopy];
		self.user.password = [[SampleCore usersDataSource] defaultPassword];
	}
	
    [SVProgressHUD setBackgroundColor:[UIColor grayColor]];
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Logging in REST", nil)];

    [LoginHelper loginOrSignUpUser:self.user successBlock:^(QBResponse *response, QBUUser *_Nullable user) {
        __typeof(self) strongSelf = weakSelf;

        [strongSelf updateCurrentUserFullNameAndTagsWithSuccessBlock:^{

			[SampleCoreManager downloadAndCacheUsersWithTags:strongSelf.tags successBlock:^{
				[strongSelf connectToChatWithErrorBlock:errorBlock];
			} errorBlock:errorBlock];
			
        } errorBlock:errorBlock];
    } errorBlock:errorBlock];
}

- (void)connectToChatWithErrorBlock:(void(^)(QBResponse *response))errorBlock {
    __weak __typeof(self)weakSelf = self;

    [SVProgressHUD showWithStatus:NSLocalizedString(@"Logging in Chat", nil)];

    // MARK: Step 5 - connect to chat
    [[SampleCoreManager instance] connectToChatWithUser:self.user successBlock:^{
        __typeof(self)strongSelf = weakSelf;

        [SampleCore usersDataSource].currentUser = strongSelf.user;

        [[SampleCoreManager instance] registerForRemoteNotifications];
        // MARK: Step 6
        [strongSelf showUsersViewController];
        [SVProgressHUD dismiss];

    } errorBlock:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Login chat error!", nil)];
        if (errorBlock) {
            errorBlock(nil);
        }
    } chatDisconnectedBlock:nil chatReconnectedBlock:nil];

}

- (void)updateCurrentUserFullNameAndTagsWithSuccessBlock:(dispatch_block_t)successBlock errorBlock:(void(^)(QBResponse * _Nonnull response))errorBlock {
    QBUUser *currentUser = [[QBSession currentSession] currentUser];

    NSParameterAssert(currentUser);

    if ([currentUser.fullName isEqualToString:self.userName] &&
            [[currentUser tags] isEqualToArray:[self.tags mutableCopy]]) {
        // when user information has not changed
        currentUser.password = self.user.password;

        self.user = currentUser;

        if (successBlock) {
            successBlock();
        }

        return;
    }

    QBUpdateUserParameters *updateParameters = [[QBUpdateUserParameters alloc] init];
    updateParameters.login = self.user.login;
    updateParameters.fullName = self.userName;
    updateParameters.tags = [self.tags mutableCopy];

    __weak __typeof(self)weakSelf = self;

    [QBRequest updateCurrentUser:updateParameters successBlock:^(QBResponse * _Nonnull response, QBUUser * _Nullable user) {
        __typeof(self)strongSelf = weakSelf;

        strongSelf.user.fullName = user.fullName;
        strongSelf.user.tags = user.tags;
        strongSelf.user.ID = user.ID;

        if (successBlock) {
            successBlock();
        }
    } errorBlock:errorBlock];
}

- (void)showUsersViewController {
	[self.input enableInput];
	
	UIStoryboard *st = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
	OutgoingCallViewController *outgoingVC = [st instantiateViewControllerWithIdentifier:kOutgoingCallViewControllerWithTagIdentifier];
	
	[self.input showViewController:outgoingVC];
}

#pragma mark LoginViewControllerOutput

- (void)loginViewControllerViewDidLoad:(id<LoginViewControllerInput>)loginViewControllerInput {
	self.input = loginViewControllerInput;
	
	QBUUser *cachedUser = [[SampleCore usersDataSource] currentUserWithDefaultPassword];
	
	if (cachedUser) {
		
		self.userName = cachedUser.fullName;
		self.tags = cachedUser.tags;
		
		[self loginWithCachedUser:cachedUser];
	}
}

- (void)loginViewControllerDidTapLoginButton:(id<LoginViewControllerInput>)loginViewControllerInput {
	[self.input disableInput];
	
	[self loginWithCurrentUser];
}

@end