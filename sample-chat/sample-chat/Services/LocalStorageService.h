//
//  LocalStorageService.h
//  sample-chat
//
//  Created by Igor Khomenko on 10/16/13.
//  Copyright (c) 2013 Igor Khomenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocalStorageService : NSObject

@property (nonatomic, strong) QBUUser *currentUser;

+ (instancetype)shared;

@end
