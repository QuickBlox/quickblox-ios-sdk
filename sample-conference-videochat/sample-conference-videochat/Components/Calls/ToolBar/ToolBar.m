//
//  ToolBar.m
//  sample-conference-videochat
//
//  Created by Injoit on 13/10/15.
//  Copyright © 2015 QuickBlox Team. All rights reserved.
//

#import "ToolBar.h"
#import "CustomButton.h"

@interface ToolBar()

@property (strong, nonatomic) NSMutableArray *buttons;
@property (strong, nonatomic) NSMutableArray *actions;

@end

@implementation ToolBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        
        self.buttons = [NSMutableArray array];
        self.actions = [NSMutableArray array];
        
        [self setBackgroundImage:[[UIImage alloc] init]
              forToolbarPosition:UIToolbarPositionAny
                      barMetrics:UIBarMetricsDefault];
        
        [self setShadowImage:[[UIImage alloc] init]
          forToolbarPosition:UIToolbarPositionAny];
        
        //Default Gray
        self.backgroundColor = UIColor.clearColor;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    
    self = [super initWithCoder:coder];
    if (self) {
        
        self.buttons = [NSMutableArray array];
        self.actions = [NSMutableArray array];
        
        [self setBackgroundImage:[[UIImage alloc] init]
              forToolbarPosition:UIToolbarPositionAny
                      barMetrics:UIBarMetricsDefault];
        
        [self setShadowImage:[[UIImage alloc] init]
          forToolbarPosition:UIToolbarPositionAny];
        
        //Default Gray
        self.backgroundColor = UIColor.clearColor;
    }
    return self;
}

- (void)removeAllButtons {
    [self.buttons removeAllObjects];
    [self.actions removeAllObjects];
    [self updateItems];
}

- (void)updateItems {
    NSMutableArray *items = [NSMutableArray array];
    UIBarButtonItem *fs =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                  target:nil
                                                  action:nil];
    [items addObject:fs];

    for (CustomButton *button in self.buttons) {
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
        [items addObject:item];
        [items addObject:fs];
    }
    [self setItems:items.copy];
}

- (void)addButton:(UIButton *)button action:(void(^)(UIButton *sender))action {
    
    [button addTarget:self
               action:@selector(pressButton:)
     forControlEvents:UIControlEventTouchUpInside];
    
    [self.buttons addObject:button];
    [self.actions addObject:[action copy]];
}

- (void)pressButton:(CustomButton *)button {
    
    NSUInteger idx = [self.buttons indexOfObject:button];
    
    void(^action)(UIButton *sender) = self.actions[idx];
    action(button);
}

@end
