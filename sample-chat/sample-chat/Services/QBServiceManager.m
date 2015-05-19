//
//  QBServiceManager.m
//  sample-chat
//
//  Created by Andrey Moskvin on 5/19/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import "QBServiceManager.h"

@interface QBServiceManager () <QMServiceManagerProtocol>

@property (nonatomic, strong) QMAuthService* authService;
@property (nonatomic, strong) QMChatService* chatService;

@end

@implementation QBServiceManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        _authService = [[QMAuthService alloc] initWithServiceManager:self];
        _chatService = [[QMChatService alloc] initWithServiceManager:self cacheDelegate:nil];
    }
    return self;
}

+ (instancetype)instance
{
    static QBServiceManager* manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [QBServiceManager new];
    });
    return manager;
}

- (void)handleErrorResponse:(QBResponse *)response
{
    NSString *errorMessage = [[response.error description] stringByReplacingOccurrencesOfString:@"(" withString:@""];
    errorMessage = [errorMessage stringByReplacingOccurrencesOfString:@")" withString:@""];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Errors"
                                                    message:errorMessage
                                                   delegate:nil
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles: nil];
    [alert show];
}

- (BOOL)isAutorized
{
    return self.authService.isAuthorized;
}

- (QBUUser *)currentUser
{
    return [QBSession currentSession].currentUser;
}

@end
