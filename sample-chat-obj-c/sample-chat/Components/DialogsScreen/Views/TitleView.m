//
//  TitleView.m
//  sample-chat
//
//  Created by Injoit on 1/31/20.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import "TitleView.h"

@implementation TitleView
#pragma mark - Utility
- (void)setupTitleViewWithTitle:(NSString *)title subTitle:(NSString *)subTitle {
    NSString *titleString = [NSString stringWithFormat:@"%@\n%@", title, subTitle ];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:titleString];
    
    NSRange titleRange = [titleString rangeOfString:title];
    UIFont *fontTitle = [UIFont systemFontOfSize:17.0f weight:UIFontWeightBold];
    NSDictionary *attributesTitle = @{ NSForegroundColorAttributeName:UIColor.whiteColor,
                                  NSFontAttributeName:fontTitle};
    [attrString addAttributes:attributesTitle range:titleRange];
    
    NSRange subTitleRange = [titleString rangeOfString:subTitle];
    UIFont *fontSubTitle = [UIFont systemFontOfSize:13.0f];
    NSDictionary *attributesSubTitle = @{ NSForegroundColorAttributeName:UIColor.whiteColor,
                                  NSFontAttributeName:fontSubTitle};
    [attrString addAttributes:attributesSubTitle range:subTitleRange];
    
    self.numberOfLines = 2;
    self.attributedText = attrString;
    self.textAlignment = NSTextAlignmentCenter;
    
    CGRect frame;
    frame = self.frame;
    frame.size.width = 200.0f;
    self.frame = frame;
}


@end
