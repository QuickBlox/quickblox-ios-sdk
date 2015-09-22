//
//  QMCDRecord+Actions.m
//  QMCDRecord
//
//  Created by Injoit on 9/15/13.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import "QMCDRecord+Actions.h"
#import "QMCDRecordStack+Actions.h"

@implementation QMCDRecord (Actions)

+ (void) saveWithBlock:(void(^)(NSManagedObjectContext *localContext))block;
{
    [[QMCDRecordStack defaultStack] saveWithBlock:block];
}

+ (void) saveWithBlock:(void(^)(NSManagedObjectContext *localContext))block completion:(MRSaveCompletionHandler)completion;
{
    [[QMCDRecordStack defaultStack] saveWithBlock:block completion:completion];
}

+ (void) saveWithBlock:(void (^)(NSManagedObjectContext *))block identifier:(NSString *)contextWorkingName completion:(MRSaveCompletionHandler)completion;
{
    [[QMCDRecordStack defaultStack] saveWithBlock:block identifier:contextWorkingName completion:completion];
}

+ (void) saveWithIdentifier:(NSString *)identifier block:(void(^)(NSManagedObjectContext *))block;
{
    [[QMCDRecordStack defaultStack] saveWithIdentifier:identifier block:block];
}

+ (BOOL) saveWithBlockAndWait:(void(^)(NSManagedObjectContext *localContext))block;
{
    return [self saveWithBlockAndWait:block error:nil];
}

+ (BOOL) saveWithBlockAndWait:(void(^)(NSManagedObjectContext *localContext))block error:(NSError **)error
{
    return [[QMCDRecordStack defaultStack] saveWithBlockAndWait:block error:error];
}

@end
