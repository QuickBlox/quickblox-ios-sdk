//
//  QBRGameModeUpdateQuery.h
//  Quickblox
//
//  Created by Igor Khomenko on 6/16/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBRGameModeQuery.h"

@class QBRGameMode;

@interface QBRGameModeUpdateQuery : QBRGameModeQuery{
    QBRGameMode *gameMode;
}
@property (nonatomic,retain) QBRGameMode *gameMode;

- (id)initWithGameMode:(QBRGameMode *)gameMode;

@end
