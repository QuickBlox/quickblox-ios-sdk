//
//  QBApplicationRedelegate.h
//  Core
//

//  Copyright 2011 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol UIApplicationDelegate42<UIApplicationDelegate>

@optional
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;

@end


@interface QBApplicationRedelegate : NSObject<UIApplicationDelegate> {
	NSObject<UIApplicationDelegate42> *delegate;
    
}
@property (nonatomic, retain) NSObject<UIApplicationDelegate42> *delegate; // We mustn't release it

+ (QBApplicationRedelegate *)redelegateCurrentApplication;
+ (void) redelegateBackCurrentApplication;

@end
