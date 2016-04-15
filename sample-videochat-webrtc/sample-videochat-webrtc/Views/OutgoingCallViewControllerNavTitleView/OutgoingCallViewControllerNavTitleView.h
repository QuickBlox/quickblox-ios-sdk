//
//  OutgoingCallViewControllerNavTitleView.h
//  sample-videochat-webrtc
//
//  Created by Anton Sokolchenko on 2/2/16.
//  Copyright © 2016 QuickBlox Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OutgoingCallViewControllerNavTitleView : UIView

- (instancetype)initWithTopTitle:(NSString *)topTitle middleTitle:(NSString *)middleTitle frame:(CGRect)frame;

@property (nonatomic, weak) IBOutlet UILabel *toplabel;
@property (nonatomic, weak) IBOutlet UILabel *middlelabel;

@end
