// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to STKStickerPack.h instead.

#import <CoreData/CoreData.h>

extern const struct STKStickerPackAttributes {
	__unsafe_unretained NSString *artist;
	__unsafe_unretained NSString *packID;
	__unsafe_unretained NSString *packName;
	__unsafe_unretained NSString *packTitle;
	__unsafe_unretained NSString *price;
} STKStickerPackAttributes;

extern const struct STKStickerPackRelationships {
	__unsafe_unretained NSString *stickers;
} STKStickerPackRelationships;

@class STKSticker;

@interface STKStickerPackID : NSManagedObjectID {}
@end

@interface _STKStickerPack : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) STKStickerPackID* objectID;

@property (nonatomic, strong) NSString* artist;

//- (BOOL)validateArtist:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* packID;

@property (atomic) int64_t packIDValue;
- (int64_t)packIDValue;
- (void)setPackIDValue:(int64_t)value_;

//- (BOOL)validatePackID:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* packName;

//- (BOOL)validatePackName:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* packTitle;

//- (BOOL)validatePackTitle:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* price;

@property (atomic) float priceValue;
- (float)priceValue;
- (void)setPriceValue:(float)value_;

//- (BOOL)validatePrice:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSOrderedSet *stickers;

- (NSMutableOrderedSet*)stickersSet;

@end

@interface _STKStickerPack (StickersCoreDataGeneratedAccessors)
- (void)addStickers:(NSOrderedSet*)value_;
- (void)removeStickers:(NSOrderedSet*)value_;
- (void)addStickersObject:(STKSticker*)value_;
- (void)removeStickersObject:(STKSticker*)value_;

- (void)insertObject:(STKSticker*)value inStickersAtIndex:(NSUInteger)idx;
- (void)removeObjectFromStickersAtIndex:(NSUInteger)idx;
- (void)insertStickers:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeStickersAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInStickersAtIndex:(NSUInteger)idx withObject:(STKSticker*)value;
- (void)replaceStickersAtIndexes:(NSIndexSet *)indexes withStickers:(NSArray *)values;

@end

@interface _STKStickerPack (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveArtist;
- (void)setPrimitiveArtist:(NSString*)value;

- (NSNumber*)primitivePackID;
- (void)setPrimitivePackID:(NSNumber*)value;

- (int64_t)primitivePackIDValue;
- (void)setPrimitivePackIDValue:(int64_t)value_;

- (NSString*)primitivePackName;
- (void)setPrimitivePackName:(NSString*)value;

- (NSString*)primitivePackTitle;
- (void)setPrimitivePackTitle:(NSString*)value;

- (NSNumber*)primitivePrice;
- (void)setPrimitivePrice:(NSNumber*)value;

- (float)primitivePriceValue;
- (void)setPrimitivePriceValue:(float)value_;

- (NSMutableOrderedSet*)primitiveStickers;
- (void)setPrimitiveStickers:(NSMutableOrderedSet*)value;

@end
