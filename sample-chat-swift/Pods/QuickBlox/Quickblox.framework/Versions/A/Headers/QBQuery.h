#import "QBCoreEnums.h"
#import "QBCoreDelegates.h"

//
//  Query.h
//  Core
//
//
@class QBBaseModule;
@class QBRestRequest;
@class RestAnswer;
@protocol Cancelable;
@protocol QBActionStatusDelegate;

@interface QBQuery : NSObject<Perform,RestRequestDelegate,Cancelable, QBActionStatusDelegate> {
    
	BOOL isCanceled;
}

@property (nonatomic, strong) NSObject<QBActionStatusDelegate> *delegate;
@property (nonatomic, weak) NSObject<Cancelable> *canceler;
@property (nonatomic, strong) NSRecursiveLock *canceledLock;
@property (nonatomic, copy) id context;
@property (nonatomic) enum RestRequestBuildStyle requestBuildStyle;

- (RestAnswer *)allocAnswer;
- (NSString *)url;
- (void)finishedSuccess;

- (void)setupRequest:(QBRestRequest *)request;
- (void)setUrl:(QBRestRequest *)request;
- (void)setBody:(QBRestRequest *)request;
- (void)setParams:(QBRestRequest *)request;
- (void)setHeaders:(QBRestRequest *)request;
- (void)setMethod:(QBRestRequest *)request;
- (void)setFiles:(QBRestRequest *)request;

@end
