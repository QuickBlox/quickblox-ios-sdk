#import "CDUser.h"


@interface CDUser ()

// Private interface goes here.

@end


@implementation CDUser

- (QBUUser *)toQBUUser {
	
	QBUUser *qbUser = [QBUUser user];
	
	qbUser.ID = self.idValue;
	qbUser.updatedAt = self.updatedAt;
	qbUser.createdAt = self.createdAt;
	
    qbUser.externalUserID = self.externalUserIDValue;
    qbUser.blobID = self.blobIDValue;
	qbUser.facebookID = self.facebookID;
	qbUser.twitterID = self.twitterID;
	qbUser.fullName = self.fullName;
	qbUser.email = self.email;
	qbUser.login = self.login;
	qbUser.phone = self.phone;
	qbUser.website = self.website;
	qbUser.lastRequestAt = self.lastRequestAt;
	qbUser.customData = self.customData;
	qbUser.tags = [self.tags componentsSeparatedByString:@","].mutableCopy;
	
	return qbUser;
}

- (void)updateWithQBUser:(QBUUser *)user {
	
    self.idValue = (int32_t)user.ID;
	self.updatedAt = user.updatedAt;
	self.createdAt = user.createdAt;
	self.externalUserIDValue = (int32_t)user.externalUserID;
	self.blobIDValue = (int32_t)user.blobID;
	self.facebookID = user.facebookID;
	self.twitterID = user.twitterID;
	self.fullName = user.fullName;
	self.email = user.email;
	self.login = user.login;
	self.phone = user.phone;
	self.website = user.website;
	self.tags = [user.tags componentsJoinedByString:@","];
	self.customData = user.customData;
	self.lastRequestAt = user.lastRequestAt;
}

@end

@implementation NSArray(CDUser)

- (NSArray<QBUUser *> *)toQBUUsers {
    
    NSMutableArray<QBUUser *> *result =
    [NSMutableArray arrayWithCapacity:self.count];
    
    for (CDUser *cache in self) {
        
        QBUUser *user = [cache toQBUUser];
        [result addObject:user];
    }
    
    return [result copy];
}

@end
