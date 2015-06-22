//
// Created by Andrey Kozlov on 01/12/2013.
// Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QBRequest;
@class QBResponse;
@class QBRequestStatus;

@protocol QBResponseSerialisationProtocol;
@protocol QBRequestSerialisationProtocol;
@class QBHTTPRequestSerialiser;

extern const struct QBRequestMethod {
    __unsafe_unretained NSString *POST;
    __unsafe_unretained NSString *GET;
    __unsafe_unretained NSString *HEAD;
    __unsafe_unretained NSString *PUT;
    __unsafe_unretained NSString *DELETE;
} QBRequestMethod;

typedef void (^QBRequestStatusUpdateBlock)(QBRequest *request, QBRequestStatus *status);
typedef void (^QBRequestCompletionBlock)(QBRequest *request, QBResponse *response, NSDictionary *objects);

typedef void (^QBRequestErrorBlock)(QBResponse *response);


@interface QBRequest : NSObject

@property (nonatomic, getter=isCancelled, readonly) BOOL canceled;

@property (nonatomic, copy) QBRequestCompletionBlock completionBlock;
@property (nonatomic, copy) QBRequestStatusUpdateBlock updateBlock;

@property (nonatomic, strong) QBHTTPRequestSerialiser<QBRequestSerialisationProtocol> *requestSerialisator;

// QBHTTPResponseSerialiser<QBResponseSerialisationProtocol>
@property (nonatomic, strong) NSArray *responseSerialisators;

@property (nonatomic, copy) NSDictionary *headers;
@property (nonatomic, copy) NSDictionary *parameters;
@property (nonatomic, copy) NSData *body;

@property (nonatomic) NSStringEncoding encoding;

- (instancetype)initWithCompletionBlock:(QBRequestCompletionBlock)completionBlock;
- (instancetype)initWithUpdateBlock:(QBRequestStatusUpdateBlock)updateBlock completionBlock:(QBRequestCompletionBlock)completionBlock;

- (void)cancel;

@end