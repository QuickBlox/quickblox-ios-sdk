//
//  STKAnalyticService.m
//  StickerFactory
//
//  Created by Vadim Degterev on 30.06.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "STKAnalyticService.h"
#import <UIKit/UIKit.h>
#import "STKStatistic.h"
#import "NSManagedObjectContext+STKAdditions.h"
#import "STKAnalyticsAPIClient.h"
#import "NSManagedObject+STKAdditions.h"
#import <GAI.h>
#import <GAIDictionaryBuilder.h>
#import <GAIFields.h>
#import "STKApiKeyManager.h"
#import "STKUUIDManager.h"

//Categories
NSString *const STKAnalyticMessageCategory = @"message";
NSString *const STKAnalyticStickerCategory = @"sticker";
NSString *const STKAnalyticPackCategory = @"pack";

//Actions
NSString *const STKAnalyticActionCheck = @"check";
NSString *const STKAnalyticActionInstall = @"install";

//labels
NSString *const STKStickersCountLabel = @"Stickers count";
NSString *const STKEventsCountLabel = @"Events count";


//Used with weak
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
static const NSInteger kMemoryCacheObjectsCount = 20;
#pragma clang diagnostic pop


@interface STKAnalyticService()

@property (assign, nonatomic) NSInteger objectCounter;
@property (strong, nonatomic) NSManagedObjectContext *backgroundContext;
@property (strong, nonatomic) STKAnalyticsAPIClient *analyticsApiClient;
@property (strong, nonatomic) id<GAITracker> tracker;

@property (assign, nonatomic) NSInteger stickersEventCounter;
@property (assign, nonatomic) NSInteger messageEventCounter;

@end

@implementation STKAnalyticService

#pragma mark - Init

+ (instancetype) sharedService {
    static STKAnalyticService *service = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[STKAnalyticService alloc] init];
    });
    return service;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.analyticsApiClient = [STKAnalyticsAPIClient new];
        
        [GAI sharedInstance].trackUncaughtExceptions = YES;
        
        [GAI sharedInstance].dispatchInterval = 60;
        
        [[GAI sharedInstance].logger setLogLevel:kGAILogLevelVerbose];
        
#if DEBUG
        [GAI sharedInstance].dryRun = YES;
#endif
        self.tracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-1113296-76"];
        
        //Custom dimensions
        [self.tracker set:[GAIFields customDimensionForIndex:1] value:[STKApiKeyManager apiKey]];
        [self.tracker set:[GAIFields customDimensionForIndex:2] value:[STKUUIDManager generatedDeviceToken]];
        [self.tracker set:[GAIFields customDimensionForIndex:3] value:[[NSBundle mainBundle] bundleIdentifier]];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillResignActive:)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillTerminateNotification:)
                                                     name:UIApplicationWillTerminateNotification object:nil];
        
    }
    return self;
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
}

#pragma mark - Events

- (void)sendEventWithCategory:(NSString*)category
                       action:(NSString*)action
                        label:(NSString*)label
                        value:(NSNumber*)value
{
    
#ifndef DEBUG
    __weak typeof(self) weakSelf = self;
    [self.backgroundContext performBlock:^{
        
        STKStatistic *statistic = nil;
        
        if ([category isEqualToString:STKAnalyticMessageCategory]) {
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[STKStatistic entityName]];
            request.fetchLimit = 1;
            
            NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:STKStatisticAttributes.label ascending:YES];
            request.sortDescriptors = @[sortDescriptor];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"label == %@", label];
            request.predicate = predicate;
            
            NSArray *objects = [weakSelf.backgroundContext executeFetchRequest:request error:nil];
            
            statistic = objects.firstObject;
            
            NSInteger tempValue = statistic.value.integerValue;
            tempValue += value.integerValue;
            statistic.value = @(tempValue);
        }
        
        if (!statistic) {
            statistic = [NSEntityDescription insertNewObjectForEntityForName:[STKStatistic entityName] inManagedObjectContext:weakSelf.backgroundContext];
            statistic.value = value;
            [weakSelf sendGoogleAnalyticsEventWithCategory:category action:action label:label value:value];
        }
        

        //TODO: REFACTORING

        statistic.category = category;

        statistic.timeValue = ((NSInteger)[[NSDate date] timeIntervalSince1970]);
        
        if ([statistic.category isEqualToString:STKAnalyticStickerCategory]) {
            statistic.label = [NSString stringWithFormat:@"[[%@_%@]]", action, label];
            statistic.action = @"use";
            
        } else {
            statistic.action = action;
            statistic.label = label;
        }
        NSError *error = nil;
        weakSelf.objectCounter++;
        if (weakSelf.objectCounter == kMemoryCacheObjectsCount) {
            [weakSelf.backgroundContext save:&error];
            weakSelf.objectCounter = 0;
        }
    }];
    
#endif
    
}

#pragma mark - Google analytic

- (void) sendGoogleAnalyticsEventWithCategory:(NSString*)category
                                       action:(NSString*)action
                                        label:(NSString*)label
                                        value:(NSNumber*)value
{
    GAIDictionaryBuilder *builder = [GAIDictionaryBuilder createEventWithCategory:category action:action label:label value:value];
    NSDictionary*buildedDictionary = [builder build];
    [self.tracker send:buildedDictionary];

}



#pragma mark - Notifications

- (void)applicationWillResignActive:(NSNotification*) notification {
    
    [self sendEventsFromDatabase];
    
}

- (void) applicationWillTerminateNotification:(NSNotification*) notification {
    
    [self sendEventsFromDatabase];
    
}

#pragma mark - Sending

- (void) sendEventsFromDatabase {
    
    __weak typeof(self) weakSelf = self;

    if (self.backgroundContext.hasChanges) {
        [self.backgroundContext performBlockAndWait:^{
            NSError *error = nil;
            [weakSelf.backgroundContext save:&error];
        }];
    }
    
    NSArray *events = [STKStatistic stk_findAllInContext:self.backgroundContext];
    
    for (STKStatistic *statistic in events) {
        if ([statistic.category isEqualToString:STKAnalyticMessageCategory]) {
            [self sendGoogleAnalyticsEventWithCategory:statistic.category action:statistic.action label:statistic.label value:statistic.value];
        }

    }
    
    //Sending analytics
    [[GAI sharedInstance] dispatch];
    
    [self.analyticsApiClient sendStatistics:events success:^(id response) {
        
        for (id object in events) {
            [weakSelf.backgroundContext deleteObject:object];
        }
        [weakSelf.backgroundContext save:nil];
        
    } failure:^(NSError *error) {
        
        NSLog(@"Failed to send events");
        
    }];
    
}


#pragma mark - Properties

- (NSManagedObjectContext *)backgroundContext {
    if (!_backgroundContext) {
        _backgroundContext = [NSManagedObjectContext stk_backgroundContext];
    }
    return _backgroundContext;
}


@end
