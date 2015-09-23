//
//  QMChatCollectionViewFlowLayout.m
//  QMChatViewController
//
//  Created by Andrey Ivanov on 20.04.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import "QMChatCollectionViewFlowLayout.h"
#import "QMChatCellLayoutAttributes.h"
#import "QMCollectionViewFlowLayoutInvalidationContext.h"

#import "QMChatCollectionView.h"

@interface QMChatCollectionViewFlowLayout()

@property (strong, nonatomic) NSMutableSet *visibleIndexPaths;
@property (strong, nonatomic) UIDynamicAnimator *dynamicAnimator;
@property (assign, nonatomic) CGFloat latestDelta;

@property (strong, nonatomic) NSCache *cache;

@end

@implementation QMChatCollectionViewFlowLayout

@dynamic chatCollectionView;

- (QMChatCollectionView *)chatCollectionView {
    
    return (id)self.collectionView;
}

#pragma mark - Initialization

- (void)configureFlowLayout {
    
    self.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.sectionInset = UIEdgeInsetsMake(10.0f, 4.0f, 10.0f, 4.0f);
    self.minimumLineSpacing = 4.0f;
    /**
     *  Init cache
     */
    _springinessEnabled = NO;
    _springResistanceFactor = 1000;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveApplicationMemoryWarningNotification:)
                                                 name:UIApplicationDidReceiveMemoryWarningNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveDeviceOrientationDidChangeNotification:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    self.cache = [[NSCache alloc] init];
    self.cache.countLimit = 3000;
    self.cache.name = @"com.qm.chat.sizes";
}

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        
        [self configureFlowLayout];
    }
    
    return self;
}

- (void)awakeFromNib {
    
    [super awakeFromNib];
    [self configureFlowLayout];
}

+ (Class)layoutAttributesClass {
    
    return [QMChatCellLayoutAttributes class];
}

+ (Class)invalidationContextClass {
    
    return [QMCollectionViewFlowLayoutInvalidationContext class];
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_dynamicAnimator removeAllBehaviors];
    _dynamicAnimator = nil;
    
    [self.visibleIndexPaths removeAllObjects];
    self.visibleIndexPaths = nil;
}

- (void)setSpringinessEnabled:(BOOL)springinessEnabled {
    
    if (_springinessEnabled != springinessEnabled) {
        
        _springinessEnabled = springinessEnabled;
        
        if (!springinessEnabled) {
            
            [_dynamicAnimator removeAllBehaviors];
            [_visibleIndexPaths removeAllObjects];
        }
        
        [self invalidateLayoutWithContext:[QMCollectionViewFlowLayoutInvalidationContext context]];
    }
}

- (CGFloat)itemWidth {
    
    return CGRectGetWidth(self.collectionView.frame) - self.sectionInset.left - self.sectionInset.right;
}

- (UIDynamicAnimator *)dynamicAnimator {
    
    if (!_dynamicAnimator) {
        _dynamicAnimator = [[UIDynamicAnimator alloc] initWithCollectionViewLayout:self];
    }
    return _dynamicAnimator;
}

- (NSMutableSet *)visibleIndexPaths {
    
    if (!_visibleIndexPaths) {
        _visibleIndexPaths = [NSMutableSet new];
    }
    return _visibleIndexPaths;
}

#pragma mark - Notifications

- (void)didReceiveApplicationMemoryWarningNotification:(NSNotification *)notification {
    
    [self resetLayout];
}

- (void)didReceiveDeviceOrientationDidChangeNotification:(NSNotification *)notification {
    
    [self resetLayout];
    [self invalidateLayoutWithContext:[QMCollectionViewFlowLayoutInvalidationContext context]];
}

#pragma mark - Collection view flow layout

- (void)invalidateLayoutWithContext:(QMCollectionViewFlowLayoutInvalidationContext *)context {
    
    if (context.invalidateDataSourceCounts) {
        
        context.invalidateFlowLayoutAttributes = YES;
        context.invalidateFlowLayoutDelegateMetrics = YES;
    }
    
    if (context.invalidateFlowLayoutAttributes || context.invalidateFlowLayoutDelegateMetrics) {
        
        [self resetDynamicAnimator];
    }
    
    if (context.invalidateFlowLayoutMessagesCache) {
        
        [self resetLayout];
    }
    
    [super invalidateLayoutWithContext:context];
}

