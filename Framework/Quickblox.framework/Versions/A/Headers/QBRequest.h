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

extern const struct QBRequestMethod {
    __unsafe_unretained NSString *QB_NONNULL_S POST;
    __unsafe_unretained NSString *QB_NONNULL_S GET;
    __unsafe_unretained NSString *QB_NONNULL_S HEAD;
    __unsafe_unretained NSString *QB_NONNULL_S PUT;
    __unsafe_unretained NSString *QB_NONNULL_S DELETE;
} QBRequestMethod;

typedef NS_ENUM(NSUInteger, QBRequestTaskType) {
    QBRequestTaskTypeNotSet,
    QBRequestTaskTypeData,
    QBRequestTaskTypeUpload,
    QBRequestTaskTypeDownload
};

/** Blocks typedef */
typedef void (^QBRequestStatusUpdateBlock)(QBRequest *QB_NONNULL_S request, QBRequestStatus *QB_NULLABLE_S status);
typedef void (^QBRequestCompletionBlock)(QBRequest *QB_NONNULL_S request, QBResponse *QB_NONNULL_S response, NSDictionary QB_GENERIC(NSString *, id) *QB_NULLABLE_S objects);

typedef void (^QBRequestErrorBlock)(QBResponse *QB_NONNULL_S response);

/** QBRequest class declaration  */
/** Overview:*/
/** This class represents all requests to Quickblox API. */

@interface QBRequest : NSObject

/** Determines if NSURLSessionTask was canceled */
@property (nonatomic, getter=isCancelled, readonly) BOOL canceled;

/** Formed NSURLSessionTask with request information */
@property (nonatomic, weak, QB_NULLABLE_PROPERTY) NSURLSessionTask* task;

/** Formed task type */
@property (nonatomic, assign, readonly) QBRequestTaskType taskType;

/** Request completion block */
@property (nonatomic, copy, QB_NULLABLE_PROPERTY) QBRequestCompletionBlock completionBlock;

/** Request update block */
@property (nonatomic, copy, QB_NULLABLE_PROPERTY) QBRequestStatusUpdateBlock updateBlock;

/** Request serialiser */
@property (nonatomic, strong, QB_NULLABLE_PROPERTY) QBHTTPRequestSerializer <QBRequestSerialisationProtocol> *requestSerialisator;

/** Response serialiser (QBHTTPResponseSerializer<QBResponseSerializationProtocol>) */
@property (nonatomic, strong, QB_NULLABLE_PROPERTY) NSArray QB_GENERIC(__kindof id<QBResponseSerializationProtocol>) *responseSerialisators;

/** Request headers */
@property (nonatomic, copy, QB_NULLABLE_PROPERTY) NSDictionary QB_GENERIC(NSString *, NSString *) *headers;

/** Request body */
@property (nonatomic, copy, QB_NULLABLE_PROPERTY) NSData *body;

/** Request encoding */
@property (nonatomic) NSStringEncoding encoding;

/** Request parameters */
@property (nonatomic, copy, readonly, QB_NULLABLE_PROPERTY) NSDictionary QB_GENERIC(NSString *, NSString *) *parameters;

/** Parameters methods */
- (void)addParametersFromDictionary:(QB_NULLABLE NSDictionary QB_GENERIC(NSString *, NSString *) *)otherDictionary;
- (void)addParameter:(QB_NONNULL id)obj forKey:(QB_NONNULL NSString *)key;
- (void)removeParameterForKey:(QB_NULLABLE NSString *)key;
- (void)extractParametersFromDictionary:(QB_NULLABLE NSDictionary QB_GENERIC(NSString *, NSString *) *)parameters;

/** Constructors */
+ (QB_NONNULL instancetype)new NS_UNAVAILABLE;

- (QB_NULLABLE instancetype)initWithType:(QBRequestTaskType)type completionBlock:(QB_NULLABLE QBRequestCompletionBlock)completionBlock;
- (QB_NULLABLE instancetype)initWithType:(QBRequestTaskType)type updateBlock:(QB_NULLABLE QBRequestStatusUpdateBlock)updateBlock completionBlock:(QB_NULLABLE QBRequestCompletionBlock)completionBlock;

/**
 *  Cancels NSURLSessionTask associated with request.
 */
- (void)cancel;

@end