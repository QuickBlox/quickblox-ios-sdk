//
//  QBSessionManager.h
//  QuickBlox
//
//  Created by Andrey Ivanov on 08.09.14.
//
//

#import <Foundation/Foundation.h>

@class QBResponse;
@class QBRequest;
@class QBSessionParameters;

@interface QBSessionManager : NSObject

+ (QBSessionManager *)instance;
- (void)setSessionParameters:(QBSessionParameters *)sessionParameters;
- (void)updateSessionForRequestIfNeeded:(QBRequest *)request successBlock:(void(^)(NSArray *deferredRequests))successBlock;
- (BOOL)sessionTokenHasExpiredOrNeedCreate;


@end
