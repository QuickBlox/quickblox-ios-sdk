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

@protocol QBResponseSerialisationProtocol;
@protocol QBRequestSerialisationProtocol;
@class QBHTTPRequestSerialiser;

extern const struct QBRequestMethod {
    __unsafe_unretained NSString *QB_NONNULL_S POST;
    __unsafe_unretained NSString *QB_NONNULL_S GET;
    __unsafe_unretained NSString *QB_NONNULL_S HEAD;
    __unsafe_unretained NSString *QB_NONNULL_S PUT;
    __unsafe_unretained NSString *QB_NONNULL_S DELETE;
} QBRequestMethod;

typedef void (^QBRequestStatusUpdateBlock)(QBRequest *QB_NONNULL_S request, QBRequestStatus *QB_NULLABLE_S status);
typedef void (^QBRequestCompletionBlock)(QBRequest *QB_NONNULL_S request, QBResponse *QB_NONNULL_S response, NSDictionary QB_GENERIC(NSString *, id) *QB_NULLABLE_S objects);

typedef void (^QBRequestErrorBlock)(QBResponse *QB_NONNULL_S response);


@interface QBRequest : NSObject

@property (nonatomic, getter=isCancelled, readonly) BOOL canceled;
@property (nonatomic, weak, QB_NULLABLE_PROPERTY) NSOperation *operation;
@property (nonatomic, copy, QB_NULLABLE_PROPERTY) QBRequestCompletionBlock completionBlock;
@property (nonatomic, copy, QB_NULLABLE_PROPERTY) QBRequestStatusUpdateBlock updateBlock;

@property (nonatomic, strong, QB_NULLABLE_PROPERTY) QBHTTPRequestSerialiser<QBRequestSerialisationProtocol> *requestSerialisator;

// QBHTTPResponseSerialiser<QBResponseSerialisationProtocol>
@property (nonatomic, strong, QB_NULLABLE_PROPERTY) NSArray QB_GENERIC(__kindof id<QBResponseSerialisationProtocol>) *responseSerialisators;

@property (nonatomic, copy, QB_NULLABLE_PROPERTY) NSDictionary QB_GENERIC(NSString *, NSString *) *headers;
@property (nonatomic, copy, QB_NULLABLE_PROPERTY) NSData *body;
@property (nonatomic) NSStringEncoding encoding;

@property (nonatomic, copy, readonly, QB_NULLABLE_PROPERTY) NSDictionary QB_GENERIC(NSString *, NSString *) *parameters;

- (void)addParametersFromDictionary:(QB_NULLABLE NSDictionary QB_GENERIC(NSString *, NSString *) *)otherDictionary;
- (void)addParameter:(QB_NONNULL id)obj forKey:(QB_NONNULL NSString *)key;
- (void)removeParameterForKey:(QB_NULLABLE NSString *)key;
- (void)extractParametersFromDictionary:(QB_NULLABLE NSDictionary QB_GENERIC(NSString *, NSString *) *)parameters;

- (QB_NONNULL instancetype)initWithCompletionBlock:(QB_NULLABLE QBRequestCompletionBlock)completionBlock;
- (QB_NONNULL instancetype)initWithUpdateBlock:(QB_NULLABLE QBRequestStatusUpdateBlock)updateBlock completionBlock:(QB_NULLABLE QBRequestCompletionBlock)completionBlock;

- (void)cancel;

@end