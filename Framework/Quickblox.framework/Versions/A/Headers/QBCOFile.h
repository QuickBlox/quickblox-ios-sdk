//
//  QBCOFile.h
//  Quickblox
//
//  Created by Igor Khomenko on 10/10/13.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quickblox/QBNullability.h>
#import <Quickblox/QBGeneric.h>

@interface QBCOFile : NSObject <NSCoding, NSCopying>{
@private
    NSString *name;
    NSString *contentType;
    NSData *data;
}

/** File name */
@property (nonatomic, retain, QB_NULLABLE_PROPERTY) NSString *name;

/** File content type */
@property (nonatomic, retain, QB_NULLABLE_PROPERTY) NSString *contentType;

/** File data */
@property (nonatomic, retain, QB_NULLABLE_PROPERTY) NSData *data;

/** Create file object
 @return New instance of QBCOFile
 */
+ (QB_NONNULL instancetype)file;

@end
