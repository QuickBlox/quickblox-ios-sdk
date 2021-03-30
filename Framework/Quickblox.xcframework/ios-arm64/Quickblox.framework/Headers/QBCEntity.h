//
//  QBCEntity.h
//
//  Created by QuickBlox team
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
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

NS_ASSUME_NONNULL_END