- (void)prepareLayout {
    
    [super prepareLayout];
    
    if (self.springinessEnabled) {
        //  pad rect to avoid flickering
        CGFloat padding = -100.0f;
        CGRect visibleRect = CGRectInset(self.collectionView.bounds, padding, padding);
        
        NSArray *visibleItems = [super layoutAttributesForElementsInRect:visibleRect];
        NSSet *visibleItemsIndexPaths = [NSSet setWithArray:[visibleItems valueForKey:NSStringFromSelector(@selector(indexPath))]];
        
        [self removeNoLongerVisibleBehaviorsFromVisibleItemsIndexPaths:visibleItemsIndexPaths];
        [self addNewlyVisibleBehaviorsFromVisibleItems:visibleItems];
    }
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    
    NSArray *attributesInRect = [super layoutAttributesForElementsInRect:rect];
    
    if (self.springinessEnabled) {
        
        NSMutableArray *attributesInRectCopy = [attributesInRect mutableCopy];
        NSArray *dynamicAttributes = [self.dynamicAnimator itemsInRect:rect];
        
        //  avoid duplicate attributes
        //  use dynamic animator attribute item instead of regular item, if it exists
        for (UICollectionViewLayoutAttributes *eachItem in attributesInRect) {
            
            for (UICollectionViewLayoutAttributes *eachDynamicItem in dynamicAttributes) {
                
                if ([eachItem.indexPath isEqual:eachDynamicItem.indexPath] && eachItem.representedElementCategory == eachDynamicItem.representedElementCategory) {
                    
                    [attributesInRectCopy removeObject:eachItem];
                    [attributesInRectCopy addObject:eachDynamicItem];
                    
                    continue;
                }
            }
        }
        
        attributesInRect = attributesInRectCopy;
    }
	__weak __typeof(self)weakSelf = self;
    [attributesInRect enumerateObjectsUsingBlock:^(QMChatCellLayoutAttributes *attributesItem, NSUInteger idx, BOOL *stop) {
        
        if (attributesItem.representedElementCategory == UICollectionElementCategoryCell) {
			__typeof(self)strongSelf = weakSelf;
            [strongSelf configureCellLayoutAttributes:attributesItem];
        }
        else {
            
            attributesItem.zIndex = -1;
        }
    }];
    
    return attributesInRect;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath  {
    
    QMChatCellLayoutAttributes *customAttributes = (id)[super layoutAttributesForItemAtIndexPath:indexPath];
    
    if (customAttributes.representedElementCategory == UICollectionElementCategoryCell) {
        [self configureCellLayoutAttributes:customAttributes];
    }
    
    return customAttributes;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    
    if (self.springinessEnabled) {
        
        UIScrollView *scrollView = self.collectionView;
        CGFloat delta = newBounds.origin.y - scrollView.bounds.origin.y;
        
        self.latestDelta = delta;
        
        CGPoint touchLocation = [self.collectionView.panGestureRecognizer locationInView:self.collectionView];
		
		__weak __typeof(self)weakSelf = self;
        [self.dynamicAnimator.behaviors enumerateObjectsUsingBlock:^(UIAttachmentBehavior *springBehaviour, NSUInteger idx, BOOL *stop) {
            __typeof(self)strongSelf = weakSelf;
            [strongSelf adjustSpringBehavior:springBehaviour forTouchLocation:touchLocation];
            [strongSelf.dynamicAnimator updateItemUsingCurrentState:[springBehaviour.items firstObject]];
        }];
    }
    
    CGRect oldBounds = self.collectionView.bounds;
    
    if (CGRectGetWidth(newBounds) > CGRectGetWidth(oldBounds) ||
        CGRectGetWidth(newBounds) < CGRectGetWidth(oldBounds )) {
        
        return YES;
    }
    
    return NO;
}

- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems {
    
    [super prepareForCollectionViewUpdates:updateItems];
	
	
	__weak __typeof(self)weakSelf = self;
    [updateItems enumerateObjectsUsingBlock:^(UICollectionViewUpdateItem *updateItem, NSUInteger index, BOOL *stop) {
        __typeof(self)strongSelf = weakSelf;
        if (updateItem.updateAction == UICollectionUpdateActionInsert) {
            
            if (strongSelf.springinessEnabled && [strongSelf.dynamicAnimator layoutAttributesForCellAtIndexPath:updateItem.indexPathAfterUpdate]) {
                *stop = YES;
            }
            
            CGFloat collectionViewHeight = CGRectGetHeight(strongSelf.collectionView.bounds);
            
            QMChatCellLayoutAttributes *attributes =
            [QMChatCellLayoutAttributes layoutAttributesForCellWithIndexPath:updateItem.indexPathAfterUpdate];
            
            if (attributes.representedElementCategory == UICollectionElementCategoryCell) {
                [strongSelf configureCellLayoutAttributes:attributes];
            }
            
            attributes.frame = CGRectMake(0.0f,
                                          collectionViewHeight + CGRectGetHeight(attributes.frame),
                                          CGRectGetWidth(attributes.frame),
                                          CGRectGetHeight(attributes.frame));
            
            if (strongSelf.springinessEnabled) {
                
                UIAttachmentBehavior *springBehaviour = [strongSelf springBehaviorWithLayoutAttributesItem:attributes];
                [strongSelf.dynamicAnimator addBehavior:springBehaviour];
            }
        }
    }];
}

#pragma mark - Invalidation utilities

- (void)resetLayout {
    [self.cache removeAllObjects];
    [self resetDynamicAnimator];
}

- (void)resetDynamicAnimator {
    
    if (self.springinessEnabled) {
        
        [self.dynamicAnimator removeAllBehaviors];
        [self.visibleIndexPaths removeAllObjects];
    }
}

#pragma mark - Message cell layout utilities

- (CGSize)containerViewSizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    //Item unique id
    NSString *itemID = [self.chatCollectionView.dataSource collectionView:self.chatCollectionView
                                                        itemIdAtIndexPath:indexPath];

    NSValue *cachedSize = [self.cache objectForKey:itemID];
    
    if (cachedSize != nil) {
        
        return [cachedSize CGSizeValue];
    }
    
    
    QMChatCellLayoutModel layoutModel =
    [self.chatCollectionView.delegate collectionView:self.chatCollectionView
                     layoutModelAtIndexPath:indexPath];
    
    CGSize finalSize = CGSizeZero;
    
    if (CGSizeEqualToSize(layoutModel.staticContainerSize, CGSizeZero)) {
        
        //  from the cell xibs, there is a 2 point space between avatar and bubble
        CGFloat spacingBetweenAvatarAndBubble = 2.0f;
        
        CGFloat horizontalContainerInsets = layoutModel.containerInsets.left + layoutModel.containerInsets.right;
        
        CGFloat horizontalInsetsTotal = horizontalContainerInsets + spacingBetweenAvatarAndBubble;
        
        CGFloat maximumWidth = self.itemWidth - layoutModel.avatarSize.width - horizontalInsetsTotal;
        
        CGSize dynamicSize = [self.chatCollectionView.delegate collectionView:self.chatCollectionView
                                                       dynamicSizeAtIndexPath:indexPath
                                                                     maxWidth:maximumWidth];
        CGFloat verticalContainerInsets =
        layoutModel.containerInsets.top + layoutModel.containerInsets.bottom +
        layoutModel.topLabelHeight + layoutModel.bottomLabelHeight;
        
        CGFloat additionalSpace = layoutModel.spaceBetweenTextViewAndBottomLabel + layoutModel.spaceBetweenTopLabelAndTextView;
        
        CGFloat finalWidth = dynamicSize.width + horizontalInsetsTotal;
        
        CGFloat cellHeight = dynamicSize.height + verticalContainerInsets + additionalSpace;
        CGFloat finalCellHeigh = MAX(cellHeight, layoutModel.avatarSize.height);
        
        CGFloat minWidht = [self.chatCollectionView.delegate collectionView:self.chatCollectionView minWidthAtIndexPath:indexPath];
        minWidht+=horizontalContainerInsets;
        
        finalSize = CGSizeMake(MAX(finalWidth, minWidht), finalCellHeigh);
    }
    else {
        
        finalSize = layoutModel.staticContainerSize;
    }
    
    [self.cache setObject:[NSValue valueWithCGSize:finalSize] forKey:itemID];
    
    return finalSize;
}

