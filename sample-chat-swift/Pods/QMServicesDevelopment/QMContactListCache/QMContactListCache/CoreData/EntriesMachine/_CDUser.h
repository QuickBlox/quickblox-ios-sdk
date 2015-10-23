// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CDUser.h instead.

#import <CoreData/CoreData.h>

extern const struct CDUserAttributes {
	__unsafe_unretained NSString *blobID;
	__unsafe_unretained NSString *createdAt;
	__unsafe_unretained NSString *customData;
	__unsafe_unretained NSString *email;
	__unsafe_unretained NSString *externalUserID;
	__unsafe_unretained NSString *facebookID;
	__unsafe_unretained NSString *fullName;
	__unsafe_unretained NSString *id;
	__unsafe_unretained NSString *login;
	__unsafe_unretained NSString *phone;
	__unsafe_unretained NSString *tags;
	__unsafe_unretained NSString *twitterID;
	__unsafe_unretained NSString *updatedAt;
	__unsafe_unretained NSString *website;
} CDUserAttributes;

@interface CDUserID : NSManagedObjectID {}
@end

@interface _CDUser : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) CDUserID* objectID;

@property (nonatomic, strong) NSNumber* blobID;

@property (atomic) int32_t blobIDValue;
- (int32_t)blobIDValue;
- (void)setBlobIDValue:(int32_t)value_;

//- (BOOL)validateBlobID:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* createdAt;

//- (BOOL)validateCreatedAt:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* customData;

//- (BOOL)validateCustomData:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* email;

//- (BOOL)validateEmail:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* externalUserID;

@property (atomic) int32_t externalUserIDValue;
- (int32_t)externalUserIDValue;
- (void)setExternalUserIDValue:(int32_t)value_;

//- (BOOL)validateExternalUserID:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* facebookID;

//- (BOOL)validateFacebookID:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* fullName;

//- (BOOL)validateFullName:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* id;

@property (atomic) int32_t idValue;
- (int32_t)idValue;
- (void)setIdValue:(int32_t)value_;

//- (BOOL)validateId:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* login;

//- (BOOL)validateLogin:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* phone;

//- (BOOL)validatePhone:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* tags;

//- (BOOL)validateTags:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* twitterID;

//- (BOOL)validateTwitterID:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* updatedAt;

//- (BOOL)validateUpdatedAt:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* website;

//- (BOOL)validateWebsite:(id*)value_ error:(NSError**)error_;

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
