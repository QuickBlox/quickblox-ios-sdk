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

@property (nonatomic, retain) NSString *movieImage;
@property (nonatomic, retain) NSString *movieName;
@property (nonatomic, retain) NSString *movieRating;
@property (nonatomic, retain) NSString *movieDetails;
@property (nonatomic) NSInteger gameModeID;
@property (nonatomic) CGFloat rating;

@end
