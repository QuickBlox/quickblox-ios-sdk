//
//  Storage.h
//  sample-custom_objects
//
//  Created by Igor Khomenko on 6/10/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kMovieClassName @"Movie"

@interface Storage : NSObject

@property (nonatomic, strong) NSMutableArray *moviesList;

+ (instancetype)instance;

@end
