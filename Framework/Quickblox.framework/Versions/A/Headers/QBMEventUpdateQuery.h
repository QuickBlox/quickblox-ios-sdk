//
//  QBMEventUpdateQuery.h
//  Quickblox
//
//  Created by Igor Khomenko on 7/19/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//
#import "QBMEventQuery.h"

@class QBMEvent;

@interface QBMEventUpdateQuery : QBMEventQuery{
    QBMEvent *event;
}
@property (nonatomic,retain) QBMEvent *event;

- (id)initWithEvent:(QBMEvent *)event;

@end
