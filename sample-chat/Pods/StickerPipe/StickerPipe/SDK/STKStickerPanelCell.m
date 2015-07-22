//
//  STKStickerPanelCell.m
//  StickerFactory
//
//  Created by Vadim Degterev on 07.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "STKStickerPanelCell.h"
#import "UIImageView+Stickers.h"
#import "UIImage+Tint.h"
#import "STKUtility.h"

@interface STKStickerPanelCell()

@property (strong, nonatomic) UIImageView *stickerImageView;

@end

@implementation STKStickerPanelCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.stickerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 80.0, 80.0)];
        self.stickerImageView.center = CGPointMake(self.contentView.bounds.size.width/2,self.contentView.bounds.size.height/2);
        self.stickerImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.stickerImageView];
    }
    return self;
}

- (void)layoutSubviews {
    self.stickerImageView.center = CGPointMake(self.contentView.bounds.size.width/2,self.contentView.bounds.size.height/2);
}

- (void)prepareForReuse {
    [self.stickerImageView stk_cancelStickerLoading];
}

- (void) configureWithStickerMessage:(NSString*)stickerMessage
                         placeholder:(UIImage*)placeholder
                    placeholderColor:(UIColor*)placeholderColor {
    UIImage *resultPlaceholder = placeholder ? placeholder : [UIImage imageNamed:@"StickerPanelPlaceholder"];
    
    UIColor *colorForPlaceholder = placeholderColor ? placeholderColor : [STKUtility defaultGrayColor];
    
    UIImage *coloredPlaceholder = [resultPlaceholder imageWithImageTintColor:colorForPlaceholder];
    
    [self.stickerImageView stk_setStickerWithMessage:stickerMessage placeholder:coloredPlaceholder];
    
}

@end
