//
//  CheckInTableViewCell.m
//  SimpleSample-location_users-ios
//
//  Created by Andrey Moskvin on 6/14/14.
//
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
