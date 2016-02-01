// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CDDialog.h instead.

#import <CoreData/CoreData.h>

extern const struct CDDialogAttributes {
	__unsafe_unretained NSString *dialogID;
	__unsafe_unretained NSString *dialogType;
	__unsafe_unretained NSString *lastMessageDate;
	__unsafe_unretained NSString *lastMessageText;
	__unsafe_unretained NSString *lastMessageUserID;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *occupantsIDs;
	__unsafe_unretained NSString *photo;
	__unsafe_unretained NSString *recipientID;
	__unsafe_unretained NSString *unreadMessagesCount;
	__unsafe_unretained NSString *updatedAt;
	__unsafe_unretained NSString *userID;
} CDDialogAttributes;

extern const struct CDDialogRelationships {
	__unsafe_unretained NSString *messages;
} CDDialogRelationships;

@class CDMessage;

@class NSObject;

@interface CDDialogID : NSManagedObjectID {}
@end

@interface _CDDialog : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) CDDialogID* objectID;

@property (nonatomic, strong) NSString* dialogID;

//- (BOOL)validateDialogID:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* dialogType;

@property (atomic) int16_t dialogTypeValue;
- (int16_t)dialogTypeValue;
- (void)setDialogTypeValue:(int16_t)value_;

//- (BOOL)validateDialogType:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* lastMessageDate;

//- (BOOL)validateLastMessageDate:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* lastMessageText;

//- (BOOL)validateLastMessageText:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* lastMessageUserID;

@property (atomic) int32_t lastMessageUserIDValue;
- (int32_t)lastMessageUserIDValue;
- (void)setLastMessageUserIDValue:(int32_t)value_;

//- (BOOL)validateLastMessageUserID:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) id occupantsIDs;

//- (BOOL)validateOccupantsIDs:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* photo;

//- (BOOL)validatePhoto:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* recipientID;

@property (atomic) int32_t recipientIDValue;
- (int32_t)recipientIDValue;
- (void)setRecipientIDValue:(int32_t)value_;

//- (BOOL)validateRecipientID:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* unreadMessagesCount;

@property (atomic) int32_t unreadMessagesCountValue;
- (int32_t)unreadMessagesCountValue;
- (void)setUnreadMessagesCountValue:(int32_t)value_;

//- (BOOL)validateUnreadMessagesCount:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* updatedAt;

//- (BOOL)validateUpdatedAt:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* userID;

@property (atomic) int32_t userIDValue;
- (int32_t)userIDValue;
- (void)setUserIDValue:(int32_t)value_;

//- (BOOL)validateUserID:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet *messages;

- (NSMutableSet*)messagesSet;

@end

@interface _CDDialog (MessagesCoreDataGeneratedAccessors)
- (void)addMessages:(NSSet*)value_;
- (void)removeMessages:(NSSet*)value_;
- (void)addMessagesObject:(CDMessage*)value_;
- (void)removeMessagesObject:(CDMessage*)value_;

@end

@interface _CDDialog (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveDialogID;
- (void)setPrimitiveDialogID:(NSString*)value;

- (NSNumber*)primitiveDialogType;
- (void)setPrimitiveDialogType:(NSNumber*)value;

- (int16_t)primitiveDialogTypeValue;
- (void)setPrimitiveDialogTypeValue:(int16_t)value_;

- (NSDate*)primitiveLastMessageDate;
- (void)setPrimitiveLastMessageDate:(NSDate*)value;

- (NSString*)primitiveLastMessageText;
- (void)setPrimitiveLastMessageText:(NSString*)value;

- (NSNumber*)primitiveLastMessageUserID;
- (void)setPrimitiveLastMessageUserID:(NSNumber*)value;

- (int32_t)primitiveLastMessageUserIDValue;
- (void)setPrimitiveLastMessageUserIDValue:(int32_t)value_;

- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;

- (id)primitiveOccupantsIDs;
- (void)setPrimitiveOccupantsIDs:(id)value;

- (NSString*)primitivePhoto;
- (void)setPrimitivePhoto:(NSString*)value;

- (NSNumber*)primitiveRecipientID;
- (void)setPrimitiveRecipientID:(NSNumber*)value;

- (int32_t)primitiveRecipientIDValue;
- (void)setPrimitiveRecipientIDValue:(int32_t)value_;

- (NSNumber*)primitiveUnreadMessagesCount;
- (void)setPrimitiveUnreadMessagesCount:(NSNumber*)value;

- (int32_t)primitiveUnreadMessagesCountValue;
- (void)setPrimitiveUnreadMessagesCountValue:(int32_t)value_;

- (NSDate*)primitiveUpdatedAt;
- (void)setPrimitiveUpdatedAt:(NSDate*)value;

- (NSNumber*)primitiveUserID;
- (void)setPrimitiveUserID:(NSNumber*)value;

- (int32_t)primitiveUserIDValue;
- (void)setPrimitiveUserIDValue:(int32_t)value_;

- (NSMutableSet*)primitiveMessages;
- (void)setPrimitiveMessages:(NSMutableSet*)value;

@end
