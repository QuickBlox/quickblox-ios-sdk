//
//  QBAddressBookRejectDetails.h
//  Pods
//
//  Created by Andrey Ivanov on 14/09/2017.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QBAddressBookRejectDetails : NSObject
/** The index of rejected object */
@property (nonatomic, assign) NSUInteger index;
/** Reject reason */
@property (nonatomic, copy) NSString *details;

@end

NS_ASSUME_NONNULL_END
