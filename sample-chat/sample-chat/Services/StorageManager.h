//
//  StorageManager.h
//  sample-chat
//
//  Created by Anton Sokolchenko on 5/28/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StorageManager : NSObject

@property (strong, nonatomic) NSArray *dialogs;
@property (strong, nonatomic) NSArray *users;

+ (instancetype)instance;

- (void)reset;

@end
