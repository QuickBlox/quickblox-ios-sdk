//
//  StatsView.m
//  sample-videochat-webrtc
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

#import "StatsView.h"

static NSString * const kStatsReportPlaceholderText = @"Loading stats report...";

@implementation StatsView {
    UILabel *_statsLabel;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self != nil) {
        
        _statsLabel = [[UILabel alloc] initWithFrame:frame];
        _statsLabel.text = kStatsReportPlaceholderText;
        _statsLabel.numberOfLines = 0;
        _statsLabel.font = [UIFont fontWithName:@"Roboto" size:12];
        _statsLabel.adjustsFontSizeToFitWidth = YES;
        _statsLabel.minimumScaleFactor = 0.6;
        _statsLabel.textColor = [UIColor greenColor];
        [self addSubview:_statsLabel];
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:.6];
    }
    return self;
}

- (void)setStats:(NSString *)stats {
    if (stats == nil) {
        stats = kStatsReportPlaceholderText;
    }
    _statsLabel.text = stats;
}

- (void)layoutSubviews {
    _statsLabel.frame = self.bounds;
}

- (void)setHidden:(BOOL)hidden {
    
    if (hidden) {
        
        [self setStats:nil];
    }
    
    [super setHidden:hidden];
}

@end
