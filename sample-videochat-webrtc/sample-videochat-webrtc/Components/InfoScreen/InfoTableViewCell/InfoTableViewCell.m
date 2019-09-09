//
//  InfoTableViewCell.m
//  sample-videochat-webrtc
//
//  Created by Injoit on 3/12/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "InfoTableViewCell.h"

@implementation InfoTableViewCell

- (void)applyInfo:(InfoModel*)model
{
    self.titleInfoLabel.text = model.title;
    self.descriptInfoLabel.text = model.info;
}

@end
