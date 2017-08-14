#import "_CDContactListItem.h"

@class QBContactListItem;

@interface CDContactListItem : _CDContactListItem

- (QBContactListItem *)toQBContactListItem;
- (void)updateWithQBContactListItem:(QBContactListItem *)contactListItem;

@end

@interface NSArray (CDContactListItemConverter)

- (NSArray<QBContactListItem *> *)toQBContactListItems;

@end
