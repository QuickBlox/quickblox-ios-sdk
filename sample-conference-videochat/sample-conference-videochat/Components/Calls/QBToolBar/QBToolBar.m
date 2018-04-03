//
//  ToolBar.m
//  sample-videochat-webrtc
//
//  Created by Andrey Ivanov on 13/10/15.
//  Copyright © 2015 QuickBlox Team. All rights reserved.
//

#import "QBToolBar.h"
#import "QBButton.h"

@interface QBToolBar()

@property (strong, nonatomic) NSMutableArray *buttons;
@property (strong, nonatomic) NSMutableArray *actions;

@end

@implementation QBToolBar

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
        self.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.3];
    }
    return self;
}

- (void)updateItems {
    
    NSMutableArray *items = [NSMutableArray array];
    
    UIBarButtonItem *fs =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                  target:nil
                                                  action:nil];
    for (QBButton *button in self.buttons) {
        
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
        
        [items addObjectsFromArray:self.items];
        [items addObject:fs];
        [items addObject:item];
    }
    
    [items addObject:fs];
    [self setItems:items.copy];
}

- (void)addButton:(UIButton *)button action:(void(^)(UIButton *sender))action {
    
    [button addTarget:self
               action:@selector(pressButton:)
     forControlEvents:UIControlEventTouchUpInside];
    
    [self.buttons addObject:button];
    [self.actions addObject:[action copy]];
}

- (void)pressButton:(QBButton *)button {
    
    NSUInteger idx = [self.buttons indexOfObject:button];
    
    void(^action)(UIButton *sender) = self.actions[idx];
    action(button);
}

@end
