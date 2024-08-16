//
//  QBAIAnswerAssistResult.h
//
//  Created by QuickBlox team
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import <Quickblox/Quickblox.h>

NS_ASSUME_NONNULL_BEGIN

@protocol QBAIAnswerAssistResultProtocol;

@interface QBAIAnswerAssistResult : QBCEntity <QBAIAnswerAssistResultProtocol, NSCoding, NSCopying>
/**
 An answer  from AI.
 */
@property (readonly) NSString *answer;

// Unavailable initializers
- (id)init NS_UNAVAILABLE;
+ (id)new NS_UNAVAILABLE;

- (instancetype)initWithAnswer:(NSString *)answer;

@end

NS_ASSUME_NONNULL_END
