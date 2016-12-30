//
//  StatsView.m
//  sample-videochat-webrtc-old
//
//  Created by Vitaliy Gorbachov on 12/15/16.
//  Copyright © 2016 QuickBlox Team. All rights reserved.
//

#import "StatsView.h"

static NSString * const kQMStatsReportPlaceholderText = @"Loading stats report...";

@implementation StatsView {
    UILabel *_statsLabel;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self != nil) {
        
        _statsLabel = [[UILabel alloc] initWithFrame:frame];
        _statsLabel.text = kQMStatsReportPlaceholderText;
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
        stats = kQMStatsReportPlaceholderText;
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
