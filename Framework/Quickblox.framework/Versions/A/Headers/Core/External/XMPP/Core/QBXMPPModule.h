#import <Foundation/Foundation.h>
#import "QBGCDMulticastDelegate.h"

@class QBXMPPStream;

/**
 * XMPPModule is the base class that all extensions/modules inherit.
 * They automatically get:
 * 
 * - A dispatch queue.
 * - A multicast delegate that automatically invokes added delegates.
 * 
 * The module also automatically registers/unregisters itself with the
 * xmpp stream during the activate/deactive methods.
**/
@interface QBXMPPModule : NSObject
{
	QBXMPPStream *xmppStream;
	
	dispatch_queue_t moduleQueue;
	id multicastDelegate;
}

@property (readonly) dispatch_queue_t moduleQueue;
@property (readonly) QBXMPPStream *xmppStream;

- (id)init;
- (id)initWithDispatchQueue:(dispatch_queue_t)queue;

- (BOOL)activate:(QBXMPPStream *)xmppStream;
- (void)deactivate;

- (void)addDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue;
- (void)removeDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue;
- (void)removeDelegate:(id)delegate;

- (NSString *)moduleName;

@end
