#import "CDContactListItem.h"

@implementation CDContactListItem

- (QBContactListItem *)toQBContactListItem {
    
    QBContactListItem *contactListItem = [[QBContactListItem alloc] init];
    contactListItem.userID = self.userID.integerValue;
    contactListItem.subscriptionState = self.subscriptionState.intValue;
    contactListItem.online = NO;
    
    return contactListItem;
}

- (void)updateWithQBContactListItem:(QBContactListItem *)contactListItem {
    
    self.userID = @(contactListItem.userID);
    self.subscriptionState = @(contactListItem.subscriptionState);
}

- (BOOL)isEqualQBContactListItem:(QBContactListItem *)other {
    
    if (self.userID.integerValue != other.userID) {
        return NO;
    }
    else if (self.subscriptionState.integerValue != other.subscriptionState) {
        return NO;
    }else {
        return YES;
    }
}

@end
