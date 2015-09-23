//
//  QMUserProfileProtocol.h
//  QMServices
//
//  Created by Andrey Ivanov on 28.04.15.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Main QMServices protocol.
 */

@protocol QMServiceManagerProtocol <NSObject>
@required

/**
 *  Get user from current session
 *
 *  @return QBUUser instance
 */
- (QBUUser *)currentUser;

/**
 *  Check is current session is authorized
 *
 *  @return YES if authorized
 */
- (BOOL)isAuthorized;

/**
 *  This method called when some QBReqest falling. Use this method for handling errors, like show alert with error.
 *  
 *  @param QBResponse instance. See response.error for falling inforamtion.
 */
- (void)handleErrorResponse:(QBResponse *)response;

@end