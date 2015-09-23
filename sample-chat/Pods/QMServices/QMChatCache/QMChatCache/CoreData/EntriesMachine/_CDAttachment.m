// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CDAttachment.m instead.

#import "_CDAttachment.h"

const struct CDAttachmentAttributes CDAttachmentAttributes = {
	.id = @"id",
	.mimeType = @"mimeType",
	.url = @"url",
};

const struct CDAttachmentRelationships CDAttachmentRelationships = {
	.message = @"message",
};

@implementation CDAttachmentID
@end

@implementation _CDAttachment

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"CDAttachment" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"CDAttachment";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"CDAttachment" inManagedObjectContext:moc_];
}

- (CDAttachmentID*)objectID {
	return (CDAttachmentID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic id;

@dynamic mimeType;

@dynamic url;

@dynamic message;

@end

