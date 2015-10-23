// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CDUser.m instead.

#import "_CDUser.h"

const struct CDUserAttributes CDUserAttributes = {
	.blobID = @"blobID",
	.createdAt = @"createdAt",
	.customData = @"customData",
	.email = @"email",
	.externalUserID = @"externalUserID",
	.facebookID = @"facebookID",
	.fullName = @"fullName",
	.id = @"id",
	.login = @"login",
	.phone = @"phone",
	.tags = @"tags",
	.twitterID = @"twitterID",
	.updatedAt = @"updatedAt",
	.website = @"website",
};

@implementation CDUserID
@end

@implementation _CDUser

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"CDUser" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"CDUser";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"CDUser" inManagedObjectContext:moc_];
}

- (CDUserID*)objectID {
	return (CDUserID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"blobIDValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"blobID"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"externalUserIDValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"externalUserID"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"idValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"id"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic blobID;

- (int32_t)blobIDValue {
	NSNumber *result = [self blobID];
	return [result intValue];
}

- (void)setBlobIDValue:(int32_t)value_ {
	[self setBlobID:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveBlobIDValue {
	NSNumber *result = [self primitiveBlobID];
	return [result intValue];
}

- (void)setPrimitiveBlobIDValue:(int32_t)value_ {
	[self setPrimitiveBlobID:[NSNumber numberWithInt:value_]];
}

@dynamic createdAt;

@dynamic customData;

@dynamic email;

@dynamic externalUserID;

- (int32_t)externalUserIDValue {
	NSNumber *result = [self externalUserID];
	return [result intValue];
}

- (void)setExternalUserIDValue:(int32_t)value_ {
	[self setExternalUserID:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveExternalUserIDValue {
	NSNumber *result = [self primitiveExternalUserID];
	return [result intValue];
}

- (void)setPrimitiveExternalUserIDValue:(int32_t)value_ {
	[self setPrimitiveExternalUserID:[NSNumber numberWithInt:value_]];
}

@dynamic facebookID;

@dynamic fullName;

@dynamic id;

- (int32_t)idValue {
	NSNumber *result = [self id];
	return [result intValue];
}

- (void)setIdValue:(int32_t)value_ {
	[self setId:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveIdValue {
	NSNumber *result = [self primitiveId];
	return [result intValue];
}

- (void)setPrimitiveIdValue:(int32_t)value_ {
	[self setPrimitiveId:[NSNumber numberWithInt:value_]];
}

@dynamic login;

@dynamic phone;

@dynamic tags;

@dynamic twitterID;

@dynamic updatedAt;

@dynamic website;

@end

