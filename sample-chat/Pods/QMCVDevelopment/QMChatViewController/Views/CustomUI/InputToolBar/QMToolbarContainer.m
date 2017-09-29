//
//  QMToolbarContainer.m
//  Pods
//
//  Created by Vitaliy Gurkovsky on 3/9/17.
//
//

#import "QMToolbarContainer.h"

@interface QMToolbarContainer()

@property (strong, nonatomic) NSMutableArray *buttonsArray;
@property (strong, nonatomic) NSMutableArray *actionsArray;

@end

@implementation QMToolbarContainer

- (instancetype)init {
    
    if (self = [super init]){
        _buttonsArray = [NSMutableArray array];
        _actionsArray = [NSMutableArray array];
    }
    
    return self;
}

- (void) dealloc {
    for (UIView *view in _buttonsArray) {
        [view removeObserver:self forKeyPath:@"hidden"];
    }
}

- (void)addButton:(UIButton *)button
           action:(void(^)(UIButton *sender))action {
    
    if (action != nil) {
        
        [button addTarget:self
                   action:@selector(pressButton:)
         forControlEvents:UIControlEventTouchUpInside];
        [self.actionsArray addObject:[action copy]];
    }
    
    if ([self.buttonsArray containsObject:button]) {
        [self.buttonsArray addObject:button];
        [button addObserver:self forKeyPath:@"hidden" options:0 context:NULL];
    }
}


- (void)pressButton:(UIButton *)button {
    
    NSUInteger idx = [self.buttonsArray indexOfObject:button];
    
    void(^action)(UIButton *sender) = self.actionsArray[idx];
    action(button);
}


@end
