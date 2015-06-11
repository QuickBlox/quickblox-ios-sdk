//
//  RestResponse.h
//  Core
//
//

#import "QBCoreEnums.h"

@class QBAFHTTPRequestOperation;

@interface QBRestResponse : NSObject

@property (readonly) id responseObject;
@property (readonly) NSString *responseObjectAsString;
@property (readonly) id AFHTTPRequestOperation;
@property (readonly) NSError *error;
@property (readonly) NSUInteger status;
@property (readonly) NSDictionary *headers;
@property (readonly) enum RestResponseType responseType;
@property (readonly) NSString *contentType;
@property (readonly) NSStringEncoding encoding;

- (id)initWithResponseObject:(id)responseObject AFHTTPRequestOperation:(QBAFHTTPRequestOperation *)AFHTTPRequestOperation error:(NSError *)error;

@end
