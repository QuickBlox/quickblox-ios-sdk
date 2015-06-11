//
//  QBRGameModeParameterValuePagedAnswer.h
//  Quickblox
//
//  Created by Igor Khomenko on 7/9/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PagedAnswer.h"

@class QBRGameModeParameterValueAnswer;

@interface QBRGameModeParameterValuePagedAnswer : PagedAnswer{
    QBRGameModeParameterValueAnswer *gameModeParemeterValueAnswer;
    
    NSMutableArray *gameModeParemeterValues;
}
@property (nonatomic, retain) NSMutableArray *gameModeParemeterValues;

@end
