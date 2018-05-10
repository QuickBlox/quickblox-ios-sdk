// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CDUser.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface CDUserID : NSManagedObjectID {}
@end

@interface _CDUser : NSManagedObject
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (nullable NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) CDUserID *objectID;

@property (nonatomic, strong, nullable) NSNumber* blobID;

@property (atomic) int32_t blobIDValue;
- (int32_t)blobIDValue;
- (void)setBlobIDValue:(int32_t)value_;

@property (nonatomic, strong, nullable) NSDate* createdAt;

@property (nonatomic, strong, nullable) NSString* customData;

@property (nonatomic, strong, nullable) NSString* email;

@property (nonatomic, strong, nullable) NSNumber* externalUserID;

@property (atomic) int32_t externalUserIDValue;
- (int32_t)externalUserIDValue;
- (void)setExternalUserIDValue:(int32_t)value_;

@property (nonatomic, strong, nullable) NSString* facebookID;

@property (nonatomic, strong, nullable) NSString* fullName;

@property (nonatomic, strong, nullable) NSNumber* id;

@property (atomic) int32_t idValue;
- (int32_t)idValue;
- (void)setIdValue:(int32_t)value_;

@property (nonatomic, strong, nullable) NSDate* lastRequestAt;

@property (nonatomic, strong, nullable) NSString* login;

@property (nonatomic, strong, nullable) NSString* phone;

@property (nonatomic, strong, nullable) NSString* tags;

@property (nonatomic, strong, nullable) NSString* twitterID;

@property (nonatomic, strong, nullable) NSDate* updatedAt;

@property (nonatomic, strong, nullable) NSString* website;

@end

@interface _CDUser (CoreDataGeneratedPrimitiveAccessors)

- (nullable NSNumber*)primitiveBlobID;
- (void)setPrimitiveBlobID:(nullable NSNumber*)value;

- (int32_t)primitiveBlobIDValue;
- (void)setPrimitiveBlobIDValue:(int32_t)value_;

- (nullable NSDate*)primitiveCreatedAt;
- (void)setPrimitiveCreatedAt:(nullable NSDate*)value;

- (nullable NSString*)primitiveCustomData;
- (void)setPrimitiveCustomData:(nullable NSString*)value;

- (nullable NSString*)primitiveEmail;
- (void)setPrimitiveEmail:(nullable NSString*)value;

- (nullable NSNumber*)primitiveExternalUserID;
- (void)setPrimitiveExternalUserID:(nullable NSNumber*)value;

- (int32_t)primitiveExternalUserIDValue;
- (void)setPrimitiveExternalUserIDValue:(int32_t)value_;

- (nullable NSString*)primitiveFacebookID;
- (void)setPrimitiveFacebookID:(nullable NSString*)value;

- (nullable NSString*)primitiveFullName;
- (void)setPrimitiveFullName:(nullable NSString*)value;

- (nullable NSNumber*)primitiveId;
- (void)setPrimitiveId:(nullable NSNumber*)value;

- (int32_t)primitiveIdValue;
- (void)setPrimitiveIdValue:(int32_t)value_;

- (nullable NSDate*)primitiveLastRequestAt;
- (void)setPrimitiveLastRequestAt:(nullable NSDate*)value;

- (nullable NSString*)primitiveLogin;
- (void)setPrimitiveLogin:(nullable NSString*)value;

- (nullable NSString*)primitivePhone;
- (void)setPrimitivePhone:(nullable NSString*)value;

- (nullable NSString*)primitiveTags;
- (void)setPrimitiveTags:(nullable NSString*)value;

- (nullable NSString*)primitiveTwitterID;
- (void)setPrimitiveTwitterID:(nullable NSString*)value;

- (nullable NSDate*)primitiveUpdatedAt;
- (void)setPrimitiveUpdatedAt:(nullable NSDate*)value;

- (nullable NSString*)primitiveWebsite;
- (void)setPrimitiveWebsite:(nullable NSString*)value;

@end

@interface CDUserAttributes: NSObject 
+ (NSString *)blobID;
+ (NSString *)createdAt;
+ (NSString *)customData;
+ (NSString *)email;
+ (NSString *)externalUserID;
+ (NSString *)facebookID;
+ (NSString *)fullName;
+ (NSString *)id;
+ (NSString *)lastRequestAt;
+ (NSString *)login;
+ (NSString *)phone;
+ (NSString *)tags;
+ (NSString *)twitterID;
+ (NSString *)updatedAt;
+ (NSString *)website;
@end

NS_ASSUME_NONNULL_END
