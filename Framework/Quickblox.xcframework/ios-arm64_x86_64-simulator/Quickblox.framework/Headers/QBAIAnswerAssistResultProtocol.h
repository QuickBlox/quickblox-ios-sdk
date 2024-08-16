//
//  QBAIAnswerAssistResultProtocol.h
//
//  Created by QuickBlox team
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol QBAIAnswerAssistResultProtocol <NSObject>

@required
/**
 An answer  from AI.
 */
@property (readonly) NSString *answer;

@end

NS_ASSUME_NONNULL_END
