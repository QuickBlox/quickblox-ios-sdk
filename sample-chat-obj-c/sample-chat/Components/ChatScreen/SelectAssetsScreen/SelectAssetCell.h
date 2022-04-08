//
//  SelectAssetCell.h
//  sample-chat
//
//  Created by Injoit on 2/6/20.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SelectAssetCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *durationVideoLabel;
@property (weak, nonatomic) IBOutlet UIView *videoTypeView;
@property (weak, nonatomic) IBOutlet UIImageView *assetTypeImageView;
@property (weak, nonatomic) IBOutlet UIImageView *assetImageView;
@property (weak, nonatomic) IBOutlet UIImageView *checkBoxImageView;
@property (weak, nonatomic) IBOutlet UIView *checkBoxView;
@property (strong, nonatomic) NSString *representedAssetIdentifier;
@end

NS_ASSUME_NONNULL_END
