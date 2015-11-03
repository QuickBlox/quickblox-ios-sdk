#import "CDUser.h"


@interface CDUser ()

// Private interface goes here.

@end


@implementation CDUser

- (QBUUser *)toQBUUser {
    
    QBUUser *qbUser = [QBUUser user];
    
    qbUser.ID = self.id.integerValue;
    qbUser.updatedAt = self.updatedAt;
    qbUser.createdAt = self.createdAt;
    
    qbUser.externalUserID = self.externalUserID.integerValue;
    qbUser.blobID = self.blobID.integerValue;
    qbUser.facebookID = self.facebookID;
    qbUser.twitterID = self.twitterID;
    qbUser.fullName = self.fullName;
    qbUser.email = self.email;
    qbUser.login = self.login;
    qbUser.phone = self.phone;
    qbUser.website = self.website;
    
    qbUser.tags = [self.tags componentsSeparatedByString:@","].mutableCopy;
    
    qbUser.customData = self.customData;
    
    return qbUser;
}

- (void)updateWithQBUser:(QBUUser *)user {
    
    self.id = @(user.ID);
    self.updatedAt = user.updatedAt;
    self.createdAt = user.createdAt;
    self.externalUserID = @(user.externalUserID);
    self.blobID = @(user.blobID);
    
    self.facebookID = user.facebookID;
    self.twitterID = user.twitterID;
    self.fullName = user.fullName;
    self.email = user.email;
    self.login = user.login;
    self.phone = user.phone;
    self.website = user.website;
    self.tags = [user.tags componentsJoinedByString:@","];
    self.customData = user.customData;
}


@end
