//
//  QBRGameModeCreateQuery.h
//  RatingsService
//
//  Created by Andrey Kozlov on 4/15/11.
//  Copyright 2011 QuickBlox. All rights reserved.
//

@interface QBRGameModeCreateQuery : QBRGameModeQuery {
}

@property (nonatomic, retain) NSString* title;

- (id) initWithTitle:(NSString*)_title;

@end
