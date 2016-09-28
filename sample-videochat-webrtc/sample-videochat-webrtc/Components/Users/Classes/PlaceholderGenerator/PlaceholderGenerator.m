//
//  PlaceholderGenerator.m
//  LoginComponent
//
//  Created by Andrey Ivanov on 08/06/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "PlaceholderGenerator.h"

@interface PlaceholderGenerator()

@property (strong, nonatomic) NSCache *cache;
@property (strong, nonatomic) NSArray *colors;

@end

@implementation PlaceholderGenerator

+ (instancetype)instance {
    
    static PlaceholderGenerator *_generator = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _generator = [[PlaceholderGenerator alloc] init];
    });
    
    return _generator;
}

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        _cache = [[NSCache alloc] init];
        _cache.name = @"QMUserPlaceholer.cache";
        _cache.countLimit = 200;
        
        _colors =
        @[[UIColor colorWithRed:0.9906f green:0.5137f blue:0.033 alpha:1.0f], // #FF9600
          [UIColor colorWithRed:0.267f green:0.859f blue:0.369f alpha:1.0f], // #44DB5E
          [UIColor colorWithRed:0.2781f green:0.7296f blue:0.984f alpha:1.0f], // #54C7FC
          [UIColor colorWithRed:0.9862f green:0.0499f blue:0.2661f alpha:1.0f], // #FF2D55
          [UIColor colorWithRed:0.5304f green:0.0727f blue:0.6196f alpha:1.0f], // #9B2FAE
          [UIColor colorWithRed:0.082f green:0.584f blue:0.533f alpha:1.0f], // #159588
          [UIColor colorWithRed:0 green:0.478f blue:1.0f alpha:1.0f], // #007AFF
          [UIColor colorWithRed:0.804f green:0.855f blue:0.286f alpha:1.0f], // #CDDA49
          [UIColor colorWithRed:0.122f green:0.737f blue:0.823f alpha:1.0f], // #1FBCD2
          [UIColor colorWithRed:0.251f green:0.329f blue:0.698f alpha:1.0f]]; // #4054B2
    }
    
    return self;
}

- (UIColor* _Nonnull)colorForString:(NSString*)string {
    
    unsigned long hashNumber = stringToLong((unsigned char*)[string UTF8String]);
    UIColor* color = self.colors[hashNumber % [self.colors count]];
    return color;
}

unsigned long stringToLong(unsigned char* str) {
    
    unsigned long hash = 5381;
    int c;
    while ((c = *str++)) {
        hash = ((hash << 5) + hash) + c;
    }
    return hash;
}

+ (UIImage *)placeholderWithSize:(CGSize)size
                           title:(NSString *)title {
    
    NSString *key = [NSString stringWithFormat:@"%@ %@", title, NSStringFromCGSize(size)];
    
    UIImage *image = [[PlaceholderGenerator instance].cache objectForKey:key];
    
    if (image) {
        
        return image;
    }
    else {
        
        UIImage *img = [self placeholderWithSize:size
                                           color:[[PlaceholderGenerator instance] colorForString:title]
                                           title:title isOval:YES];
        
        [[PlaceholderGenerator instance].cache setObject:img forKey:key];
        
        return img;
    }
}

+ (UIImage *)placeholderWithSize:(CGSize)size color:(UIColor *)color title:(NSString *)title isOval:(BOOL)isOval {
    
    NSUInteger min = MIN(size.width, size.height);
    CGRect frame = CGRectMake(0, 0, size.width, size.height);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    
    UIBezierPath *path = nil;
    if (isOval) {
        
        path = [UIBezierPath bezierPathWithOvalInRect:frame];
    }
    else {
        
        path = [UIBezierPath bezierPathWithRect:frame];
    }
    
    [color setFill];
    [path fill];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    UIFont *font = [UIFont systemFontOfSize:min / 2.0f];
    UIColor *textColor = [UIColor whiteColor];
    
    NSString *textContent = [[title substringToIndex:1] uppercaseString];
    
    NSDictionary *ovalFontAttributes = @{NSFontAttributeName:font ,
                                         NSForegroundColorAttributeName:textColor,
                                         NSParagraphStyleAttributeName:paragraphStyle};
    
    CGRect rect = [textContent boundingRectWithSize:frame.size
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:ovalFontAttributes context:nil];
    
    CGRect textRect = CGRectOffset(frame,
                                   0,
                                   (size.height - rect.size.height) / 2);
    [textContent drawInRect:textRect withAttributes: ovalFontAttributes];
    //Get image
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

+ (UIImage *)groupPlaceholderWithUsers:(NSArray *)users
                                  size:(NSUInteger)size {
    
    CGSize tSize = (CGSize){size, size};
    
    UIGraphicsBeginImageContextWithOptions(tSize, NO, 0.0);
    
    NSUInteger count = MIN(users.count, 4);
    
    for (NSUInteger i = 0; i < count; i++) {
        
        QBUUser *user = users[i];
        CGRect r = [self rectWithIndex:i size:size count:count];
        
        UIImage *img = [self placeholderWithSize:r.size
                                           color:[PlaceholderGenerator instance].colors[user.ID % 10]
                                           title:user.fullName
                                          isOval:NO];
        
        [img drawInRect:r];
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();

    UIGraphicsBeginImageContextWithOptions(tSize, NO, 0.0);
    
    [[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.3] setFill];
    [[UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, size, size)] fill];
    
    CGRect interiorBox = CGRectInset(CGRectMake(0, 0, size, size), 2, 2);
    UIBezierPath *interior = [UIBezierPath bezierPathWithOvalInRect:interiorBox];
    
    [interior addClip];
    [image drawInRect:CGRectMake(0, 0, size, size)];
    
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return finalImage;
}

+ (CGRect)rectWithIndex:(NSUInteger)idx size:(NSUInteger)size count:(NSUInteger)count {
    
    NSUInteger h = count > 2 ? size / 2 : size;
    NSUInteger s = size/2;
    
    switch (idx) {
        case 0:
            
            return CGRectMake(0, 0, s, count < 4 ?  size : size / 2);
            
        case 1:
            
            return CGRectMake(s, 0, s, h);
            
        case 2:
            
            return CGRectMake(count < 4 ? s : 0, s, s, h);
            
        case 3:
            
            return CGRectMake(s, s, s, h);
    }
    
    return CGRectZero;
}

@end
