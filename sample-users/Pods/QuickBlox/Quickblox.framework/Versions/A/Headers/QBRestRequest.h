//
//  QBRestRequest.h
//  Core
//
//

#import "QBCoreEnums.h"
#import "QBCoreDelegates.h"

@interface QBRestRequest : NSObject<Cancelable>
{
	enum RestMethodKind method;
	NSURL *URL;
	NSDictionary *headers;
	NSDictionary *parameters;
	NSArray *files;
	NSObject<RestRequestDelegate>* delegate;
	NSRecursiveLock *canceledLock;
	NSObject<Cancelable>* canceler;
	BOOL isCanceled;
	enum RestRequestBuildStyle buildStyle;
}

@property (nonatomic) enum RestMethodKind method;
@property (nonatomic, retain) NSObject<RestRequestDelegate>* delegate;
@property (nonatomic, retain) NSURL *URL;
@property (nonatomic, retain) NSDictionary *headers;
@property (nonatomic, retain) NSDictionary *parameters;
@property (nonatomic, retain) NSArray *files;
@property (nonatomic, readonly) NSData *rawBodyWithoutEncode;
@property (nonatomic, readonly) NSString *httpMethod;
@property (readonly) NSString *finalURL;
@property (nonatomic, retain) NSRecursiveLock *canceledLock;
@property (nonatomic, retain) NSObject<Cancelable>* canceler;
@property (nonatomic) enum RestRequestBuildStyle buildStyle;

- (void)asyncRequestWithdelegate:(NSObject<RestRequestDelegate> *)delegate;
+ (NSString *)httpMethod:(enum RestMethodKind)method;

@end
