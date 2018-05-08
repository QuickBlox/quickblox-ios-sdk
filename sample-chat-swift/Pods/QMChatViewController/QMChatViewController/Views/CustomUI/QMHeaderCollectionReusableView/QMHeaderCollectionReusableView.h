//
//  QMHeaderCollectionReusableView.h
//  QMChatViewController
//
//  Created by Vitaliy Gorbachov on 11/16/15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QMHeaderCollectionReusableView : UICollectionReusableView

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;

+ (UINib *)nib;
+ (NSString *)cellReuseIdentifier;

@end
