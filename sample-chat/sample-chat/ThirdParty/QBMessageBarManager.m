//
//  QBMessageBarManager.m
//  sample-chat
//
//  Created by Vitaliy Gurkovsky on 5/13/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QBMessageBarManager.h"
#import "TWMessageBarManager+Private.h"



//@implementation TWMessageView
//- (CGSize)descriptionSize {
//    
//    return CGSizeMake(100.0, 20.0);
//}
//@end


@implementation QBMessageBarManager

#pragma mark - Alloc/Init

- (id)init
{
    self = [super init];
    if (self)
    {
        _maxDescriptionHeight = 60.0;
    }
    return self;
}


- (void)showMessageWithTitle:(NSString *)title description:(NSString *)description type:(TWMessageBarMessageType)type
{
     [self showMessageWithTitle:title description:description type:type duration:[TWMessageBarManager durationForMessageType:type] callback:nil];

}
@end
