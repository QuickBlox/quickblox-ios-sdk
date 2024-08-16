//
//  QBAITranslateMessageProtocol.h
//
//  Created by QuickBlox team
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol QBAITranslateMessageProtocol <NSObject>

@required
/**
 ID of Smart Chat Assistan of Your Application in QuickBlox Dashboard.
 */
@property (readonly) NSString *smartChatAssistantId;

/**
 Text to translate.
 */
@property (readonly) NSString *message;

/**
 Translation language code..
 */
@property (readonly) NSString *languageCode;

@end

NS_ASSUME_NONNULL_END
