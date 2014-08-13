//
//  Entity.h
//  Core
//
//

#import <Foundation/Foundation.h>

/** Entity class declaration */
/** Overview */
/** Base class for the most business objects */

@interface Entity : NSObject <NSCoding, NSCopying> {
@private
	NSDate *createdAt;
	NSDate *updatedAt;
	NSUInteger ID;
}

/** Object ID */
@property (nonatomic) NSUInteger ID;

/** Created date */
@property (nonatomic,retain) NSDate* createdAt;

/** Updated date */
@property (nonatomic,retain) NSDate* updatedAt;

@end