- (CGSize)sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGSize containerSize = [self containerViewSizeForItemAtIndexPath:indexPath];
    
    return CGSizeMake(self.itemWidth, ceilf(containerSize.height));
}

- (void)configureCellLayoutAttributes:(QMChatCellLayoutAttributes *)layoutAttributes {
    
    NSIndexPath *indexPath = layoutAttributes.indexPath;
    
    CGSize containerSize = [self containerViewSizeForItemAtIndexPath:indexPath];
    layoutAttributes.containerSize = containerSize;
    
    QMChatCellLayoutModel layoutModel =
    [self.chatCollectionView.delegate collectionView:self.chatCollectionView
                              layoutModelAtIndexPath:indexPath];
    
    layoutAttributes.avatarSize = layoutModel.avatarSize;
    layoutAttributes.containerInsets = layoutModel.containerInsets;
    layoutAttributes.topLabelHeight = layoutModel.topLabelHeight;
    layoutAttributes.bottomLabelHeight = layoutModel.bottomLabelHeight;
    layoutAttributes.spaceBetweenTopLabelAndTextView = layoutModel.spaceBetweenTopLabelAndTextView;
    layoutAttributes.spaceBetweenTextViewAndBottomLabel = layoutModel.spaceBetweenTextViewAndBottomLabel;
}

