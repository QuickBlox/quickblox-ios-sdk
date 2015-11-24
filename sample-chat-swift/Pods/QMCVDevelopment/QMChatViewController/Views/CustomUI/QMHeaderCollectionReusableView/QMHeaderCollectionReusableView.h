//
//  QMHeaderCollectionReusableView.h
//  Pods
//
//  Created by Vitaliy Gorbachov on 11/16/15.
//
//

#import <UIKit/UIKit.h>

@interface QMHeaderCollectionReusableView : UICollectionReusableView

@property (weak, nonatomic) IBOutlet UILabel *headerLabel;

+ (UINib *)nib;
+ (NSString *)cellReuseIdentifier;

@end
