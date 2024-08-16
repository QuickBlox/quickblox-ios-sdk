//
//  QBRequest+AITranslate.h
//
//  Created by QuickBlox team
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuickBlox/QBRequest.h>

NS_ASSUME_NONNULL_BEGIN

@class QBAITranslateMessage;

@interface QBRequest (AITranslate)

/**
 Create translate request
 
 @param translate translate message instance
 
 @return An answer from AI'.
 */
+ (void)translateWithMessage:(QBAITranslateMessage *)translate
                  completion:(void (^) (NSString * _Nullable answer, NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
