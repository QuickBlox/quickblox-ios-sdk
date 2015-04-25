#import <Foundation/Foundation.h>
#import "QBDDXMLElement.h"
#import "QBDDXMLNode.h"


enum {
	DDXMLDocumentXMLKind = 0,
	DDXMLDocumentXHTMLKind,
	DDXMLDocumentHTMLKind,
	DDXMLDocumentTextKind
};
typedef NSUInteger DDXMLDocumentContentKind;

@interface QBDDXMLDocument : QBDDXMLNode
{
}

- (id)initWithXMLString:(NSString *)string options:(NSUInteger)mask error:(NSError **)error;
//- (id)initWithContentsOfURL:(NSURL *)url options:(NSUInteger)mask error:(NSError **)error;
- (id)initWithData:(NSData *)data options:(NSUInteger)mask error:(NSError **)error;
//- (id)initWithRootElement:(QBDDXMLElement *)element;

//+ (Class)replacementClassForClass:(Class)cls;

//- (void)setCharacterEncoding:(NSString *)encoding; //primitive
//- (NSString *)characterEncoding; //primitive

//- (void)setVersion:(NSString *)version;
//- (NSString *)version;

//- (void)setStandalone:(BOOL)standalone;
//- (BOOL)isStandalone;

//- (void)setDocumentContentKind:(DDXMLDocumentContentKind)kind;
//- (DDXMLDocumentContentKind)documentContentKind;

//- (void)setMIMEType:(NSString *)MIMEType;
//- (NSString *)MIMEType;

//- (void)setDTD:(DDXMLDTD *)documentTypeDeclaration;
//- (DDXMLDTD *)DTD;

//- (void)setRootElement:(QBDDXMLNode *)root;
- (QBDDXMLElement *)rootElement;

//- (void)insertChild:(QBDDXMLNode *)child atIndex:(NSUInteger)index;

//- (void)insertChildren:(NSArray *)children atIndex:(NSUInteger)index;

//- (void)removeChildAtIndex:(NSUInteger)index;

//- (void)setChildren:(NSArray *)children;

//- (void)addChild:(QBDDXMLNode *)child;

//- (void)replaceChildAtIndex:(NSUInteger)index withNode:(QBDDXMLNode *)node;

- (NSData *)XMLData;
- (NSData *)XMLDataWithOptions:(NSUInteger)options;

//- (id)objectByApplyingXSLT:(NSData *)xslt arguments:(NSDictionary *)arguments error:(NSError **)error;
//- (id)objectByApplyingXSLTString:(NSString *)xslt arguments:(NSDictionary *)arguments error:(NSError **)error;
//- (id)objectByApplyingXSLTAtURL:(NSURL *)xsltURL arguments:(NSDictionary *)argument error:(NSError **)error;

//- (BOOL)validateAndReturnError:(NSError **)error;

@end
