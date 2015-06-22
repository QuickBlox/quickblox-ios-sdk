//
//  QBMEventPagedAnswer.h
//  Quickblox
//
//  Created by Igor Khomenko on 7/19/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "PagedAnswer.h"

@class QBMEventAnswer;

@interface QBMEventPagedAnswer : PagedAnswer{
    QBMEventAnswer *eventAnswer;
    NSMutableArray *events;
}

@property (nonatomic, retain) NSMutableArray *events;

@end
