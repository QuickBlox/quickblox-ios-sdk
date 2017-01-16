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
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
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

- (NSNumber*)primitiveBlobID;
- (void)setPrimitiveBlobID:(NSNumber*)value;

- (int32_t)primitiveBlobIDValue;
- (void)setPrimitiveBlobIDValue:(int32_t)value_;

- (NSDate*)primitiveCreatedAt;
- (void)setPrimitiveCreatedAt:(NSDate*)value;

- (NSString*)primitiveCustomData;
- (void)setPrimitiveCustomData:(NSString*)value;

- (NSString*)primitiveEmail;
- (void)setPrimitiveEmail:(NSString*)value;

- (NSNumber*)primitiveExternalUserID;
- (void)setPrimitiveExternalUserID:(NSNumber*)value;

- (int32_t)primitiveExternalUserIDValue;
- (void)setPrimitiveExternalUserIDValue:(int32_t)value_;

- (NSString*)primitiveFacebookID;
- (void)setPrimitiveFacebookID:(NSString*)value;

- (NSString*)primitiveFullName;
- (void)setPrimitiveFullName:(NSString*)value;

- (NSNumber*)primitiveId;
- (void)setPrimitiveId:(NSNumber*)value;

- (int32_t)primitiveIdValue;
- (void)setPrimitiveIdValue:(int32_t)value_;

- (NSDate*)primitiveLastRequestAt;
- (void)setPrimitiveLastRequestAt:(NSDate*)value;

- (NSString*)primitiveLogin;
- (void)setPrimitiveLogin:(NSString*)value;

- (NSString*)primitivePhone;
- (void)setPrimitivePhone:(NSString*)value;

- (NSString*)primitiveTags;
- (void)setPrimitiveTags:(NSString*)value;

- (NSString*)primitiveTwitterID;
- (void)setPrimitiveTwitterID:(NSString*)value;

- (NSDate*)primitiveUpdatedAt;
- (void)setPrimitiveUpdatedAt:(NSDate*)value;

- (NSString*)primitiveWebsite;
- (void)setPrimitiveWebsite:(NSString*)value;

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
