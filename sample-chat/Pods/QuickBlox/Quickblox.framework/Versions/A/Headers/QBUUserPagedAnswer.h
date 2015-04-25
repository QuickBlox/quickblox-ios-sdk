//
//  QBUUserPagedAnswer.h
//  UsersService
//
//  Created by Igor Khomenko on 1/27/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PagedAnswer.h"

@class QBUUserAnswer;

@interface QBUUserPagedAnswer : PagedAnswer{
    QBUUserAnswer *userAnswer;
	NSMutableArray *users;
}
@property (nonatomic, retain) NSMutableArray *users;

@end
