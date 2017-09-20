//
//  QBAddressBookContact.h
//  Quickblox
//
//  Created by Andrey Ivanov on 13/09/2017.
//  Copyright © 2017 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QBAddressBookContact : NSObject <NSCoding, NSCopying>

/** Name (required only for create/update), min 1 max 255 symbols */
@property (nonatomic, copy) NSString *name;

/** Phone (required), min 10 max 15 symbols */
@property (nonatomic, copy) NSString *phone;

/** Destroy (not required, possible value YES) */
@property (nonatomic) BOOL destroy;

@end

NS_ASSUME_NONNULL_END
