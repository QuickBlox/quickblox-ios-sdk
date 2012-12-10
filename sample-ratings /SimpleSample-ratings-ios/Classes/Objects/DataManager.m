//
//  DataManager.m
//  SimpleSample-ratings-ios
//
//  Created by Ruslan on 9/11/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "DataManager.h"
#import "Movie.h"

@implementation DataManager

static DataManager *dataManager = nil;

@synthesize movies;

+(DataManager *)shared{
    if(!dataManager){
        dataManager = [[DataManager alloc] init];
        
        // Populate movies library
        //
        
        dataManager.movies = [NSMutableArray array];
        
        Movie *movi = [[Movie alloc] init];
        [movi setMovieName:@"Ted"];
        [movi setMovieImage:@"ted.jpg"];
        [movi setGameModeID:202]; // taken from Admin panel (admin.quickblox.com, Ratings module, Game modes tab)
        [movi setMovieDetails:@"As the result of a childhood wish, John Bennett's teddy bear, Ted, came to life and has been by John's side ever since - a friendship that's tested when Lori, John's girlfriend of four years, wants more from their relationship."];
        [dataManager.movies addObject:movi];
        [movi release];

        movi = [[Movie alloc] init];
        [movi setMovieName:@"Hachiko: A Dog's Tale"];
        [movi setMovieImage:@"hachiko.jpg"];
        [movi setGameModeID:203]; // taken from Admin panel (admin.quickblox.com, Ratings module, Game modes tab)
        [movi setMovieDetails:@"A drama based on the true story of a college professor's bond with the abandoned dog he takes into his home."];
        [dataManager.movies addObject:movi];
        [movi release];

        movi = [[Movie alloc] init];
        [movi setMovieName:@"The Godfather"];
        [movi setMovieImage:@"godfather.jpg"];
        [movi setGameModeID:204]; // taken from Admin panel (admin.quickblox.com, Ratings module, Game modes tab)
        [movi setMovieDetails:@"The aging patriarch of an organized crime dynasty transfers control of his clandestine empire to his reluctant son."];
        [dataManager.movies addObject:movi];
        [movi release];

        movi = [[Movie alloc] init];
        [movi setMovieName:@"The Shawshank Redemption"];
        [movi setMovieImage:@"shawshank_redemption.jpg"];
        [movi setGameModeID:205]; // taken from Admin panel (admin.quickblox.com, Ratings module, Game modes tab)
        [movi setMovieDetails:@"Two imprisoned men bond over a number of years, finding solace and eventual redemption through acts of common decency."];
        [dataManager.movies addObject:movi];
        [movi release];

        movi = [[Movie alloc] init];
        [movi setMovieName:@"The Lord of the Rings: The Fellowship of the Ring"];
        [movi setMovieImage:@"the_lord_of_the_rings.jpg"];
        [movi setGameModeID:206]; // taken from Admin panel (admin.quickblox.com, Ratings module, Game modes tab)
        [movi setMovieDetails:@"An innocent hobbit of The Shire journeys with eight companions to the fires of Mount Doom to destroy the One Ring and the dark lord Sauron forever."];
        [dataManager.movies addObject:movi];
        [movi release];

        movi = [[Movie alloc] init];
        [movi setMovieName:@"Fight Club"];
        [movi setMovieImage:@"fight_club.jpg"];
        [movi setGameModeID:207]; // taken from Admin panel (admin.quickblox.com, Ratings module, Game modes tab)
        [movi setMovieDetails:@"An insomniac office worker and a devil-may-care soap maker form an underground fight club that transforms into a violent revolution."];
        [dataManager.movies addObject:movi];
        [movi release];

        movi = [[Movie alloc] init];
        [movi setMovieName:@"Harry Potter and the Deathly Hallows"];
        [movi setMovieImage:@"harry_potter.jpg"];
        [movi setGameModeID:208]; // taken from Admin panel (admin.quickblox.com, Ratings module, Game modes tab)
        [movi setMovieDetails:@"Harry, Ron and Hermione search for Voldemort's remaining Horcruxes in their effort to destroy the Dark Lord."];
        [dataManager.movies addObject:movi];
        [movi release];
        
    }
    return dataManager;
}

@end
