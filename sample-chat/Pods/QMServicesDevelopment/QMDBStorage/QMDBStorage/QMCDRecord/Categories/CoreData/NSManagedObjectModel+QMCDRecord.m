//
//  NSManagedObjectModel+QMCDRecord.m
//
//  Created by Injoit on 3/11/10.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import "NSManagedObjectModel+QMCDRecord.h"

@implementation NSManagedObjectModel (QMCDRecord)

+ (NSManagedObjectModel *)QM_managedObjectModelAtURL:(NSURL *)url;
{
    return [[NSManagedObjectModel alloc] initWithContentsOfURL:url];
}

+ (NSManagedObjectModel *)QM_mergedObjectModelFromMainBundle;
{
    return [self mergedModelFromBundles:nil];
}

+ (NSManagedObjectModel *)QM_newModelNamed:(NSString *)modelName inBundleNamed:(NSString *)bundleName;
{
    NSString *path = [[NSBundle mainBundle] pathForResource:[modelName stringByDeletingPathExtension]
                                                     ofType:[modelName pathExtension]
                                                inDirectory:bundleName];
    NSURL *modelUrl = [NSURL fileURLWithPath:path];

    NSManagedObjectModel *mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelUrl];

    return mom;
}

+ (NSManagedObjectModel *)QM_managedObjectModelNamed:(NSString *)modelFileName;
{
    NSString *path = [[NSBundle mainBundle] pathForResource:[modelFileName stringByDeletingPathExtension]
                                                     ofType:[modelFileName pathExtension]];
    NSURL *momURL = [NSURL fileURLWithPath:path];

    NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:momURL];
    return model;
}

@end
