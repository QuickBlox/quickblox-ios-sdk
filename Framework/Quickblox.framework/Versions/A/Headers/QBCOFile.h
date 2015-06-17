//
//  QBCOFile.h
//  Quickblox
//
//  Created by Igor Khomenko on 10/10/13.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QBCOFile : NSObject <NSCoding, NSCopying>{
@private
    NSString *name;
    NSString *contentType;
    NSData *data;
}

/** File name */
@property (nonatomic, retain) NSString *name;

/** File content type */
@property (nonatomic, retain) NSString *contentType;

/** File data */
@property (nonatomic, retain) NSData *data;

/** Create file object
 @return New instance of QBCOFile
 */
+ (instancetype)file;

@end
