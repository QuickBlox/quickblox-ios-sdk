//
//  QBAuth.h
//  AuthService
//
//  Copyright 2011 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBBaseModule.h"
#import "QBCoreDelegates.h"

/** QBAuth class declaration. */
/** Overview */
/** This class is the main entry point to work with Quickblox Auth module. */

@interface QBAuth : QBBaseModule {

}

#pragma mark -
#pragma mark App authorization

/**
 Session Creation
 
 Type of Result - QBAAuthSessionCreationResult.
 
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBAAuthSessionCreationResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+(NSObject<Cancelable> *)createSessionWithDelegate:(NSObject<QBActionStatusDelegate> *)delegate __attribute__((deprecated("use '+[QBRequest createSessionWithSuccessBlock:errorBlock:]' instead.")));

+(NSObject<Cancelable> *)createSessionWithDelegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context __attribute__((deprecated("use '+[QBRequest createSessionWithSuccessBlock:errorBlock:]' instead.")));

#pragma mark -
#pragma mark App authorization with extended Request

/**
 Session Creation with extended Request
 
 Type of Result - QBAAuthSessionCreationResult.
 
 
 @param extendedRequest Extended set of request parameters
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBAAuthSessionCreationResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+(NSObject<Cancelable> *)createSessionWithExtendedRequest:(QBASessionCreationRequest *)extendedRequest delegate:(NSObject<QBActionStatusDelegate> *)delegate __attribute__((deprecated("use '+[QBRequest createSessionWithExtendedParameters:successBlock:errorBlock:]' instead.")));
///
+(NSObject<Cancelable> *)createSessionWithExtendedRequest:(QBASessionCreationRequest *)extendedRequest delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context __attribute__((deprecated("use '+[QBRequest createSessionWithExtendedParameters:successBlock:errorBlock:]' instead.")));


#pragma mark -
#pragma mark Delete session

/**
 Session Destroy
 
 Type of Result - QBAAuthResult.
 
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBAAuthResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+(NSObject<Cancelable> *)destroySessionWithDelegate:(NSObject<QBActionStatusDelegate> *)delegate __attribute__((deprecated("use '+[QBRequest destroySessionWithSuccessBlock:errorBlock:]' instead.")));
///
+(NSObject<Cancelable> *)destroySessionWithDelegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context __attribute__((deprecated("use '+[QBRequest destroySessionWithSuccessBlock:errorBlock:]' instead.")));
@end
