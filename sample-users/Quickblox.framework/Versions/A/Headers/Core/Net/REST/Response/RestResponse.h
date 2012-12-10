//
//  RestResponse.h
//  Core
//
//

@interface RestResponse : NSObject{
	NSDictionary *headers;
	NSData *body;
	NSError *error;
	QBASIHTTPRequest* asirequest;
}

@property (nonatomic, retain) NSDictionary *headers;
@property (nonatomic, retain) NSData *body;
@property (readonly) NSUInteger status;
@property (readonly) enum RestResponseType responseType;
@property (readonly) NSString* contentType;
@property (nonatomic, retain) NSError *error;
@property (readonly) QBASIHTTPRequest* asirequest;
@property (nonatomic,readonly) NSStringEncoding encoding;

-(id)initWithAsiRequest:(QBASIHTTPRequest*)_asirequest;
+(enum RestResponseType)getResponseType:(NSString *)mimeType;

@end
