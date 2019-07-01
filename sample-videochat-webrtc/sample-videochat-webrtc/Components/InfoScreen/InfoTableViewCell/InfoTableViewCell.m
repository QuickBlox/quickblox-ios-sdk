//
//  InfoTableViewCell.m
//  sample-videochat-webrtc
//
//  Created by Injoit on 12/30/18.
//  Copyright © 2018 Quickblox. All rights reserved.
//

#import "InfoTableViewCell.h"

@implementation InfoTableViewCell

- (void)applyInfo:(InfoModel*)model
{
    self.titleInfoLabel.text = model.title;
    self.descriptInfoLabel.text = model.info;
}

@end
