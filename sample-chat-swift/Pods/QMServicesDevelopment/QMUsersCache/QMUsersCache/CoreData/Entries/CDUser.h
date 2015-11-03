#import "_CDUser.h"

@interface CDUser : _CDUser {}

- (QBUUser *)toQBUUser;
- (void)updateWithQBUser:(QBUUser *)user;

@end
