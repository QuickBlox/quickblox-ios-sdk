//
//  Created by Tony Arnold on 20/04/2014.
//  Copyright (c) 2014 QMCD Panda Software LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@protocol QMCDRecordMOGeneratorProtocol <NSObject>

@optional
+ (NSString *) entityName;
- (instancetype) entityInManagedObjectContext:(NSManagedObjectContext *)object;
- (instancetype) insertInManagedObjectContext:(NSManagedObjectContext *)object;

@end
