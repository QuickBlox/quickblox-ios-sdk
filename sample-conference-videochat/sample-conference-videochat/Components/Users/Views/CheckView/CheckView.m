//
//  CheckView.m
//  LoginComponent
//
//  Created by Andrey Ivanov on 03/06/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "CheckView.h"

@interface CheckView()

@property (strong, nonatomic) UIImageView *imageView;

@end

@implementation CheckView

- (UIImage *)checkboxNormalImage {
    
    static UIImage *_qm_checkbox_normal = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _qm_checkbox_normal = [UIImage imageNamed:@"checkbox-normal"];
    });
    
    return _qm_checkbox_normal;
}

- (UIImage *)checkboxPressedImage{
    
    static UIImage *_qm_checkbox_pressed = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _qm_checkbox_pressed = [UIImage imageNamed:@"checkbox-pressed"];
    });

    return _qm_checkbox_pressed;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _imageView = [[UIImageView alloc] initWithImage:[self checkboxNormalImage]];
    _imageView.frame = self.bounds;
    [self addSubview:_imageView];
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    _imageView.frame = self.bounds;
}

- (void)setCheck:(BOOL)check {
    
    if (_check != check) {
        _check = check;
        
        self.imageView.image = check ? [self checkboxPressedImage] : [self checkboxNormalImage];
    }
}

@end
