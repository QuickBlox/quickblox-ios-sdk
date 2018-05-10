//
//  QMUserProfileProtocol.h
//  QMServices
//
//  Created by Andrey Ivanov on 28.04.15.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quickblox/Quickblox.h>

/**
 *  Main QMServices protocol.
 */

NS_ASSUME_NONNULL_BEGIN

@protocol QMServiceManagerProtocol <NSObject>
@required

/**
 *  Current user
 *
 *  @return QBUUser instance
 */
@property (nonatomic, strong, readonly) QBUUser *currentUser;

/**
 *  Check is current session is authorized
 *
 *  @return YES if authorized
 */
@property (nonatomic, assign, readonly) BOOL isAuthorized;

/**
 *  This method called when some QBReqest falling. Use this method for handling errors, like show alert with error.
 *  
 *  @param response QBResponse instance. See response.error for falling inforamtion.
 */
- (void)handleErrorResponse:(QBResponse *)response;

@optional

- (NSString *)appGroupIdentifier;

@end

NS_ASSUME_NONNULL_END
