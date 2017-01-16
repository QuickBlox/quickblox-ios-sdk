// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CDContactListItem.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface CDContactListItemID : NSManagedObjectID {}
@end

@interface _CDContactListItem : NSManagedObject
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) CDContactListItemID *objectID;

@property (nonatomic, strong, nullable) NSNumber* subscriptionState;

@property (atomic) int16_t subscriptionStateValue;
- (int16_t)subscriptionStateValue;
- (void)setSubscriptionStateValue:(int16_t)value_;

@property (nonatomic, strong, nullable) NSNumber* userID;

@property (atomic) int32_t userIDValue;
- (int32_t)userIDValue;
- (void)setUserIDValue:(int32_t)value_;

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

@interface CDContactListItemAttributes: NSObject 
+ (NSString *)subscriptionState;
+ (NSString *)userID;
@end

NS_ASSUME_NONNULL_END
