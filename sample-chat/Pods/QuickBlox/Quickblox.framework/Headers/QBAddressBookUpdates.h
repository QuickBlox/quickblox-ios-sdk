//
//  QBAddressBookUpdates.h
//  Quickblox
//
//  Created by Andrey Ivanov on 13/09/2017.
//  Copyright © 2017 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QBAddressBookRejectDetails;

NS_ASSUME_NONNULL_BEGIN

@interface QBAddressBookUpdates : NSObject

/** The number of created objects */
@property (nonatomic, assign) NSUInteger created;
/** The number of deleted objects */
@property (nonatomic, assign) NSUInteger deleted;
/** The number of updated objects */
@property (nonatomic, assign) NSUInteger updated;
/** The array of rejected objects */
@property (nonatomic, strong, nullable) NSArray<QBAddressBookRejectDetails *> *rejected;

@end

NS_ASSUME_NONNULL_END
