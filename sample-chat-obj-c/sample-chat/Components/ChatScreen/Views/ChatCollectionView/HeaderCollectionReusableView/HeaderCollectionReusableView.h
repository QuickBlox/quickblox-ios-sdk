//
//  HeaderCollectionReusableView.h
//  sample-chat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HeaderCollectionReusableView : UICollectionReusableView

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;

+ (UINib *)nib;
+ (NSString *)cellReuseIdentifier;

@end

NS_ASSUME_NONNULL_END
