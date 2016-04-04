//
//  STKStickerPanelHeaderCell.m
//  StickerFactory
//
//  Created by Vadim Degterev on 08.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "STKStickerHeaderCell.h"
#import "DFImageManagerKit.h"
#import "STKUtility.h"
#import "UIImage+Tint.h"
#import "STKStickerPackObject.h"
#import "STKBadgeView.h"

@interface STKStickerHeaderCell()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) STKBadgeView *dotView;
@property (nonatomic, strong) DFImageTask *imageTask;
@property (nonatomic, strong) UIImage *grayImage;
@property (nonatomic, strong) UIImage *originalImage;

@end

@implementation STKStickerHeaderCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 24.0, 24.0)];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.imageView.center = CGPointMake(self.contentView.bounds.size.width/2,self.contentView.bounds.size.height/2);
        [self.contentView addSubview:self.imageView];
        
        self.dotView = [[STKBadgeView alloc] initWithFrame:CGRectMake(0, 0, 12.0, 12.0) lineWidth:1.0 dotSize:CGSizeZero andBorderColor:[STKUtility defaultGreyColor]];
        
        self.dotView.center = CGPointMake(CGRectGetMaxX(self.imageView.frame), CGRectGetMinY(self.imageView.frame));
        
        [self.contentView addSubview:self.dotView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected {
    if (selected) {
        self.backgroundColor = self.selectionColor ? self.selectionColor : [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1.0];
        self.imageView.image = self.originalImage;
    }
    else {
        self.backgroundColor = [UIColor clearColor];
        self.imageView.image = self.grayImage ? self.grayImage : self.originalImage;
    }
}

- (void)prepareForReuse {
    [self.imageTask cancel];
    self.imageTask = nil;
    self.imageView.image = nil;
    self.originalImage = nil;
    self.grayImage = nil;
    self.dotView.hidden = NO;
    self.backgroundColor = [UIColor clearColor];
}

- (void)configWithStickerPack:(STKStickerPackObject *)stickerPack placeholder:(UIImage *)placeholder placeholderTintColor:(UIColor *)placeholderTintColor{
    //TODO:Refactoring
    if ([stickerPack.packName isEqualToString:@"Recent"]) {
        
        self.originalImage = [UIImage imageNamed:@"STKRecentSelectedIcon"];
        self.grayImage = [UIImage imageNamed:@"STKRecentIcon"];
        self.imageView.image = [UIImage imageNamed:@"STKRecentIcon"];
        self.dotView.hidden = YES;
    } else {
        self.dotView.hidden = !stickerPack.isNew.boolValue;
        
        NSURL *iconUrl = [STKUtility tabImageUrlForPackName:stickerPack.packName];
        
        UIImage *resultPlaceholder = placeholder ? placeholder : [UIImage imageNamed:@"STKStikerTabPlaceholder"];
        
        UIColor *colorForPlaceholder = placeholderTintColor && !placeholder ? placeholderTintColor : [STKUtility defaultPlaceholderGrayColor];
        
        UIImage *coloredPlaceholder = [resultPlaceholder imageWithImageTintColor:colorForPlaceholder];
        
        
        DFImageRequestOptions *options = [DFImageRequestOptions new];
        
        options.priority = DFImageRequestPriorityHigh;
        
        self.originalImage = coloredPlaceholder;
        self.imageView.image = coloredPlaceholder;
        [self setNeedsLayout];
        
        DFImageRequest *request = [DFImageRequest requestWithResource:iconUrl targetSize:CGSizeZero contentMode:DFImageContentModeAspectFit options:options];
        
        __weak typeof(self) weakSelf = self;
        
        //TODO:Refactoring
        self.imageTask =[[DFImageManager sharedManager] imageTaskForRequest:request completion:^(UIImage *image, NSDictionary *info) {
            
            if (image) {
                weakSelf.grayImage = [UIImage convertImageToGrayScale:image];
                weakSelf.originalImage = image;
                UIImage *resultImage = weakSelf.selected ? image : [UIImage convertImageToGrayScale:image];
                weakSelf.imageView.image = resultImage;
                [weakSelf setNeedsLayout];
            } else {
                NSError *error = info[DFImageInfoErrorKey];
                if (error.code != -1) {
                    STKLog(@"Failed loading from header cell: %@", error.localizedDescription);
                }
            }
        }];
        
        [self.imageTask resume];
        
    }
    
}

- (void)configureSettingsCell {
    self.originalImage = [UIImage imageNamed:@"STKSettingsSelectedIcon"];
    self.grayImage = [UIImage imageNamed:@"STKSettingsIcon"];
    self.imageView.image = self.grayImage;
    self.imageView.tintColor = [UIColor colorWithRed:4/255.0 green:122/255.0 blue:1 alpha:1];
    self.dotView.hidden = YES;
}

@end
