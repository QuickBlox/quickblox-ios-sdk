//
//  SSUChangesLoginState.h
//  SimpleSample-users-ios
//
//  Created by Andrey Moskvin on 7/21/14.
//  Copyright (c) 2014 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SSULoginState;
@protocol SSUChangesLoginState <NSObject>

@property (nonatomic, weak) SSULoginState* loginState;

@end
