#import <Foundation/Foundation.h>
#import "QBDDXMLNode.h"


@interface QBDDXMLElement : QBDDXMLNode
{
}

- (id)initWithName:(NSString *)name;
- (id)initWithName:(NSString *)name URI:(NSString *)URI;
- (id)initWithName:(NSString *)name stringValue:(NSString *)string;
- (id)initWithXMLString:(NSString *)string error:(NSError **)error;

#pragma mark --- Elements by name ---

- (NSArray *)elementsForName:(NSString *)name;
- (NSArray *)elementsForLocalName:(NSString *)localName URI:(NSString *)URI;

#pragma mark --- Attributes ---

- (void)addAttribute:(QBDDXMLNode *)attribute;
- (void)removeAttributeForName:(NSString *)name;
- (void)setAttributes:(NSArray *)attributes;
//- (void)setAttributesAsDictionary:(NSDictionary *)attributes;
- (NSArray *)attributes;
- (QBDDXMLNode *)attributeForName:(NSString *)name;
//- (QBDDXMLNode *)attributeForLocalName:(NSString *)localName URI:(NSString *)URI;

#pragma mark --- Namespaces ---

- (void)addNamespace:(QBDDXMLNode *)aNamespace;
- (void)removeNamespaceForPrefix:(NSString *)name;
- (void)setNamespaces:(NSArray *)namespaces;
- (NSArray *)namespaces;
- (QBDDXMLNode *)namespaceForPrefix:(NSString *)prefix;
- (QBDDXMLNode *)resolveNamespaceForName:(NSString *)name;
- (NSString *)resolvePrefixForNamespaceURI:(NSString *)namespaceURI;

#pragma mark --- Children ---

- (void)insertChild:(QBDDXMLNode *)child atIndex:(NSUInteger)index;
//- (void)insertChildren:(NSArray *)children atIndex:(NSUInteger)index;
- (void)removeChildAtIndex:(NSUInteger)index;
- (void)setChildren:(NSArray *)children;
- (void)addChild:(QBDDXMLNode *)child;
//- (void)replaceChildAtIndex:(NSUInteger)index withNode:(QBDDXMLNode *)node;
//- (void)normalizeAdjacentTextNodesPreservingCDATA:(BOOL)preserve;

@end
