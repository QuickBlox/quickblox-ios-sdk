//
//  STKStickerPanelHeaderCell.m
//  StickerFactory
//
//  Created by Vadim Degterev on 08.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "STKStickerPanelHeaderCell.h"
#import <UIImageView+WebCache.h>
#import "STKUtility.h"
#import "UIImage+Tint.h"

@interface STKStickerPanelHeaderCell()

@property (strong, nonatomic) UIImageView *imageView;

@end

@implementation STKStickerPanelHeaderCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 24.0, 24.0)];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.imageView.center = CGPointMake(self.contentView.bounds.size.width/2,self.contentView.bounds.size.height/2);
        [self addSubview:self.imageView];
        
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected {
    if (selected) {
        self.backgroundColor = self.selectionColor ? self.selectionColor : [UIColor whiteColor];
    }
    else {
        self.backgroundColor = [UIColor clearColor];
    }
}

- (void)prepareForReuse {
    [self.imageView sd_cancelCurrentImageLoad];
    self.imageView.image = nil;
    self.backgroundColor = [UIColor clearColor];
}

- (void)configWithStickerPackName:(NSString *)name placeholder:(UIImage *)placeholder placeholderTintColor:(UIColor *)placeholderTintColor{
    
    if ([name isEqualToString:@"Recent"]) {
        self.imageView.image = [UIImage imageNamed:@"RecentIcon"];
    } else {
        
        NSURL *iconUrl = [STKUtility tabImageUrlForPackName:name];
        
        UIImage *resultPlaceholder = placeholder ? placeholder : [UIImage imageNamed:@"StikerTabPlaceholder"];
        
        UIColor *colorForPlaceholder = placeholderTintColor ? placeholderTintColor : [STKUtility defaultGrayColor];
        
        UIImage *coloredPlaceholder = [resultPlaceholder imageWithImageTintColor:colorForPlaceholder];
        
        
        [self.imageView sd_setImageWithURL:iconUrl placeholderImage:coloredPlaceholder];
    }
    
}

@end
