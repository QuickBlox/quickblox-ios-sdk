//
//  NSFetchedResultsController+QMCDFetching.h
//  TradeShow
//
//  Created by Injoit on 2/5/13.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import <CoreData/CoreData.h>

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
/**
 Category methods to make working with NSFetchedResultsController simpler.

 @since Available in v3.0 and later.
 */
@interface NSFetchedResultsController (QMCDFetching)

/**
 Executes -performFetch: and logs any errors to the console.

 @since Available in v3.0 and later.
 */
- (void) QM_performFetch;

@end
#endif
