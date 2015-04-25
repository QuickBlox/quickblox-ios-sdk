//
//  QBUUserAnswer.h
//  UsersService
//

//  Copyright 2011 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EntityAnswer.h"

@class QBUUser;

@interface QBUUserAnswer : EntityAnswer {

}
@property (nonatomic,readonly) QBUUser *user;

@end