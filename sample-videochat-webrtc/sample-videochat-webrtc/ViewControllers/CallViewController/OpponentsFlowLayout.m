//
//  CustomLayout.m
//  flowlayout
//
//  Created by Anton Sokolchenko on 10/8/15.
//  Copyright © 2015 anton. All rights reserved.
//

#import "OpponentsFlowLayout.h"

@interface OpponentsFlowLayout()

@property (strong, nonatomic) NSMutableArray *data;

@end

@implementation OpponentsFlowLayout

- (CGSize)collectionViewContentSize {
    
    return self.collectionView.frame.size;
}

- (void)prepareLayout {
    
    self.minimumInteritemSpacing = 2;
    self.minimumLineSpacing = 2;
    
    if (!_data) {
        _data = [NSMutableArray array];
    }
    else {
        return;
    }
    
    NSInteger items = [self.collectionView.dataSource collectionView:self.collectionView
                                              numberOfItemsInSection:0];
    
    for (NSUInteger itemIndex = 0; itemIndex < items; itemIndex++) {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:itemIndex inSection:0];
        
        UICollectionViewLayoutAttributes *itemAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        
        CGRect frame  = [OpponentsFlowLayout frameForWithNumberOfItems:items
                                                                   row:itemIndex
                                                           contentSize:self.collectionView.frame.size];
        itemAttributes.frame = frame;
        
        [self.data addObject:itemAttributes];
    }
}

+ (NSUInteger )columnsWithWithNumberOfItems:(NSUInteger )numbers isPortrait:(BOOL)isPortrait{
    
    int countOfColumns = -1;
    
    if (isPortrait) {
        
        if (numbers <= 2 ){
            
            countOfColumns = 1;
        }
        else if (numbers <= 6) {
            
            countOfColumns = 2;
        }
        else {
            
            countOfColumns = 3;
        }
    }
    else {
        
        if (numbers == 1 ) {
            
            countOfColumns = 1;
            
        } else if (numbers <= 2 || numbers == 4) {
            
            countOfColumns = 2;
            
        } else if (numbers == 3 || numbers == 5) {
            
            countOfColumns = 3;
            
        } else {
            
            countOfColumns = 4;
        }
    }
    
    return countOfColumns;
}

+ (CGRect)frameForWithNumberOfItems:(NSUInteger)numberOfItems row:(NSUInteger)row contentSize:(CGSize)contentSize {
    
    BOOL isPortrait = contentSize.width < contentSize.height;
    NSUInteger columns = [self columnsWithWithNumberOfItems:numberOfItems
                                                 isPortrait:isPortrait];
    NSUInteger border = 1;
    
    NSUInteger rows = ceil((float)numberOfItems / (float)columns);
    
    CGFloat h = (contentSize.height - ((rows + 1) * border)) / rows;
    CGFloat w = (contentSize.width - ((columns + 1) * border)) / columns ;
    
    NSUInteger line = row == 0 ? 0 : row / columns;
    NSUInteger _r = row % columns;
    
    NSUInteger xOffset = (w * _r)  ;
    NSUInteger yOffset = (line == 0 ? 0 : h * line ) ;
    
    NSUInteger xBorderOffset = border * (_r + 1) ;
    
    NSUInteger yBorderOffset = border * (line + 1);
    
    NSUInteger mod = numberOfItems % columns;
    
    NSUInteger centered = numberOfItems - mod;
    
    if (row >= centered) {
        
        CGFloat centerX = contentSize.width / 2;
        xBorderOffset = centerX - mod * w/2;
        
    }
    
    CGRect result = CGRectMake(xOffset + xBorderOffset , yOffset+ yBorderOffset, w , h);
    
    return result;
}

//- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
//    
//    return YES;
//}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)targetRect {
    
    NSMutableArray *matchingLayoutAttributes = [NSMutableArray new];
    
    
    NSInteger items = [self.collectionView.dataSource collectionView:self.collectionView
                                              numberOfItemsInSection:0];
    
    for (UICollectionViewLayoutAttributes *cellAttributes in self.data) {
        
        NSUInteger index = [self.data indexOfObject:cellAttributes];
        CGRect frame  = [OpponentsFlowLayout frameForWithNumberOfItems:items
                                                                   row:index
                                                           contentSize:self.collectionView.bounds.size];
        cellAttributes.frame = frame;
        UICollectionViewLayoutAttributes *copy = [cellAttributes copy];
        [matchingLayoutAttributes addObject:copy];
    }
    
    
    return matchingLayoutAttributes;
}

// center last row elements by collectionView center
- (void)centerLastRowElements:(NSArray *)attributes {
    
    CGFloat attributeWidth = ((UICollectionViewLayoutAttributes *)attributes[0]).frame.size.width;
    CGFloat centerX = self.collectionView.center.x;
    CGFloat offsetByX = centerX - attributes.count * attributeWidth/2; // shift by half sum of lowest row elements width
    
    for (NSUInteger i = attributes.count; i != 0; i--) { // from left to right
        // first element will be leftmost at display
        UICollectionViewLayoutAttributes *currentAttribute = attributes[attributes.count - i];
        
        currentAttribute.frame = CGRectMake(offsetByX,
                                            currentAttribute.frame.origin.y,
                                            currentAttribute.frame.size.width,
                                            currentAttribute.frame.size.height);
        offsetByX += attributeWidth;
    }
}

/// arrange elements in row by full width
- (void)arrangeLastRowElements:(NSArray *)attributes width:(CGFloat)width {
    
    for (UICollectionViewLayoutAttributes *attribute in attributes) {
        attribute.size = CGSizeMake(width/attributes.count, attribute.size.height);
    }
    
    [self centerLastRowElements:attributes];
    
}

@end
