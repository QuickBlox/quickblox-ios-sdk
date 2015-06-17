//
//  Storage.h
//  sample-users
//
//  Created by Igor Khomenko on 6/11/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Storage : NSObject

@property (nonatomic, strong) NSMutableArray *users;

+ (instancetype)instance;

@end
