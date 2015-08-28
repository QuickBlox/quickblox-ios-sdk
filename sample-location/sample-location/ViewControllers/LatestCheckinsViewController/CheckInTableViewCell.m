//
//  CheckInTableViewCell.m
//  sample-location
//
//  Created by Quickblox Team on 6/14/14.
//  Copyright (c) 2015 QuickBlox. All rights reserved.
//

#import "CheckInTableViewCell.h"

@interface CheckInTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *checkinsLabel;

@end

@implementation CheckInTableViewCell

- (void)configureWithGeoData:(QBLGeoData *)geoData
{
    self.nameLabel.text = geoData.user.login;
    self.checkinsLabel.text = geoData.status;
}

@end
