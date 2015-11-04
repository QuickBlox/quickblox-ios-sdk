//
//  OpponentsFlowLayout.h
//  flowlayout
//
//  Created by Anton Sokolchenko on 10/8/15.
//  Copyright © 2015 anton. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OpponentsFlowLayout : UICollectionViewFlowLayout

+ (CGRect)frameForWithNumberOfItems:(NSUInteger)numberOfItems row:(NSUInteger)row contentSize:(CGSize)contentSize;

@end
