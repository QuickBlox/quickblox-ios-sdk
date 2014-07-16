//
//  Movie.h
//  SimpleSample-ratings-ios
//
//  Created by Ruslan on 9/11/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//
//
// This class presents single movie entity
//

#import <Foundation/Foundation.h>

@interface Movie : NSObject

@property (nonatomic, strong) NSString *movieImage;
@property (nonatomic, strong) NSString *movieName;
@property (nonatomic, strong) NSString *movieRating;
@property (nonatomic, strong) NSString *movieDetails;
@property (nonatomic) NSInteger gameModeID;
@property (nonatomic) CGFloat rating;

@end
