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

@interface QBQuery : NSObject<Perform,RestRequestDelegate,Cancelable, QBActionStatusDelegate>
{
	NSObject<QBActionStatusDelegate> *delegate;
	NSObject<Cancelable> *canceler;
	BOOL isCanceled;
	NSRecursiveLock *canceledLock;
	id context;
	enum RestRequestBuildStyle requestBuildStyle;
}
@property (nonatomic,retain) NSObject<QBActionStatusDelegate> *delegate;
@property (nonatomic,retain) NSObject<Cancelable> *canceler;
@property (nonatomic,retain) NSRecursiveLock *canceledLock;
@property (nonatomic,retain) id context;
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
