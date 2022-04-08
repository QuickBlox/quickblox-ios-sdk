//
//  UITableView+Chat.m
//  sample-chat
//
//  Created by Injoit on 04.02.2020.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import "UITableView+Chat.h"

@implementation UITableView (Chat)
- (void)setupEmptyViewWithAlert:(NSString *)alert {
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(self.center.x, self.center.y, self.bounds.size.width, self.bounds.size.height)];

    UILabel *alertLabel = [[UILabel alloc] init];
    alertLabel.textColor = [UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:1.0f];
    alertLabel.font = [UIFont systemFontOfSize:17.0f weight:UIFontWeightRegular];
    [backgroundView addSubview:alertLabel];
    alertLabel.text = alert;
    alertLabel.numberOfLines = 1;
    alertLabel.textAlignment = NSTextAlignmentCenter;
       
    alertLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [alertLabel.topAnchor constraintEqualToAnchor:backgroundView.topAnchor constant:28.0f].active = YES;
    [alertLabel.centerXAnchor constraintEqualToAnchor:backgroundView.centerXAnchor].active = YES;
       
    self.backgroundView = backgroundView;
       
   }

- (void)removeEmptyView {
    self.backgroundView = nil;
   }
   
- (void)addShadowWithColor:(UIColor *)shadowColor {
    self.backgroundColor = UIColor.clearColor;
    self.layer.masksToBounds = YES;
    self.layer.shadowOffset = CGSizeMake(0, 12.0f);
    self.layer.shadowColor = shadowColor.CGColor;
    self.layer.shadowOpacity = 1.0f;
    self.layer.shadowRadius = 11.0f;
   }
@end
