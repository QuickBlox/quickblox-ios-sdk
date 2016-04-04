// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to STKStickerPack.h instead.

#import <CoreData/CoreData.h>

extern const struct STKStickerPackAttributes {
	__unsafe_unretained NSString *artist;
	__unsafe_unretained NSString *bannerUrl;
	__unsafe_unretained NSString *disabled;
	__unsafe_unretained NSString *isNew;
	__unsafe_unretained NSString *order;
	__unsafe_unretained NSString *packDescription;
	__unsafe_unretained NSString *packID;
	__unsafe_unretained NSString *packName;
	__unsafe_unretained NSString *packTitle;
	__unsafe_unretained NSString *price;
    __unsafe_unretained NSString *pricePoint;
	__unsafe_unretained NSString *productID;
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

@property (nonatomic, strong) NSString* bannerUrl;

//- (BOOL)validateBannerUrl:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* disabled;

@property (atomic) BOOL disabledValue;
- (BOOL)disabledValue;
- (void)setDisabledValue:(BOOL)value_;

//- (BOOL)validateDisabled:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* isNew;

@property (atomic) BOOL isNewValue;
- (BOOL)isNewValue;
- (void)setIsNewValue:(BOOL)value_;

//- (BOOL)validateIsNew:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* order;

@property (atomic) int32_t orderValue;
- (int32_t)orderValue;
- (void)setOrderValue:(int32_t)value_;

//- (BOOL)validateOrder:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* packDescription;

//- (BOOL)validatePackDescription:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* packID;

@property (atomic) int64_t packIDValue;
- (int64_t)packIDValue;
- (void)setPackIDValue:(int64_t)value_;

//- (BOOL)validatePackID:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* packName;

//- (BOOL)validatePackName:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* packTitle;

//- (BOOL)validatePackTitle:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* pricePoint;

@property (nonatomic, strong) NSNumber* price;

@property (atomic) float priceValue;
- (float)priceValue;
- (void)setPriceValue:(float)value_;

//- (BOOL)validatePrice:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* productID;

//- (BOOL)validateProductID:(id*)value_ error:(NSError**)error_;

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

- (NSString*)primitiveBannerUrl;
- (void)setPrimitiveBannerUrl:(NSString*)value;

- (NSNumber*)primitiveDisabled;
- (void)setPrimitiveDisabled:(NSNumber*)value;

- (BOOL)primitiveDisabledValue;
- (void)setPrimitiveDisabledValue:(BOOL)value_;

- (NSNumber*)primitiveIsNew;
- (void)setPrimitiveIsNew:(NSNumber*)value;

- (BOOL)primitiveIsNewValue;
- (void)setPrimitiveIsNewValue:(BOOL)value_;

- (NSNumber*)primitiveOrder;
- (void)setPrimitiveOrder:(NSNumber*)value;

- (int32_t)primitiveOrderValue;
- (void)setPrimitiveOrderValue:(int32_t)value_;

- (NSString*)primitivePackDescription;
- (void)setPrimitivePackDescription:(NSString*)value;

- (NSNumber*)primitivePackID;
- (void)setPrimitivePackID:(NSNumber*)value;

- (int64_t)primitivePackIDValue;
- (void)setPrimitivePackIDValue:(int64_t)value_;

- (NSString*)primitivePackName;
- (void)setPrimitivePackName:(NSString*)value;

- (NSString*)primitivePackTitle;
- (void)setPrimitivePackTitle:(NSString*)value;

- (NSString*)primitivePricePoint;
- (void)setPrimitivePricePoint:(NSString*)value;

- (NSNumber*)primitivePrice;
- (void)setPrimitivePrice:(NSNumber*)value;

- (float)primitivePriceValue;
- (void)setPrimitivePriceValue:(float)value_;

- (NSString*)primitiveProductID;
- (void)setPrimitiveProductID:(NSString*)value;

- (NSMutableOrderedSet*)primitiveStickers;
- (void)setPrimitiveStickers:(NSMutableOrderedSet*)value;

@end