#pragma mark - Spring behavior utilities

- (UIAttachmentBehavior *)springBehaviorWithLayoutAttributesItem:(UICollectionViewLayoutAttributes *)item {
    
    if (CGSizeEqualToSize(item.frame.size, CGSizeZero)) {
        // adding a spring behavior with zero size will fail in in -prepareForCollectionViewUpdates:
        return nil;
    }
    
    UIAttachmentBehavior *springBehavior =
    [[UIAttachmentBehavior alloc] initWithItem:item
                              attachedToAnchor:item.center];
    
    springBehavior.length = 1.0f;
    springBehavior.damping = 1.0f;
    springBehavior.frequency = 1.0f;
    
    return springBehavior;
}

- (void)addNewlyVisibleBehaviorsFromVisibleItems:(NSArray *)visibleItems {
    //  a "newly visible" item is in `visibleItems` but not in `self.visibleIndexPaths`
    NSIndexSet *indexSet = [visibleItems indexesOfObjectsPassingTest:^BOOL(UICollectionViewLayoutAttributes *item, NSUInteger index, BOOL *stop) {
        return ![self.visibleIndexPaths containsObject:item.indexPath];
    }];
    
    NSArray *newlyVisibleItems = [visibleItems objectsAtIndexes:indexSet];
    CGPoint touchLocation = [self.collectionView.panGestureRecognizer locationInView:self.collectionView];
	
	__weak __typeof(self)weakSelf = self;
	
    [newlyVisibleItems enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *item, NSUInteger index, BOOL *stop) {
		__typeof(self)strongSelf = weakSelf;
        UIAttachmentBehavior *springBehaviour = [strongSelf springBehaviorWithLayoutAttributesItem:item];
        [strongSelf adjustSpringBehavior:springBehaviour forTouchLocation:touchLocation];
        [strongSelf.dynamicAnimator addBehavior:springBehaviour];
        [strongSelf.visibleIndexPaths addObject:item.indexPath];
    }];
}

- (void)removeNoLongerVisibleBehaviorsFromVisibleItemsIndexPaths:(NSSet *)visibleItemsIndexPaths {
    
    NSArray *behaviors = self.dynamicAnimator.behaviors;
    
    NSIndexSet *indexSet = [behaviors indexesOfObjectsPassingTest:^BOOL(UIAttachmentBehavior *springBehaviour, NSUInteger index, BOOL *stop) {
        
        UICollectionViewLayoutAttributes *layoutAttributes = [springBehaviour.items firstObject];
        return ![visibleItemsIndexPaths containsObject:layoutAttributes.indexPath];
    }];
    
    NSArray *behaviorsToRemove = [self.dynamicAnimator.behaviors objectsAtIndexes:indexSet];
	
	__weak __typeof(self)weakSelf = self;
	
    [behaviorsToRemove enumerateObjectsUsingBlock:^(UIAttachmentBehavior *springBehaviour, NSUInteger index, BOOL *stop) {
        __typeof(self)strongSelf = weakSelf;
        UICollectionViewLayoutAttributes *layoutAttributes = [springBehaviour.items firstObject];
        [strongSelf.dynamicAnimator removeBehavior:springBehaviour];
        [strongSelf.visibleIndexPaths removeObject:layoutAttributes.indexPath];
    }];
}

- (void)adjustSpringBehavior:(UIAttachmentBehavior *)springBehavior forTouchLocation:(CGPoint)touchLocation {
    
    UICollectionViewLayoutAttributes *item = [springBehavior.items firstObject];
    CGPoint center = item.center;
    
    //  if touch is not (0,0) -- adjust item center "in flight"
    if (!CGPointEqualToPoint(CGPointZero, touchLocation)) {
        
        CGFloat distanceFromTouch = fabs(touchLocation.y - springBehavior.anchorPoint.y);
        CGFloat scrollResistance = distanceFromTouch / self.springResistanceFactor;
        
        if (self.latestDelta < 0.0f) {
            
            center.y += MAX(self.latestDelta, self.latestDelta * scrollResistance);
        }
        else {
            
            center.y += MIN(self.latestDelta, self.latestDelta * scrollResistance);
        }
        
        item.center = center;
    }
}

@end
