//
//  AI.h
//
//  Created by QuickBlox team
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol QBAIAnswerAssistHistoryMessageProtocol;
@protocol QBAIAnswerAssistResultProtocol;
@protocol QBAITranslateResultProtocol;

@interface AI : NSObject
/**
 Create answer assist request
 
 @param answerAssist answer assist instance
 
 @return An answer from AI'.
 */
- (void)answerAssistWithSmartChatAssistantId:(NSString *)smartChatAssistantId
                             messageToAssist:(NSString *)messageToAssist
                                     history:(NSArray<id<QBAIAnswerAssistHistoryMessageProtocol>> *)history
                                  completion:(void (^) (id<QBAIAnswerAssistResultProtocol>result, NSError * _Nullable error))completion;

/**
 Create translate request
 
 @param translate translate message instance
 
 @return An answer from AI'.
 */
- (void)translateWithSmartChatAssistantId:(NSString *)smartChatAssistantId
                          textToTranslate:(NSString *)textToTranslate
                             languageCode:(NSString *)languageCode
                               completion:(void (^) (id<QBAITranslateResultProtocol>result, NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
