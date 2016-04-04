// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to STKStickerPack.m instead.

#import "_STKStickerPack.h"

const struct STKStickerPackAttributes STKStickerPackAttributes = {
	.artist = @"artist",
	.bannerUrl = @"bannerUrl",
	.disabled = @"disabled",
	.isNew = @"isNew",
	.order = @"order",
	.packDescription = @"packDescription",
	.packID = @"packID",
	.packName = @"packName",
	.packTitle = @"packTitle",
	.price = @"price",
    .pricePoint = @"pricePoint",
	.productID = @"productID",
};

const struct STKStickerPackRelationships STKStickerPackRelationships = {
	.stickers = @"stickers",
};

@implementation STKStickerPackID
@end

@implementation _STKStickerPack

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"STKStickerPack" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"STKStickerPack";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"STKStickerPack" inManagedObjectContext:moc_];
}

- (STKStickerPackID*)objectID {
	return (STKStickerPackID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"disabledValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"disabled"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"isNewValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isNew"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"orderValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"order"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"packIDValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"packID"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"priceValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"price"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic artist;

@dynamic bannerUrl;

@dynamic disabled;

- (BOOL)disabledValue {
	NSNumber *result = [self disabled];
	return [result boolValue];
}

- (void)setDisabledValue:(BOOL)value_ {
	[self setDisabled:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveDisabledValue {
	NSNumber *result = [self primitiveDisabled];
	return [result boolValue];
}

- (void)setPrimitiveDisabledValue:(BOOL)value_ {
	[self setPrimitiveDisabled:[NSNumber numberWithBool:value_]];
}

@dynamic isNew;

- (BOOL)isNewValue {
	NSNumber *result = [self isNew];
	return [result boolValue];
}

- (void)setIsNewValue:(BOOL)value_ {
	[self setIsNew:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsNewValue {
	NSNumber *result = [self primitiveIsNew];
	return [result boolValue];
}

- (void)setPrimitiveIsNewValue:(BOOL)value_ {
	[self setPrimitiveIsNew:[NSNumber numberWithBool:value_]];
}

@dynamic order;

- (int32_t)orderValue {
	NSNumber *result = [self order];
	return [result intValue];
}

- (void)setOrderValue:(int32_t)value_ {
	[self setOrder:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveOrderValue {
	NSNumber *result = [self primitiveOrder];
	return [result intValue];
}

- (void)setPrimitiveOrderValue:(int32_t)value_ {
	[self setPrimitiveOrder:[NSNumber numberWithInt:value_]];
}

@dynamic packDescription;

@dynamic packID;

- (int64_t)packIDValue {
	NSNumber *result = [self packID];
	return [result longLongValue];
}

- (void)setPackIDValue:(int64_t)value_ {
	[self setPackID:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitivePackIDValue {
	NSNumber *result = [self primitivePackID];
	return [result longLongValue];
}

- (void)setPrimitivePackIDValue:(int64_t)value_ {
	[self setPrimitivePackID:[NSNumber numberWithLongLong:value_]];
}

@dynamic packName;

@dynamic pricePoint;

@dynamic packTitle;

@dynamic price;

- (float)priceValue {
	NSNumber *result = [self price];
	return [result floatValue];
}

- (void)setPriceValue:(float)value_ {
	[self setPrice:[NSNumber numberWithFloat:value_]];
}

- (float)primitivePriceValue {
	NSNumber *result = [self primitivePrice];
	return [result floatValue];
}

- (void)setPrimitivePriceValue:(float)value_ {
	[self setPrimitivePrice:[NSNumber numberWithFloat:value_]];
}

@dynamic productID;

@dynamic stickers;

- (NSMutableOrderedSet*)stickersSet {
	[self willAccessValueForKey:@"stickers"];

	NSMutableOrderedSet *result = (NSMutableOrderedSet*)[self mutableOrderedSetValueForKey:@"stickers"];

	[self didAccessValueForKey:@"stickers"];
	return result;
}

@end

@implementation _STKStickerPack (StickersCoreDataGeneratedAccessors)
- (void)addStickers:(NSOrderedSet*)value_ {
	[self.stickersSet unionOrderedSet:value_];
}
- (void)removeStickers:(NSOrderedSet*)value_ {
	[self.stickersSet minusOrderedSet:value_];
}
- (void)addStickersObject:(STKSticker*)value_ {
	[self.stickersSet addObject:value_];
}
- (void)removeStickersObject:(STKSticker*)value_ {
	[self.stickersSet removeObject:value_];
}
- (void)insertObject:(STKSticker*)value inStickersAtIndex:(NSUInteger)idx {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"stickers"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self stickers]];
    [tmpOrderedSet insertObject:value atIndex:idx];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"stickers"];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"stickers"];
}
- (void)removeObjectFromStickersAtIndex:(NSUInteger)idx {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"stickers"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self stickers]];
    [tmpOrderedSet removeObjectAtIndex:idx];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"stickers"];
    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"stickers"];
}
- (void)insertStickers:(NSArray *)value atIndexes:(NSIndexSet *)indexes {
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"stickers"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self stickers]];
    [tmpOrderedSet insertObjects:value atIndexes:indexes];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"stickers"];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"stickers"];
}
- (void)removeStickersAtIndexes:(NSIndexSet *)indexes {
    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"stickers"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self stickers]];
    [tmpOrderedSet removeObjectsAtIndexes:indexes];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"stickers"];
    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"stickers"];
}
- (void)replaceObjectInStickersAtIndex:(NSUInteger)idx withObject:(STKSticker*)value {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:@"stickers"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self stickers]];
    [tmpOrderedSet replaceObjectAtIndex:idx withObject:value];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"stickers"];
    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:@"stickers"];
}
- (void)replaceStickersAtIndexes:(NSIndexSet *)indexes withStickers:(NSArray *)value {
    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:@"stickers"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self stickers]];
    [tmpOrderedSet replaceObjectsAtIndexes:indexes withObjects:value];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"stickers"];
    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:@"stickers"];
}
@end

