// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to QMCDAttachment.m instead.

#import "_QMCDAttachment.h"

@implementation QMCDAttachmentID
@end

@implementation _QMCDAttachment

+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"QMCDAttachment" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"QMCDAttachment";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"QMCDAttachment" inManagedObjectContext:moc_];
}

- (QMCDAttachmentID*)objectID {
	return (QMCDAttachmentID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic customParameters;

@dynamic data;

@dynamic id;

@dynamic mimeType;

@dynamic name;

@dynamic url;

@dynamic message;

@end

@implementation QMCDAttachmentAttributes 
+ (NSString *)customParameters {
	return @"customParameters";
}
+ (NSString *)data {
	return @"data";
}
+ (NSString *)id {
	return @"id";
}
+ (NSString *)mimeType {
	return @"mimeType";
}
+ (NSString *)name {
	return @"name";
}
+ (NSString *)url {
	return @"url";
}
@end

@implementation QMCDAttachmentRelationships 
+ (NSString *)message {
	return @"message";
}
@end

