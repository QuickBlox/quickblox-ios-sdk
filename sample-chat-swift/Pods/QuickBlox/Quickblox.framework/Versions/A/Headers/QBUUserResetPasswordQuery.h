//
//  QBUUserResetPasswordQuery.h
//  Quickblox
//
//  Created by Igor Khomenko on 7/22/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QBUUserQuery.h"

@interface QBUUserResetPasswordQuery : QBUUserQuery

@property (nonatomic,retain) NSString *email;

- (id)initWithEmail:(NSString *)email;
@end
