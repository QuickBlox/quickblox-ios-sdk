//
//  RootViewControllerSegue.m
//  sample-conference-videochat
//
//  Created by Injoit on 12/10/15.
//  Copyright © 2015 QuickBlox Team. All rights reserved.
//

#import "RootViewControllerSegue.h"
#import "AppDelegate.h"

@implementation RootViewControllerSegue

- (void)perform {
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.window.rootViewController = self.destinationViewController;
}

@end
