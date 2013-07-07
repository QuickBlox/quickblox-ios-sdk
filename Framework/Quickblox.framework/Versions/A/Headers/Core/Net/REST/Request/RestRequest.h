//
//  RestRequest.h
//  Core
//
//

@interface RestRequest : NSObject<Cancelable>
{
	enum RestMethodKind method;
	NSURL *URL;
	NSDictionary *headers;
	NSDictionary *parameters;
	NSArray *files;
	NSData *body;
	NSObject<RestRequestDelegate>* delegate;
	ProgressDispatcher *uploadDispatcher;
	ProgressDispatcher *downloadDispatcher;
	NSRecursiveLock *canceledLock;
	NSObject<Cancelable>* canceler;
	BOOL isCanceled;
	enum RestRequestBuildStyle buildStyle;
	BOOL shouldRedirect;
    
    QBASIHTTPRequest* asirequest;
}

@property (nonatomic) enum RestMethodKind method;
@property(nonatomic, retain) NSObject<RestRequestDelegate>* delegate;
@property(nonatomic, retain) NSURL *URL;
@property(nonatomic, retain) NSDictionary *headers;
@property(nonatomic, retain) NSDictionary *parameters;
@property(nonatomic, retain) NSArray *files;
@property(nonatomic, retain) NSData *body;
@property(nonatomic, readonly) NSData* rawBody;
@property(nonatomic, readonly) NSData* rawBodyWithoutEncode;
@property(nonatomic, readonly) NSString* httpMethod;

@property(readonly) QBASIHTTPRequest* asirequestAsync;


@property(readonly) NSURL *finalURL;
@property(nonatomic, retain) ProgressDispatcher *uploadDispatcher;
@property(nonatomic, retain) ProgressDispatcher *downloadDispatcher;
@property(nonatomic, retain) NSRecursiveLock *canceledLock;
@property(nonatomic, retain) NSObject<Cancelable>* canceler;
@property(nonatomic) BOOL shouldRedirect;
@property(nonatomic) enum RestRequestBuildStyle buildStyle;


- (void)asyncRequestWithdelegate:(NSObject<RestRequestDelegate>*)delegate;

+ (NSString *)httpMethod:(enum RestMethodKind)method;
- (void)setMultipartParts:(QBASIFormDataRequest*)asireq;

@end
