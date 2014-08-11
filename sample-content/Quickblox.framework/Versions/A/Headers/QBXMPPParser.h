#import <Foundation/Foundation.h>
#import <libxml2/libxml/parser.h>

#if TARGET_OS_IPHONE
  #import "QBDDXML.h"
#endif


@interface QBXMPPParser : NSObject
{
	id delegate;
	
	BOOL hasReportedRoot;
	unsigned depth;
	
	xmlParserCtxt *parserCtxt;
}

- (id)initWithDelegate:(id)delegate;

- (id)delegate;
- (void)setDelegate:(id)delegate;

/**
 * Synchronously parses the given data.
 * This means the delegate methods will get called before this method returns.
**/
- (void)parseData:(NSData *)data;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@protocol QBXMPPParserDelegate
@optional

- (void)xmppParser:(QBXMPPParser *)sender didReadRoot:(NSXMLElement *)root;

- (void)xmppParser:(QBXMPPParser *)sender didReadElement:(NSXMLElement *)element;

- (void)xmppParserDidEnd:(QBXMPPParser *)sender;

- (void)xmppParser:(QBXMPPParser *)sender didFail:(NSError *)error;

@end
