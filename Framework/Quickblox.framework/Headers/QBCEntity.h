//
//  Entity.h
//  Core
//
//

#import <Foundation/Foundation.h>
#import <Quickblox/QBNullability.h>
#import <Quickblox/QBGeneric.h>

/** Entity class declaration */
/** Overview */
/** Base class for the most business objects */

@interface QBCEntity : NSObject <NSCoding, NSCopying> {
@private
	NSDate *createdAt;
	NSDate *updatedAt;
	NSUInteger ID;
}

/** Object ID */
@property (nonatomic) NSUInteger ID;

/** Created date */
@property (nonatomic, strong, QB_NULLABLE_PROPERTY) NSDate* createdAt;

/** Updated date */
@property (nonatomic, strong, QB_NULLABLE_PROPERTY) NSDate* updatedAt;

@end
