//
//  CallActionsBar.m
//  sample-videochat-webrtc
//
//  Created by Injoit on 15.08.2021.
//  Copyright © 2021 QuickBlox Team. All rights reserved.
//

#import "CallActionsBar.h"
#import "ActionButton.h"
#import "CallAction.h"

const CGRect kButtonRect = {0, 0, 56, 76};

@interface CallActionsBar()
//MARK: - Properties
@property (strong, nonatomic) NSMutableArray<CallAction *>*buttons;

@end

@implementation CallActionsBar
//MARK: - Life Cycle
- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.buttons = [NSMutableArray array];
        [self setBackgroundImage:[[UIImage alloc] init]
              forToolbarPosition:UIToolbarPositionAny
                      barMetrics:UIBarMetricsDefault];
        [self setShadowImage:[[UIImage alloc] init]
          forToolbarPosition:UIToolbarPositionAny];
        self.backgroundColor = UIColor.clearColor;
    }
    return self;
}

//MARK: - Public Methods
- (void)clear {
    [self.buttons removeAllObjects];
    [self setItems:@[]];
}

- (void)setupWithActions:(NSArray<CallAction *> *)actions {
    NSMutableDictionary *oldButtons = [NSMutableDictionary dictionary];
    if (self.buttons.count > 0) {
        for (int i = 0; i < self.buttons.count; i++) {
            CallAction *action = self.buttons[i];
            oldButtons[@(action.button.tag)] = action;
        }
    }
    [self.buttons removeAllObjects];
    
    
    [self setItems:@[]];
    NSMutableArray *items = [NSMutableArray array];
    UIBarButtonItem *fs =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                  target:nil
                                                  action:nil];
    [items addObject:fs];
    for (CallAction *actionType in actions) {
        ActionButton *button = [self createButtonWithType:actionType];
        [button addTarget:self
                   action:@selector(pressButton:)
         forControlEvents:UIControlEventTouchUpInside];
        if (oldButtons.count > 0 && oldButtons[@(actionType.typeAction)]) {
            CallAction *oldActionType = oldButtons[@(actionType.typeAction)];
            button.pressed = oldActionType.button.pressed;
            actionType.action = oldActionType.action;
        }
        actionType.button = button;
        [self.buttons addObject:actionType];
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
        [items addObject:item];
        [items addObject:fs];
    }
    [self setItems:items.copy];
}

- (void)select:(BOOL)selected type:(CallActionType)type {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"button.tag == %ld", type];
    CallAction *action = [self.buttons filteredArrayUsingPredicate:predicate].firstObject;
    if (!action || action.button.pressed == selected) {
        return;
    }
    action.button.pressed = selected;
}

- (BOOL)isSelected:(CallActionType)type {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"button.tag == %ld", type];
    CallAction *action = [self.buttons filteredArrayUsingPredicate:predicate].firstObject;
    if (action.button.tag == type) {
        return action.button.pressed;
    }
    return NO;
}

- (void)setUserInteractionEnabled:(BOOL)enabled type:(CallActionType)type {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"button.tag == %ld", type];
    CallAction *action = [self.buttons filteredArrayUsingPredicate:predicate].firstObject;
    if (!action) {
        return;
    }
    action.button.userInteractionEnabled = enabled;
}

- (void)pressButton:(ActionButton *)button {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"button.tag == %ld", button.tag];
    CallAction *actionType = [self.buttons filteredArrayUsingPredicate:predicate].firstObject;
    if (!actionType) {
        return;
    }
    void(^action)(ActionButton *sender) = actionType.action;
    action(button);
}

//MARK: - Private Methods
- (ActionButton *)createButtonWithType:(CallAction *)action {
    ActionButton *button = [[ActionButton alloc] initWithFrame:kButtonRect];
    
    switch (action.typeAction) {
        case CallActionAudio:
            button.selectedTitle = @"Unmute";
            button.unSelectedTitle = @"Mute";
            button.pushed = NO;
            button.tag = CallActionAudio;
            button.iconView = [self iconViewWithNormalImage:@"mute_on_ic"
                                           highlightedImage:@"mic_off"];
            break;
        case CallActionVideo:
            button.selectedTitle = @"Cam on";
            button.unSelectedTitle = @"Cam off";
            button.pushed = NO;
            button.tag = CallActionVideo;
            button.iconView = [self iconViewWithNormalImage:@"camera_on_ic"
                                           highlightedImage:@"cam_off"];
            break;
        case CallActionSpeaker:
            button.selectedTitle = @"Mic";
            button.unSelectedTitle = @"Speaker";
            button.pushed = YES;
            button.tag = CallActionSpeaker;
            button.iconView = [self iconViewWithNormalImage:@"speaker"
                                           highlightedImage:@"speaker_off"];
            break;
        case CallActionDecline:
            button.selectedTitle = @"End call";
            button.unSelectedTitle = @"End call";
            button.pushed = YES;
            button.tag = CallActionDecline;
            button.iconView = [self iconViewWithNormalImage:@"decline-ic"
                                           highlightedImage:@"decline-ic"];
            break;
        case CallActionShare:
            button.selectedTitle = @"Stop sharing";
            button.unSelectedTitle = @"Screen share";
            button.tag = CallActionShare;
            button.iconView = [self iconViewWithNormalImage:@"screensharing_ic"
                                           highlightedImage:@"screenshare_selected"];
            break;
        case CallActionSwitchCamera:
            button.selectedTitle = @"Swap cam";
            button.unSelectedTitle = @"Swap cam";
            button.pushed = YES;
            button.tag = CallActionSwitchCamera;
            button.iconView = [self iconViewWithNormalImage:@"switchCamera"
                                           highlightedImage:@"abort_swap"];
            break;
    }
    return button;
}

- (UIImageView *)iconViewWithNormalImage:(NSString *)normalImage
                        highlightedImage:(NSString *)selectedImage {
    UIImage *icon = [UIImage imageNamed:normalImage];
    UIImage *selectedIcon = [UIImage imageNamed:selectedImage];
    UIImageView *iconView = [[UIImageView alloc] initWithImage:icon
                                              highlightedImage:selectedIcon];
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    return iconView;
}

@end
