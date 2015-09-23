// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CDMessage.h instead.

#import <CoreData/CoreData.h>

extern const struct CDMessageAttributes {
	__unsafe_unretained NSString *createAt;
	__unsafe_unretained NSString *customParameters;
	__unsafe_unretained NSString *dateSend;
	__unsafe_unretained NSString *delayed;
	__unsafe_unretained NSString *deliveredIDs;
	__unsafe_unretained NSString *dialogID;
	__unsafe_unretained NSString *isRead;
	__unsafe_unretained NSString *messageID;
	__unsafe_unretained NSString *readIDs;
	__unsafe_unretained NSString *recipientID;
	__unsafe_unretained NSString *senderID;
	__unsafe_unretained NSString *senderNick;
	__unsafe_unretained NSString *text;
	__unsafe_unretained NSString *updateAt;
} CDMessageAttributes;

extern const struct CDMessageRelationships {
	__unsafe_unretained NSString *attachments;
	__unsafe_unretained NSString *dialog;
} CDMessageRelationships;

@class CDAttachment;
@class CDDialog;

@interface CDMessageID : NSManagedObjectID {}
@end

@interface _CDMessage : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) CDMessageID* objectID;

@property (nonatomic, strong) NSDate* createAt;

//- (BOOL)validateCreateAt:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSData* customParameters;

//- (BOOL)validateCustomParameters:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* dateSend;

//- (BOOL)validateDateSend:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* delayed;

@property (atomic) BOOL delayedValue;
- (BOOL)delayedValue;
- (void)setDelayedValue:(BOOL)value_;

//- (BOOL)validateDelayed:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSData* deliveredIDs;

//- (BOOL)validateDeliveredIDs:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* dialogID;

//- (BOOL)validateDialogID:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* isRead;

@property (atomic) BOOL isReadValue;
- (BOOL)isReadValue;
- (void)setIsReadValue:(BOOL)value_;

//- (BOOL)validateIsRead:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* messageID;

//- (BOOL)validateMessageID:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSData* readIDs;

//- (BOOL)validateReadIDs:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* recipientID;

@property (atomic) int32_t recipientIDValue;
- (int32_t)recipientIDValue;
- (void)setRecipientIDValue:(int32_t)value_;

//- (BOOL)validateRecipientID:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* senderID;

@property (atomic) int32_t senderIDValue;
- (int32_t)senderIDValue;
- (void)setSenderIDValue:(int32_t)value_;

//- (BOOL)validateSenderID:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* senderNick;

//- (BOOL)validateSenderNick:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* text;

//- (BOOL)validateText:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* updateAt;

//- (BOOL)validateUpdateAt:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet *attachments;

- (NSMutableSet*)attachmentsSet;

@property (nonatomic, strong) CDDialog *dialog;

//- (BOOL)validateDialog:(id*)value_ error:(NSError**)error_;

@end

@interface _CDMessage (AttachmentsCoreDataGeneratedAccessors)
- (void)addAttachments:(NSSet*)value_;
- (void)removeAttachments:(NSSet*)value_;
- (void)addAttachmentsObject:(CDAttachment*)value_;
- (void)removeAttachmentsObject:(CDAttachment*)value_;

@end

@interface _CDMessage (CoreDataGeneratedPrimitiveAccessors)

- (NSDate*)primitiveCreateAt;
- (void)setPrimitiveCreateAt:(NSDate*)value;

- (NSData*)primitiveCustomParameters;
- (void)setPrimitiveCustomParameters:(NSData*)value;

- (NSDate*)primitiveDateSend;
- (void)setPrimitiveDateSend:(NSDate*)value;

- (NSNumber*)primitiveDelayed;
- (void)setPrimitiveDelayed:(NSNumber*)value;

- (BOOL)primitiveDelayedValue;
- (void)setPrimitiveDelayedValue:(BOOL)value_;

- (NSData*)primitiveDeliveredIDs;
- (void)setPrimitiveDeliveredIDs:(NSData*)value;

- (NSString*)primitiveDialogID;
- (void)setPrimitiveDialogID:(NSString*)value;

- (NSNumber*)primitiveIsRead;
- (void)setPrimitiveIsRead:(NSNumber*)value;

- (BOOL)primitiveIsReadValue;
- (void)setPrimitiveIsReadValue:(BOOL)value_;

- (NSString*)primitiveMessageID;
- (void)setPrimitiveMessageID:(NSString*)value;

- (NSData*)primitiveReadIDs;
- (void)setPrimitiveReadIDs:(NSData*)value;

- (NSNumber*)primitiveRecipientID;
- (void)setPrimitiveRecipientID:(NSNumber*)value;

- (int32_t)primitiveRecipientIDValue;
- (void)setPrimitiveRecipientIDValue:(int32_t)value_;

- (NSNumber*)primitiveSenderID;
- (void)setPrimitiveSenderID:(NSNumber*)value;

- (int32_t)primitiveSenderIDValue;
- (void)setPrimitiveSenderIDValue:(int32_t)value_;

- (NSString*)primitiveSenderNick;
- (void)setPrimitiveSenderNick:(NSString*)value;

- (NSString*)primitiveText;
- (void)setPrimitiveText:(NSString*)value;

- (NSDate*)primitiveUpdateAt;
- (void)setPrimitiveUpdateAt:(NSDate*)value;

- (NSMutableSet*)primitiveAttachments;
- (void)setPrimitiveAttachments:(NSMutableSet*)value;

- (CDDialog*)primitiveDialog;
- (void)setPrimitiveDialog:(CDDialog*)value;

@end
