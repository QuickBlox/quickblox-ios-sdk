//
//  CallTimerView.m
//  sample-videochat-webrtc
//
//  Created by Injoit on 28.09.2021.
//  Copyright © 2021 QuickBlox Team. All rights reserved.
//

#import "CallTimerView.h"
#import "UILabel+Videochat.h"

static const NSTimeInterval kRefreshTimeInterval = 1.0f;

@interface CallTimerView()
//MARK: - IBOutlets
//MARK: - Properties
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSTimeInterval duration;
@end

@implementation CallTimerView
//MARK: - Life Cycle
- (void)awakeFromNib {
    [super awakeFromNib];
    
    _duration = 0.0f;
    _isActive = NO;
    [self setRoundedLabelWithCornerRadius: 10.0f];
    self.hidden = YES;
}

- (void)setIsActive:(BOOL)isActive {
    _isActive = isActive;
    _isActive == YES ? [self activate] : [self deactivate];
}

//MARK: - Private Methods
- (void)activate {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:kRefreshTimeInterval
                                                  target:self
                                                selector:@selector(refreshCallTime)
                                                userInfo:nil
                                                 repeats:YES];
    self.hidden = NO;
    [self refreshCallTime];
}

- (void)deactivate {
    if (!self.timer) {
        return;
    }
    [self.timer invalidate];
    self.timer = nil;
    self.hidden = YES;
    [self removeFromSuperview];
}

- (void)refreshCallTime {
    self.duration += kRefreshTimeInterval;
    NSString *time = [self stringWithTimeDuration:self.duration];
    self.text = time;
}

- (NSString *)stringWithTimeDuration:(NSTimeInterval )timeDuration {
    NSInteger hours = timeDuration / 3600;
    NSInteger minutes = timeDuration / 60;
    NSInteger seconds = (NSInteger)timeDuration % 60;
    
    NSString *timeStr = @"";
    
    if (hours > 0) {
        NSInteger minutes = (timeDuration - 3600 * hours) / 60;
        timeStr = [NSString stringWithFormat:@"%ld:%ld:%02ld", (long)hours, (long)minutes, (long)seconds];
    } else {
        timeStr = [NSString stringWithFormat:@"%ld:%02ld", (long)minutes, (long)seconds];
    }
    return timeStr;
}


@end
