//
//  SQLiteQMCDRecordStack.m
//  QMCDRecord
//
//  Created by Injoit on 9/14/13.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import "QMCDRecordStack+Private.h"
#import "SQLiteQMCDRecordStack.h"
#import "NSPersistentStoreCoordinator+QMCDRecord.h"
#import "QMCDRecordLogging.h"

@interface SQLiteQMCDRecordStack ()

@property (nonatomic, copy, readwrite) NSURL *storeURL;

@end


@implementation SQLiteQMCDRecordStack

+ (instancetype) stackWithStoreNamed:(NSString *)name
{
    return [[self alloc] initWithStoreNamed:name];
}

+ (instancetype) stackWithStoreAtURL:(NSURL *)url
{
    return [[self alloc] initWithStoreAtURL:url];
}

+ (instancetype) stackWithStoreAtPath:(NSString *)path
{
    return [[self alloc] initWithStoreAtPath:path];
}

+ (instancetype) stackWithStoreNamed:(NSString *)name model:(NSManagedObjectModel *)model
{
    return [self stackWithStoreNamed:name model:model applicationGroupIdentifier:nil];
}
+ (instancetype) stackWithStoreNamed:(NSString *)name model:(NSManagedObjectModel *)model applicationGroupIdentifier:(NSString *)appGroupIdentifier
{
    return [[self alloc] initWithStoreNamed:name model:model applicationGroupIdentifier:appGroupIdentifier];
}
+ (instancetype) stackWithStoreAtURL:(NSURL *)url model:(NSManagedObjectModel *)model
{
    return [[self alloc] initWithStoreAtURL:url model:model];
}

+ (instancetype) stackWithStoreAtPath:(NSString *)path model:(NSManagedObjectModel *)model
{
    return [[self alloc] initWithStoreAtPath:path model:model];
}

- (instancetype) init
{
    return [self initWithStoreNamed:[QMCDRecord defaultStoreName]];
}

- (instancetype) initWithStoreNamed:(NSString *)name
{
	NSURL *storeURL = [NSPersistentStore QM_fileURLForStoreName:name];
    return [self initWithStoreAtURL:storeURL];
}

- (instancetype) initWithStoreAtPath:(NSString *)path
{
    NSURL *storeURL = [NSURL fileURLWithPath:path];
    return [self initWithStoreAtURL:storeURL];
}

- (instancetype) initWithStoreAtURL:(NSURL *)url
{
    return [self initWithStoreAtURL:url model:nil];
}

- (instancetype) initWithStoreAtPath:(NSString *)path model:(NSManagedObjectModel *)model
{
    NSURL *storeURL = [NSURL fileURLWithPath:path];
    return [self initWithStoreAtURL:storeURL model:model];
}

- (instancetype) initWithStoreNamed:(NSString *)name model:(NSManagedObjectModel *)model
{
    return [self initWithStoreNamed:name model:model applicationGroupIdentifier:nil];
}

- (instancetype) initWithStoreNamed:(NSString *)name model:(NSManagedObjectModel *)model applicationGroupIdentifier:(NSString *)appGroupIdentifier
{
    NSDictionary *options = [NSPersistentStore QM_migrationOptionsForStoreName:name
                                                    applicationGroupIdentifier:appGroupIdentifier];
    return [self initWithStoreAtURL:options[QMCDRecordTargetURLKey] model:model options:options];
}

- (instancetype) initWithStoreAtURL:(NSURL *)url model:(NSManagedObjectModel *)model
{
    return [self initWithStoreAtURL:url
                              model:model
                            options:nil];
}

- (instancetype) initWithStoreAtURL:(NSURL *)url model:(NSManagedObjectModel *)model options:(NSDictionary *)options
{
    NSParameterAssert(url);
    
    self = [super init];
    
    if (self) {
        if (options != nil) {
            _storeOptions = options;
        }
        _storeURL = url;
        self.model = model;
    }
    return self;
}

- (NSDictionary *) defaultStoreOptions
{
    NSDictionary *options = @{ QMCDRecordShouldDeletePersistentStoreOnModelMismatchKey:
                                   @(self.shouldDeletePersistentStoreOnModelMismatch) };
    return options;
}

- (NSPersistentStoreCoordinator *)createCoordinator
{
    return [self createCoordinatorWithOptions:[self defaultStoreOptions]];
}

- (NSManagedObjectContext *) newConfinementContext
{
    NSManagedObjectContext *context = [super newConfinementContext];
    [context setParentContext:[self context]];
    return context;
}

- (NSPersistentStoreCoordinator *)createCoordinatorWithOptions:(NSDictionary *)options
{
    QMCDLogVerbose(@"Loading Store at URL: %@", self.storeURL);
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self model]];

    NSMutableDictionary *storeOptions = [[self defaultStoreOptions] mutableCopy];
    [storeOptions addEntriesFromDictionary:self.storeOptions];
    
    [coordinator QM_addSqliteStoreAtURL:self.storeURL withOptions:storeOptions];

    return coordinator;
}


@end
