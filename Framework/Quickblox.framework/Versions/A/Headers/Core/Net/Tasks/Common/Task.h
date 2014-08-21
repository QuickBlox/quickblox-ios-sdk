//
//  Task.h
//  Core
//

//  Copyright 2010 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Task : Performer <QBActionStatusDelegate> {
	NSUInteger itemsCount;
	NSUInteger currentItem;
}
@property (nonatomic) NSUInteger itemsCount;
@property (nonatomic) NSUInteger currentItem;

@end
