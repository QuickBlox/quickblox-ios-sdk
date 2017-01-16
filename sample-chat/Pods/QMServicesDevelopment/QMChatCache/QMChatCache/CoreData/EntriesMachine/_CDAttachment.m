// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CDAttachment.m instead.

#import "_CDAttachment.h"

@implementation CDAttachmentID
@end

@implementation _CDAttachment

+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_ {
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

@dynamic data;

@dynamic id;

@dynamic mimeType;

@dynamic url;

@dynamic message;

@end

@implementation CDAttachmentAttributes 
+ (NSString *)data {
	return @"data";
}
+ (NSString *)id {
	return @"id";
}
+ (NSString *)mimeType {
	return @"mimeType";
}
+ (NSString *)url {
	return @"url";
}
@end

@implementation CDAttachmentRelationships 
+ (NSString *)message {
	return @"message";
}
@end

