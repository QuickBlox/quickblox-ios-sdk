//
// Created by Andrey Kozlov on 01/12/2013.
// Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quickblox/QBNullability.h>
#import <Quickblox/QBGeneric.h>

@class QBRequest;
@class QBResponse;
@class QBRequestStatus;

@protocol QBResponseSerializationProtocol;
@protocol QBRequestSerialisationProtocol;
@class QBHTTPRequestSerializer;

NS_ASSUME_NONNULL_BEGIN

extern const struct QBRequestMethod {
    __unsafe_unretained NSString *POST;
    __unsafe_unretained NSString *GET;
    __unsafe_unretained NSString *HEAD;
    __unsafe_unretained NSString *PUT;
    __unsafe_unretained NSString *DELETE;
} QBRequestMethod;

typedef NS_ENUM(NSUInteger, QBRequestTaskType) {
    QBRequestTaskTypeNotSet,
    QBRequestTaskTypeData,
    QBRequestTaskTypeUpload,
    QBRequestTaskTypeDownload
};

/** Blocks typedef */
typedef void (^QBRequestStatusUpdateBlock)(QBRequest *request, QBRequestStatus * _Nullable status);
typedef void (^QBRequestCompletionBlock)(QBRequest *request, QBResponse *response, NSDictionary QB_GENERIC(NSString *, id) * _Nullable objects);

typedef void (^QBRequestErrorBlock)(QBResponse *response);

/** 
 *  QBRequest class interface.
 *  This class represents all requests to Quickblox API.
 */
@interface QBRequest : NSObject

/** 
 *  Determines if NSURLSessionTask was canceled.
 */
@property (nonatomic, getter=isCancelled, readonly) BOOL canceled;

/** 
 *  Formed NSURLSessionTask with request information.
 */
@property (nonatomic, weak, nullable) NSURLSessionTask* task;

/** 
 *  Formed task type.
 */
@property (nonatomic, assign, readonly) QBRequestTaskType taskType;

/** 
 *  Request completion block.
 */
@property (nonatomic, copy, nullable) QBRequestCompletionBlock completionBlock;

/** 
 *  Request update block.
 */
@property (nonatomic, copy, nullable) QBRequestStatusUpdateBlock updateBlock;

/** 
 *  Request serialiser.
 */
@property (nonatomic, strong, nullable) QBHTTPRequestSerializer <QBRequestSerialisationProtocol> *requestSerialisator;

/** 
 *  Response serialiser (QBHTTPResponseSerializer<QBResponseSerializationProtocol>).
 */
@property (nonatomic, strong, nullable) NSArray QB_GENERIC(__kindof id<QBResponseSerializationProtocol>) *responseSerialisators;

/** 
 *  Request headers.
 */
@property (nonatomic, copy, nullable) NSDictionary QB_GENERIC(NSString *, NSString *) *headers;

/** 
 *  Request body.
 */
@property (nonatomic, copy, nullable) NSData *body;

/** 
 *  Request encoding.
 */
@property (nonatomic) NSStringEncoding encoding;

/** 
 *  Request parameters.
 */
@property (nonatomic, copy, readonly, nullable) NSDictionary QB_GENERIC(NSString *, NSString *) *parameters;

/** Parameters methods */
- (void)addParametersFromDictionary:(nullable NSDictionary QB_GENERIC(NSString *, NSString *) *)otherDictionary;
- (void)addParameter:(id)obj forKey:(NSString *)key;
- (void)removeParameterForKey:(nullable NSString *)key;
- (void)extractParametersFromDictionary:(nullable NSDictionary QB_GENERIC(NSString *, NSString *) *)parameters;

/** Constructors */
+ (instancetype)new NS_UNAVAILABLE;

- (nullable instancetype)initWithType:(QBRequestTaskType)type completionBlock:(nullable QBRequestCompletionBlock)completionBlock;
- (nullable instancetype)initWithType:(QBRequestTaskType)type updateBlock:(nullable QBRequestStatusUpdateBlock)updateBlock completionBlock:(nullable QBRequestCompletionBlock)completionBlock;

/**
 *  Cancels NSURLSessionTask associated with request.
 */
- (void)cancel;

@end

NS_ASSUME_NONNULL_END
