//
//  QBAIRoleType.h
//
//  Created by QuickBlox team
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 QBAIRoleType emun interface.
 This emun represents the role of the message sender. Can be a user or assistant.
 */
typedef NSString *QBAIRoleType NS_TYPED_ENUM;
extern QBAIRoleType const  QBAIRoleTypeUser;
extern QBAIRoleType const  QBAIRoleTypeAssistant;

NS_ASSUME_NONNULL_END
