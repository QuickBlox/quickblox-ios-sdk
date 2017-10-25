//
//  Entity.h
//  Core
//
//

#import <Foundation/Foundation.h>

/** 
 *  QBCEntity class interface.
 *  Base class for the most business objects 
 */
@interface QBCEntity : NSObject <NSCoding, NSCopying>

/** 
 *  Object ID.
 */
@property (nonatomic, assign) NSUInteger ID;

/** 
 *  Created date.
 */
@property (nonatomic, strong, nullable) NSDate *createdAt;

/** 
 *  Updated date.
 */
@property (nonatomic, strong, nullable) NSDate *updatedAt;

@end
