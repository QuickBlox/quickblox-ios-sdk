//
//  QBRGameModeGetQuery.h
//  Quickblox
//
//  Created by Igor Khomenko on 6/16/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QBRGameModeGetQuery : QBRGameModeQuery {
    PagedRequest *pagedRequest;
    NSUInteger gameModeID;
    
    BOOL isMultipleGet;
}
@property (nonatomic, readonly) PagedRequest *pagedRequest;
@property (nonatomic) NSUInteger gameModeID;

- (id)initWithGameModeID:(NSUInteger)gameModeID;
- (id)initWithRequest:(PagedRequest *)_pagedRequest;

@end
