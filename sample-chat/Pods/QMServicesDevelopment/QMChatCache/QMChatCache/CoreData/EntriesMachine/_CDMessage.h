// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CDMessage.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@class CDAttachment;
@class CDDialog;

@interface CDMessageID : NSManagedObjectID {}
@end

@interface _CDMessage : NSManagedObject
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (nullable NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) CDMessageID *objectID;

@property (nonatomic, strong, nullable) NSDate* createAt;

@property (nonatomic, strong, nullable) NSData* customParameters;

@property (nonatomic, strong, nullable) NSDate* dateSend;

@property (nonatomic, strong, nullable) NSNumber* delayed;

@property (atomic) BOOL delayedValue;
- (BOOL)delayedValue;
- (void)setDelayedValue:(BOOL)value_;

@property (nonatomic, strong, nullable) NSData* deliveredIDs;

@property (nonatomic, strong, nullable) NSString* dialogID;

@property (nonatomic, strong, nullable) NSString* messageID;

@property (nonatomic, strong, nullable) NSData* readIDs;

@property (nonatomic, strong, nullable) NSNumber* recipientID;

@property (atomic) int32_t recipientIDValue;
- (int32_t)recipientIDValue;
- (void)setRecipientIDValue:(int32_t)value_;

@property (nonatomic, strong, nullable) NSNumber* senderID;

@property (atomic) int32_t senderIDValue;
- (int32_t)senderIDValue;
- (void)setSenderIDValue:(int32_t)value_;

@property (nonatomic, strong, nullable) NSString* senderNick;

@property (nonatomic, strong, nullable) NSString* text;

@property (nonatomic, strong, nullable) NSDate* updateAt;

@property (nonatomic, strong, nullable) NSSet<CDAttachment*> *attachments;
- (nullable NSMutableSet<CDAttachment*>*)attachmentsSet;

@property (nonatomic, strong, nullable) CDDialog *dialog;

@end

@interface _CDMessage (AttachmentsCoreDataGeneratedAccessors)
- (void)addAttachments:(NSSet<CDAttachment*>*)value_;
- (void)removeAttachments:(NSSet<CDAttachment*>*)value_;
- (void)addAttachmentsObject:(CDAttachment*)value_;
- (void)removeAttachmentsObject:(CDAttachment*)value_;

@end

@interface _CDMessage (CoreDataGeneratedPrimitiveAccessors)

- (nullable NSDate*)primitiveCreateAt;
- (void)setPrimitiveCreateAt:(nullable NSDate*)value;

- (nullable NSData*)primitiveCustomParameters;
- (void)setPrimitiveCustomParameters:(nullable NSData*)value;

- (nullable NSDate*)primitiveDateSend;
- (void)setPrimitiveDateSend:(nullable NSDate*)value;

- (nullable NSNumber*)primitiveDelayed;
- (void)setPrimitiveDelayed:(nullable NSNumber*)value;

- (BOOL)primitiveDelayedValue;
- (void)setPrimitiveDelayedValue:(BOOL)value_;

- (nullable NSData*)primitiveDeliveredIDs;
- (void)setPrimitiveDeliveredIDs:(nullable NSData*)value;

- (nullable NSString*)primitiveDialogID;
- (void)setPrimitiveDialogID:(nullable NSString*)value;

- (nullable NSString*)primitiveMessageID;
- (void)setPrimitiveMessageID:(nullable NSString*)value;

- (nullable NSData*)primitiveReadIDs;
- (void)setPrimitiveReadIDs:(nullable NSData*)value;

- (nullable NSNumber*)primitiveRecipientID;
- (void)setPrimitiveRecipientID:(nullable NSNumber*)value;

- (int32_t)primitiveRecipientIDValue;
- (void)setPrimitiveRecipientIDValue:(int32_t)value_;

- (nullable NSNumber*)primitiveSenderID;
- (void)setPrimitiveSenderID:(nullable NSNumber*)value;

- (int32_t)primitiveSenderIDValue;
- (void)setPrimitiveSenderIDValue:(int32_t)value_;

- (nullable NSString*)primitiveSenderNick;
- (void)setPrimitiveSenderNick:(nullable NSString*)value;

- (nullable NSString*)primitiveText;
- (void)setPrimitiveText:(nullable NSString*)value;

- (nullable NSDate*)primitiveUpdateAt;
- (void)setPrimitiveUpdateAt:(nullable NSDate*)value;

- (NSMutableSet<CDAttachment*>*)primitiveAttachments;
- (void)setPrimitiveAttachments:(NSMutableSet<CDAttachment*>*)value;

- (CDDialog*)primitiveDialog;
- (void)setPrimitiveDialog:(CDDialog*)value;

@end

@interface CDMessageAttributes: NSObject 
+ (NSString *)createAt;
+ (NSString *)customParameters;
+ (NSString *)dateSend;
+ (NSString *)delayed;
+ (NSString *)deliveredIDs;
+ (NSString *)dialogID;
+ (NSString *)messageID;
+ (NSString *)readIDs;
+ (NSString *)recipientID;
+ (NSString *)senderID;
+ (NSString *)senderNick;
+ (NSString *)text;
+ (NSString *)updateAt;
@end

@interface CDMessageRelationships: NSObject
+ (NSString *)attachments;
+ (NSString *)dialog;
@end

NS_ASSUME_NONNULL_END
