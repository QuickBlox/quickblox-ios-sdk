//
//  QBChatAbstractMessage+TextEncoding.h
//  QMServices
//
//  Created by Igor Alefirenko on 20.08.14.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import <Quickblox/QBChatMessage.h>

@interface QBChatMessage (TextEncoding)

@property (strong, nonatomic, readonly) NSString *encodedText;

@end
