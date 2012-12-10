//
//  QBMEventUpdateQuery.h
//  Quickblox
//
//  Created by Igor Khomenko on 7/19/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

@interface QBMEventUpdateQuery : QBMEventQuery{
    QBMEvent *event;
}
@property (nonatomic,retain) QBMEvent *event;

- (id)initWithEvent:(QBMEvent *)event;

@end
