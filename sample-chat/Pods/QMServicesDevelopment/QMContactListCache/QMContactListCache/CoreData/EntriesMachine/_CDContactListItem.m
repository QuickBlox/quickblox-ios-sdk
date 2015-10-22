// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CDContactListItem.m instead.

#import "_CDContactListItem.h"

const struct CDContactListItemAttributes CDContactListItemAttributes = {
	.subscriptionState = @"subscriptionState",
	.userID = @"userID",
};

@implementation CDContactListItemID
@end

@implementation _CDContactListItem

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"CDContactListItem" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"CDContactListItem";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"CDContactListItem" inManagedObjectContext:moc_];
}

- (CDContactListItemID*)objectID {
	return (CDContactListItemID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"subscriptionStateValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"subscriptionState"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"userIDValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"userID"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic subscriptionState;

- (int16_t)subscriptionStateValue {
	NSNumber *result = [self subscriptionState];
	return [result shortValue];
}

- (void)setSubscriptionStateValue:(int16_t)value_ {
	[self setSubscriptionState:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveSubscriptionStateValue {
	NSNumber *result = [self primitiveSubscriptionState];
	return [result shortValue];
}

- (void)setPrimitiveSubscriptionStateValue:(int16_t)value_ {
	[self setPrimitiveSubscriptionState:[NSNumber numberWithShort:value_]];
}

@dynamic userID;

- (int32_t)userIDValue {
	NSNumber *result = [self userID];
	return [result intValue];
}

- (void)setUserIDValue:(int32_t)value_ {
	[self setUserID:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveUserIDValue {
	NSNumber *result = [self primitiveUserID];
	return [result intValue];
}

- (void)setPrimitiveUserIDValue:(int32_t)value_ {
	[self setPrimitiveUserID:[NSNumber numberWithInt:value_]];
}

@end

