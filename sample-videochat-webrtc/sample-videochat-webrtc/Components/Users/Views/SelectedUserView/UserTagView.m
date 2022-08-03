//
//  SelectedUserView.m
//  sample-videochat-webrtc
//
//  Created by Injoit on 03.08.2021.
//  Copyright © 2021 QuickBlox Team. All rights reserved.
//

#import "UserTagView.h"
#import "UIView+Videochat.h"

@interface UserTagView()
//MARK: - IBOutlets
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@end

@implementation UserTagView
//MARK: - Life Cycle
- (void)awakeFromNib {
    [super awakeFromNib];

    [self setRoundBorderEdgeColorView:4.0f
                          borderWidth:1.0f
                                color:UIColor.clearColor
                          borderColor:[UIColor colorWithRed:0.5f green:0.55f blue:0.64f alpha:1.0f]];
}

- (void)setName:(NSString *)name {
    _name = name;
    self.nameLabel.text = name;
}

//MARK: - Actions
- (IBAction)cancelButtonTapped:(UIButton *)sender {
    if (self.onCancelTapped) {
        self.onCancelTapped(self.userID.unsignedIntValue);
    }
}

@end
