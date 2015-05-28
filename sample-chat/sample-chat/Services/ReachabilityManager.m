//
//  ReachabilityManager.m
//  sample-chat
//
//  Created by Anton Sokolchenko on 5/28/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import "ReachabilityManager.h"
#import "Reachability.h"

@interface ReachabilityManager()
@property (nonatomic, strong) Reachability *reach;
@end

@implementation ReachabilityManager

+ (instancetype)instance {
	static id sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] init];
	});
	return sharedInstance;
}

- (instancetype)init {
	self = [super init];
	if( self ) {
		self.reach = [Reachability reachabilityForInternetConnection];
	}
	return self;
}

- (void)startNotifier {
	[self.reach startNotifier];
}

- (void)stopNotifier {
	[self.reach stopNotifier];
}

- (BOOL)isReachable {
	return [self.reach isReachable];
}


@end
