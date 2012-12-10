//
//  Query.h
//  Core
//
//
@class BaseService;
@interface Query : NSObject<Perform,RestRequestDelegate,Cancelable, QBActionStatusDelegate>
{
	NSObject<QBActionStatusDelegate>* delegate;
    
	NSObject<Cancelable>* canceler;
	BOOL isCanceled;
	NSRecursiveLock* canceledLock;
	id context;
	enum RestRequestBuildStyle requestBuildStyle;
}
@property (nonatomic,retain) NSObject<QBActionStatusDelegate>* delegate;
@property (nonatomic,retain) NSObject<Cancelable>* canceler;
@property (nonatomic,retain) NSRecursiveLock* canceledLock;
@property (nonatomic,retain) id context;
@property (nonatomic) enum RestRequestBuildStyle requestBuildStyle;

- (RestAnswer*)allocAnswer;

- (NSString*)url;
- (void)setupRequest:(RestRequest*)request;
- (void)setUrl:(RestRequest*)request;
- (void)setAuthentication:(RestRequest*)request;
- (void)setBody:(RestRequest*)request;
- (void)setParams:(RestRequest*)request;
- (void)setHeaders:(RestRequest*)request;
- (void)setMethod:(RestRequest*)request;
- (void)setFiles:(RestRequest*)request;
- (void)setShouldRedirect:(RestRequest*)request;
- (void)finishedSuccess;

@end
