//
//  QBRGameModePagedAnswer.h
//  Quickblox
//
//  Created by Igor Khomenko on 6/16/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QBRGameModePagedAnswer : PagedAnswer{
    QBRGameModeAnswer *gameModeAnswer;

    NSMutableArray *gameModes;
}

@property (nonatomic, retain) NSMutableArray *gameModes;
@end
