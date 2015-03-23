#if TARGET_OS_IPHONE

#import "QBDDXMLNode.h"
#import "QBDDXMLElement.h"
#import "QBDDXMLDocument.h"

#ifndef NSXMLNode
  #define NSXMLNode QBDDXMLNode
#endif
#ifndef NSXMLElement
  #define NSXMLElement QBDDXMLElement
#endif
#ifndef NSXMLDocument
  #define NSXMLDocument QBDDXMLDocument
#endif

#ifndef NSXMLInvalidKind
  #define NSXMLInvalidKind DDXMLInvalidKind
#endif
#ifndef NSXMLDocumentKind
  #define NSXMLDocumentKind DDXMLDocumentKind
#endif
#ifndef NSXMLElementKind
  #define NSXMLElementKind QBDDXMLElementKind
#endif
#ifndef NSXMLAttributeKind
  #define NSXMLAttributeKind QBDDXMLAttributeKind
#endif
#ifndef NSXMLNamespaceKind
  #define NSXMLNamespaceKind QBDDXMLNamespaceKind
#endif
#ifndef NSXMLProcessingInstructionKind
  #define NSXMLProcessingInstructionKind DDXMLProcessingInstructionKind
#endif
#ifndef NSXMLCommentKind
  #define NSXMLCommentKind QBDDXMLCommentKind
#endif
#ifndef NSXMLTextKind
  #define NSXMLTextKind QBDDXMLTextKind
#endif
#ifndef NSXMLDTDKind
  #define NSXMLDTDKind QBDDXMLDTDKind
#endif
#ifndef NSXMLEntityDeclarationKind
  #define NSXMLEntityDeclarationKind QBDDXMLEntityDeclarationKind
#endif
#ifndef NSXMLAttributeDeclarationKind
  #define NSXMLAttributeDeclarationKind QBDDXMLAttributeDeclarationKind
#endif
#ifndef NSXMLElementDeclarationKind
  #define NSXMLElementDeclarationKind QBDDXMLElementDeclarationKind
#endif
#ifndef NSXMLNotationDeclarationKind
  #define NSXMLNotationDeclarationKind QBDDXMLNotationDeclarationKind
#endif

#ifndef NSXMLNodeOptionsNone
  #define NSXMLNodeOptionsNone QBDDXMLNodeOptionsNone
#endif
#ifndef NSXMLNodeExpandEmptyElement
  #define NSXMLNodeExpandEmptyElement QBDDXMLNodeExpandEmptyElement
#endif
#ifndef NSXMLNodeCompactEmptyElement
  #define NSXMLNodeCompactEmptyElement QBDDXMLNodeCompactEmptyElement
#endif
#ifndef NSXMLNodePrettyPrint
  #define NSXMLNodePrettyPrint QBDDXMLNodePrettyPrint
#endif

// KissXML has rather straight-forward memory management:
// http://code.google.com/p/kissxml/wiki/MemoryManagementThreadSafety
// 
// There are 3 important concepts to keep in mind when working with KissXML:
// 
// 
// 1.) KissXML provides a light-weight wrapper around libxml.
// 
// The parsing, creation, storage, etc of the xml tree is all done via libxml.
// This is a fast low-level C library that's been around for ages, and comes pre-installed on Mac OS X and iOS.
// KissXML provides an easy-to-use Objective-C library atop libxml.
// So a QBDDXMLNode, QBDDXMLElement, or QBDDXMLDocument are simply objective-c objects
// with pointers to the underlying libxml C structure.
// Then only time you need to be aware of any of this is when it comes to equality.
// In order to maximize speed and provide read-access thread-safety,
// the library may create multiple DDXML wrapper objects that point to the same underlying xml node.
// So don't assume you can test for equality with "==".
// Instead use the isEqual method (as you should generally do with objects anyway).
// 
// 
// 2.) XML is implicitly a tree heirarchy, and the XML API's are designed to allow traversal up & down the tree.
// 
// The tree heirarchy and API contract have an implicit impact concerning memory management.
// 
// <starbucks>
//   <latte/>
// </starbucks>
// 
// Imagine you have a QBDDXMLNode corresponding to the starbucks node,
// and you have a QBDDXMLNode corresponding to the latte node.
// Now imagine you release the starbucks node, but you retain a reference to the latte node.
// What happens?
// Well the latte node is a part of the xml tree heirarchy.
// So if the latte node is still around, the xml tree heirarchy must stick around as well.
// So even though the QBDDXMLNode corresponding to the starbucks node may get deallocated,
// the underlying xml tree structure won't be freed until the latte node gets dealloacated.
// 
// In general, this means that KissXML remains thread-safe when reading and processing a tree.
// If you traverse a tree and fork off asynchronous tasks to process subnodes,
// the tree will remain properly in place until all your asynchronous tasks have completed.
// In other words, it just works.
// 
// However, if you parse a huge document into memory, and retain a single node from the giant xml tree...
// Well you should see the problem this creates.
// Instead, in this situation, copy or detach the node if you want to keep it around.
// Or just extract the info you need from it.
// 
// 
// 3.) KissXML is read-access thread-safe, but write-access thread-unsafe (designed for speed).
// 
// <starbucks>
//   <latte/>
// </starbucks>
// 
// Imagine you have a QBDDXMLNode corresponding to the starbucks node,
// and you have a QBDDXMLNode corresponding to the latte node.
// What happens if you invoke [starbucks removeChildAtIndex:0]?
// Well the undelying xml tree will remove the latte node, and release the associated memory.
// And what if you still have a reference to the QBDDXMLNode that corresponds to the latte node?
// Well the short answer is that you shouldn't use it. At all.
// This is pretty obvious when you think about it from the context of this simple example.
// But in the real world, you might have multiple threads running in parallel,
// and you might accidently modify a node while another thread is processing it.
// 
// To completely fix this problem, and provide write-access thread-safety, would require extensive overhead.
// This overhead is completely unwanted in the majority of cases.
// Most XML usage patterns are heavily read-only.
// And in the case of xml creation or modification, it is generally done on the same thread.
// Thus the KissXML library is write-access thread-unsafe, but provides speedier performance.
// 
// However, when such a bug does creep up, it produces horrible side-effects.
// Essentially the pointer to the underlying xml structure becomes a dangling pointer,
// which means that accessing the dangling pointer might give you the correct results, or completely random results.
// And attempting to make modifications to non-existant xml nodes via the dangling pointer might do nothing,
// or completely corrupt your heap and cause un-explainable crashes in random parts of your library.
// Heap corruption is one of the worst problems to track down.
// So to help out, the library provides a debugging macro to track down these problems.
// That is, if you invalidate the write-access thread-unsafe rule,
// this macro will tell you when you're trying to access a no-dangling pointer.
// 
// How does it work?
// Well everytime a DDXML wrapper object is created atop a libxml structure,
// it marks the linkage in a table.
// And everytime a libxml structure is freed, it destorys all corresponding linkages in the table.
// So everytime a DDXML wrapper objects is about to dereference it's pointer,
// it first ensures the linkage still exists in the table.
// 
// The debugging macro adds a significant amount of overhead, and shouldn't be enabled on production builds.

#if DEBUG
  #define DDXML_DEBUG_MEMORY_ISSUES 0
#else
  #define DDXML_DEBUG_MEMORY_ISSUES 0 // Don't change me!
#endif

#endif