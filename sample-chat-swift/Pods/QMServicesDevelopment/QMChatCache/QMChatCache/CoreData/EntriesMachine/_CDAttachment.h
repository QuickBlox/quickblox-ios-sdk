// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CDAttachment.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@class CDMessage;

@interface CDAttachmentID : NSManagedObjectID {}
@end

@interface _CDAttachment : NSManagedObject
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (nullable NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) CDAttachmentID *objectID;

@property (nonatomic, strong, nullable) NSData* customParameters;

@property (nonatomic, strong, nullable) NSString* data;

@property (nonatomic, strong, nullable) NSString* id;

@property (nonatomic, strong, nullable) NSString* mimeType;

@property (nonatomic, strong, nullable) NSString* name;

@property (nonatomic, strong, nullable) NSString* url;

@property (nonatomic, strong, nullable) CDMessage *message;

@end

@interface _CDAttachment (CoreDataGeneratedPrimitiveAccessors)

- (nullable NSData*)primitiveCustomParameters;
- (void)setPrimitiveCustomParameters:(nullable NSData*)value;

- (nullable NSString*)primitiveData;
- (void)setPrimitiveData:(nullable NSString*)value;

- (nullable NSString*)primitiveId;
- (void)setPrimitiveId:(nullable NSString*)value;

- (nullable NSString*)primitiveMimeType;
- (void)setPrimitiveMimeType:(nullable NSString*)value;

- (nullable NSString*)primitiveName;
- (void)setPrimitiveName:(nullable NSString*)value;

- (nullable NSString*)primitiveUrl;
- (void)setPrimitiveUrl:(nullable NSString*)value;

- (CDMessage*)primitiveMessage;
- (void)setPrimitiveMessage:(CDMessage*)value;

@end

@interface CDAttachmentAttributes: NSObject 
+ (NSString *)customParameters;
+ (NSString *)data;
+ (NSString *)id;
+ (NSString *)mimeType;
+ (NSString *)name;
+ (NSString *)url;
@end

@interface CDAttachmentRelationships: NSObject
+ (NSString *)message;
@end

NS_ASSUME_NONNULL_END
