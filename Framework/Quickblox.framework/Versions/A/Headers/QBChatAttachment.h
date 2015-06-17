//
//  QBChatAttachment.h
//  Quickblox
//
//  Created by Igor Alefirenko on 08/05/2014.
//  Copyright (c) 2014 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QBChatAttachment : NSObject <NSCoding, NSCopying> {

}

/** Type of attachment: audio/video/image */
@property (nonatomic, retain) NSString *type;

/** Content URL */
@property (nonatomic, retain) NSString *url;

/** ID of attached element */
@property (nonatomic, retain) NSString *ID;

@end
