//
// Created by Anton Sokolchenko on 3/30/16.
// Copyright (c) 2016 QuickBlox Team. All rights reserved.
//

#import "LoginManager.h"

@implementation LoginManager

+ (void)loginOrSignupUser:(QBUUser *)user successBlock:(void(^)(QBResponse * response, QBUUser * _Nullable user))successBlock errorBlock:(void(^)(QBResponse *response))errorBlock {
	
	
	[self loginWithUser:user successBlock:successBlock errorBlock:^(QBResponse *response) {
		
		
		[self signUpUser:user successBlock:^(QBResponse *response, QBUUser * _Nullable newUser) {
			
			[self loginWithUser:user successBlock:successBlock errorBlock:errorBlock];
			
		} errorBlock:errorBlock];
		
	}];
	
}

+ (void)loginWithUser:(QBUUser *)user successBlock:(void(^)(QBResponse * response, QBUUser * _Nullable user))successBlock errorBlock:(void(^)(QBResponse *response))errorBlock {
	[QBRequest logInWithUserLogin:user.login password:user.password successBlock:successBlock errorBlock:errorBlock];
}

+ (void)signUpUser:(QBUUser *)user successBlock:(void(^)(QBResponse * response, QBUUser * _Nullable user))successBlock errorBlock:(void(^)(QBResponse *response))errorBlock {
	[QBRequest signUp:user successBlock:successBlock errorBlock:errorBlock];
}

@end