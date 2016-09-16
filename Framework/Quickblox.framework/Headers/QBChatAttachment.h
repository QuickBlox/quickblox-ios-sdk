//
//  QBChatAttachment.h
//  Quickblox
//
//  Created by Igor Alefirenko on 08/05/2014.
//  Copyright (c) 2014 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quickblox/QBNullability.h>
#import <Quickblox/QBGeneric.h>

@interface QBChatAttachment : NSObject <NSCoding, NSCopying>

/**
 *  Type of attachment.
 *
 *  @discussion Can be any type. For example: audio, video, image, location, any other
 */
@property (nonatomic, copy, nullable) NSString *type;

/**
 *  Content URL.
 */
@property (nonatomic, copy, nullable) NSString *url;

/**
 *  ID of attached element.
 */
@property (nonatomic, copy, nullable) NSString *ID;

/**
 *  Any addictional data.
 */
@property (nonatomic, copy, nullable) NSString *data;

@end
