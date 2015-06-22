//
//  Storage.h
//  sample-content
//
//  Created by Igor Khomenko on 6/9/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuickBlox/QuickBlox.h>

@interface Storage : NSObject

@property (nonatomic, strong) NSMutableArray *filesList;

+ (instancetype)instance;

@end
