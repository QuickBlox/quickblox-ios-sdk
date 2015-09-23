// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CDContactListItem.h instead.

#import <CoreData/CoreData.h>

extern const struct CDContactListItemAttributes {
	__unsafe_unretained NSString *subscriptionState;
	__unsafe_unretained NSString *userID;
} CDContactListItemAttributes;

@interface CDContactListItemID : NSManagedObjectID {}
@end

@interface _CDContactListItem : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) CDContactListItemID* objectID;

@property (nonatomic, strong) NSNumber* subscriptionState;

@property (atomic) int16_t subscriptionStateValue;
- (int16_t)subscriptionStateValue;
- (void)setSubscriptionStateValue:(int16_t)value_;

//- (BOOL)validateSubscriptionState:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* userID;

@property (atomic) int32_t userIDValue;
- (int32_t)userIDValue;
- (void)setUserIDValue:(int32_t)value_;

//- (BOOL)validateUserID:(id*)value_ error:(NSError**)error_;

@end

@interface _CDContactListItem (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber*)primitiveSubscriptionState;
- (void)setPrimitiveSubscriptionState:(NSNumber*)value;

- (int16_t)primitiveSubscriptionStateValue;
- (void)setPrimitiveSubscriptionStateValue:(int16_t)value_;

- (NSNumber*)primitiveUserID;
- (void)setPrimitiveUserID:(NSNumber*)value;

- (int32_t)primitiveUserIDValue;
- (void)setPrimitiveUserIDValue:(int32_t)value_;

@end
