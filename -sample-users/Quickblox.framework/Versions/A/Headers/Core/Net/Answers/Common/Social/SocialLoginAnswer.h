//
//  SocialLoginAnswer.h
//  Quickblox
//
//  Created by Igor Khomenko on 7/30/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SocialLoginAnswer : RestAnswer{
}
@property (nonatomic, retain) id session;
@property (nonatomic, retain) id user;
@property (nonatomic, retain) NSString *socialProviderToken;
@property (nonatomic, retain) NSDate *socialProviderTokenExpiresAt;

- (void)returnResult;
- (void)populateAnswer:(NSString *)responce headers:(NSDictionary *)headers;

@end
