#import <Foundation/Foundation.h>

enum QBXMPPJIDCompareOptions
{
	XMPPJIDCompareUser     = 1, // 001
	XMPPJIDCompareDomain   = 2, // 010
	XMPPJIDCompareResource = 4, // 100
	
	XMPPJIDCompareBare     = 3, // 011
	XMPPJIDCompareFull     = 7, // 111
};
typedef enum QBXMPPJIDCompareOptions XMPPJIDCompareOptions;


@interface QBXMPPJID : NSObject <NSCoding, NSCopying>
{
	NSString *user;
	NSString *domain;
	NSString *resource;
}

+ (QBXMPPJID *)jidWithString:(NSString *)jidStr;
+ (QBXMPPJID *)jidWithString:(NSString *)jidStr resource:(NSString *)resource;
+ (QBXMPPJID *)jidWithUser:(NSString *)user domain:(NSString *)domain resource:(NSString *)resource;

@property (readonly) NSString *user;
@property (readonly) NSString *domain;
@property (readonly) NSString *resource;

- (QBXMPPJID *)bareJID;
- (QBXMPPJID *)domainJID;

- (NSString *)bare;
- (NSString *)full;

- (BOOL)isBare;
- (BOOL)isBareWithUser;

- (BOOL)isFull;
- (BOOL)isFullWithUser;

- (BOOL)isServer;

/**
 * When you know both objects are JIDs, this method is a faster way to check equality than isEqual:.
**/
- (BOOL)isEqualToJID:(QBXMPPJID *)aJID;
- (BOOL)isEqualToJID:(QBXMPPJID *)aJID options:(XMPPJIDCompareOptions)mask;

@end
