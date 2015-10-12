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

@interface QBChatAttachment : NSObject <NSCoding, NSCopying> {

}

/** Type of attachment: audio/video/image */
@property (nonatomic, strong, QB_NULLABLE_PROPERTY) NSString *type;

/** Content URL */
@property (nonatomic, strong, QB_NULLABLE_PROPERTY) NSString *url;

/** ID of attached element */
@property (nonatomic, strong, QB_NULLABLE_PROPERTY) NSString *ID;

@end
