//
//  QBMEventCreateQuery.h
//  MessagesService
//

//  Copyright 2011 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBMEventQuery.h"

@class QBMEvent;
@interface QBMEventCreateQuery : QBMEventQuery {
	QBMEvent *event;
}
@property (nonatomic,retain) QBMEvent *event;

- (id)initWithEvent:(QBMEvent *)event;

@end
