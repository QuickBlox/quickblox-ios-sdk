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

typedef enum QBAutoCreateSessionType {
    QBAutoCreateSessionTypeNone,
    QBAutoCreateSessionTypeSimple,
    QBAutoCreateSessionTypeSocialProvider
}QBAutoCreateSessionType;

@interface QBSessionManager : NSObject

@property (assign, nonatomic, readonly) QBAutoCreateSessionType autoCreateSessionType;

+ (QBSessionManager *)instance;
- (BOOL)setSessionParameters:(QBSessionParameters *)sessionParameters;
- (BOOL)clearCurrentSessionParameters;
- (void)updateSessionForRequestIfNeeded:(QBRequest *)request successBlock:(void(^)(NSArray *deferredRequests))successBlock;
- (BOOL)sessionTokenHasExpiredOrNeedCreate;


@end
