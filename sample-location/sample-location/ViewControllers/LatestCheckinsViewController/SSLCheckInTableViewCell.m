//
//  CheckInTableViewCell.m
//  SimpleSample-location_users-ios
//
//  Created by Andrey Moskvin on 6/14/14.
//
//

#import "SSLCheckInTableViewCell.h"

@interface SSLCheckInTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *checkinsLabel;

@end

@implementation SSLCheckInTableViewCell

- (void)configureWithGeoData:(QBLGeoData *)geoData
{
    self.nameLabel.text = geoData.user.login;
    self.checkinsLabel.text = geoData.status;
}

@end
