//
//  Movie.m
//  SimpleSample-ratings-ios
//
//  Created by Ruslan on 9/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Movie.h"

@implementation Movie

@synthesize movieName;
@synthesize movieImage;
@synthesize movieRating;
@synthesize movieDetails;
@synthesize gameModeID;
@synthesize rating;


-(void) dealloc{
    [movieName release];
    [movieImage release];
    [movieRating release];
    [movieDetails release];
    
    [super dealloc];
}

@end
