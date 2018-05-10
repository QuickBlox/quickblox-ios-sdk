// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CDOpenGraphModel.m instead.

#import "_CDOpenGraphModel.h"

@implementation CDOpenGraphModelID
@end

@implementation _CDOpenGraphModel

+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"CDOpenGraphModel" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"CDOpenGraphModel";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"CDOpenGraphModel" inManagedObjectContext:moc_];
}

- (CDOpenGraphModelID*)objectID {
	return (CDOpenGraphModelID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"heightValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"height"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"widthValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"width"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic faviconURL;

@dynamic height;

- (int16_t)heightValue {
	NSNumber *result = [self height];
	return [result shortValue];
}

- (void)setHeightValue:(int16_t)value_ {
	[self setHeight:@(value_)];
}

- (int16_t)primitiveHeightValue {
	NSNumber *result = [self primitiveHeight];
	return [result shortValue];
}

- (void)setPrimitiveHeightValue:(int16_t)value_ {
	[self setPrimitiveHeight:@(value_)];
}

@dynamic id;

@dynamic imageURL;

@dynamic siteDescription;

@dynamic title;

@dynamic url;

@dynamic width;

- (int16_t)widthValue {
	NSNumber *result = [self width];
	return [result shortValue];
}

- (void)setWidthValue:(int16_t)value_ {
	[self setWidth:@(value_)];
}

- (int16_t)primitiveWidthValue {
	NSNumber *result = [self primitiveWidth];
	return [result shortValue];
}

- (void)setPrimitiveWidthValue:(int16_t)value_ {
	[self setPrimitiveWidth:@(value_)];
}

@end

@implementation CDOpenGraphModelAttributes 
+ (NSString *)faviconURL {
	return @"faviconURL";
}
+ (NSString *)height {
	return @"height";
}
+ (NSString *)id {
	return @"id";
}
+ (NSString *)imageURL {
	return @"imageURL";
}
+ (NSString *)siteDescription {
	return @"siteDescription";
}
+ (NSString *)title {
	return @"title";
}
+ (NSString *)url {
	return @"url";
}
+ (NSString *)width {
	return @"width";
}
@end

