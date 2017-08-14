//
//  QMCDRecordStack.m
//  QMCDRecord
//
//  Created by Injoit on 9/14/13.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import "QMCDRecordStack.h"

#import "NSManagedObjectContext+QMCDRecord.h"
#import "NSPersistentStore+QMCDRecord.h"
#import "NSManagedObjectModel+QMCDRecord.h"
#import "QMCDRecordLogging.h"

@interface QMCDRecordStack ()

@property (nonatomic, strong) NSManagedObjectContext *privateWriterContext;
@property (nonatomic, strong) NSManagedObjectContext *mainContext;


@property (nonatomic, strong) NSNotificationCenter *applicationWillTerminate;
@property (nonatomic, strong) NSNotificationCenter *applicationWillResignActive;
@property (nonatomic, copy, readwrite) NSURL *storeURL;

@end

@implementation QMCDRecordStack

- (void)dealloc {
    
    [self reset];
}

- (NSString *)description {
    
    NSMutableString *status = [NSMutableString stringWithString:@"\n"];
    
    [status appendFormat:@"Stack:           %@ (%p)\n", NSStringFromClass([self class]), self];
    [status appendFormat:@"Model:           %@\n", [self.model entityVersionHashesByName]];
    [status appendFormat:@"Coordinator:     %@\n", self.coordinator];
    [status appendFormat:@"Store:           %@\n", self.store];
    [status appendFormat:@"Context:         %@\n", [self.privateWriterContext QM_description]];
    
    return status;
}

+ (instancetype) stack {
    
    return [[self alloc] init];
}

+ (instancetype)stackWithStoreNamed:(NSString *)name
                              model:(NSManagedObjectModel *)model
         applicationGroupIdentifier:(NSString *)appGroupIdentifier {
    
    NSDictionary *options =
    [NSPersistentStore QM_migrationOptionsForStoreName:name
                            applicationGroupIdentifier:appGroupIdentifier];
    
    return [[self alloc] initWithStoreAtURL:options[QMCDRecordTargetURLKey]
                                      model:model
                                    options:options];
}

+ (instancetype)stackWithStoreNamed:(NSString *)name
                              model:(NSManagedObjectModel *)model {
    return [[self class] stackWithStoreNamed:name
                                       model:model
                  applicationGroupIdentifier:nil];
}

- (instancetype)initWithStoreAtURL:(NSURL *)url
                             model:(NSManagedObjectModel *)model
                           options:(NSDictionary *)options {
    
    NSParameterAssert(url);
    self = [super init];
    
    if (self) {
        
        _storeOptions = options;
        _storeURL = url;
        _model = model;
        
        [self loadStack];
    }
    
    return self;
}

- (NSDictionary *)defaultStoreOptions {
    
    NSDictionary *options =
    @{
      QMCDRecordShouldDeletePersistentStoreOnModelMismatchKey : @(self.shouldDeletePersistentStoreOnModelMismatch) };
    
    return options;
}

- (NSPersistentStoreCoordinator *)createCoordinator {
    
    return [self createCoordinatorWithOptions:[self defaultStoreOptions]];
}

- (NSPersistentStoreCoordinator *) createCoordinatorWithOptions:(NSDictionary *)options {
    
    QMCDLogVerbose(@"Loading Store at URL: %@", self.storeURL);
    NSPersistentStoreCoordinator *coordinator =
    [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self model]];
    
    NSMutableDictionary *storeOptions = [[self defaultStoreOptions] mutableCopy];
    [storeOptions addEntriesFromDictionary:self.storeOptions];
    
    [coordinator QM_addSqliteStoreAtURL:self.storeURL withOptions:storeOptions];
    
    return coordinator;
}

- (void)loadStack {
    
    NSManagedObjectContext *context = [self privateWriterContext];
    NSString *stackType = NSStringFromClass([self class]);
#pragma unused(stackType)
    NSAssert(context, @"No NSManagedObjectContext for stack [%@]", stackType);
    NSAssert([self model], @"No NSManagedObjectModel loaded for stack [%@]", stackType);
    NSAssert([self store], @"No NSPersistentStore initialized for stack [%@]", stackType);
    NSAssert([self coordinator], @"No NSPersistentStoreCoodinator initialized for stack [%@]", stackType);
#ifndef DEBUG
    if (context == nil) {
        QMCDLogError(@"No NSManagedObjectContext for stack [%@]", stackType);
    }
#endif
}

- (void)setModelFromClass:(Class)modelClass {
    
    NSBundle *bundle = [NSBundle bundleForClass:modelClass];
    NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:[NSArray arrayWithObject:bundle]];
    [self setModel:model];
}

- (void)setModelNamed:(NSString *)modelName {
    
    NSManagedObjectModel *model = [NSManagedObjectModel QM_managedObjectModelNamed:modelName];
    [self setModel:model];
}

- (void)reset {
    
    self.privateWriterContext = nil;
    self.model = nil;
    self.coordinator = nil;
    self.store = nil;
}

- (NSManagedObjectContext *)privateWriterContext {
    
    if (!_privateWriterContext) {
        
        _privateWriterContext =
        [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        
        _privateWriterContext.persistentStoreCoordinator = self.coordinator;
        _privateWriterContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
        [_privateWriterContext QM_setWorkingName:[NSString stringWithFormat:@"Private Queue Context (%@)", [self stackName]]];
    }
    
    return _privateWriterContext;
}

- (NSString *)stackName {
    
    if (_stackName == nil) {
        _stackName = [NSString stringWithFormat:@"%@ [%p]", NSStringFromClass([self class]), self];
    }
    return _stackName;
}

- (NSManagedObjectModel *)model {
    
    if (_model == nil) {
        _model = [NSManagedObjectModel QM_mergedObjectModelFromMainBundle];
    }
    return _model;
}

- (NSPersistentStoreCoordinator *)coordinator {
    
    if (_coordinator == nil)
    {
        _coordinator = [self createCoordinator];
        _store = [[_coordinator persistentStores] lastObject];
    }
    return _coordinator;
}

//MARK: - Handle System Notifications

- (BOOL)saveOnApplicationWillResignActive {
    
    return self.applicationWillResignActive != nil;
}

- (void)setSaveOnApplicationWillResignActive:(BOOL)save {
    
    [self setApplicationWillTerminate:save ? [NSNotificationCenter defaultCenter] : nil];
}

-(void)setApplicationWillResignActive:(NSNotificationCenter *)applicationWillResignActive {
    
    NSString *notificationName = nil;
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
    notificationName = UIApplicationWillTerminateNotification;
#elif TARGET_OS_MAC
    notificationName = NSApplicationWillTerminateNotification;
#endif
    [_applicationWillResignActive removeObserver:self
                                            name:notificationName
                                          object:nil];
    _applicationWillResignActive = applicationWillResignActive;
    [_applicationWillResignActive addObserver:self
                                     selector:@selector(autoSaveHandle:)
                                         name:notificationName
                                       object:nil];
}

- (BOOL)saveOnApplicationWillTerminate {
    
    return self.applicationWillTerminate != nil;
}

- (void) setSaveOnApplicationWillTerminate:(BOOL)save {
    
    [self setApplicationWillTerminate:save ? [NSNotificationCenter defaultCenter] : nil];
}

- (void)setApplicationWillTerminate:(NSNotificationCenter *)willTerminate {
    
    NSString *notificationName = nil;
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
    notificationName = UIApplicationWillTerminateNotification;
#elif TARGET_OS_MAC
    notificationName = NSApplicationWillTerminateNotification;
#endif
    [_applicationWillTerminate removeObserver:self
                                         name:notificationName
                                       object:nil];
    _applicationWillTerminate = willTerminate;
    [_applicationWillTerminate addObserver:self
                                  selector:@selector(autoSaveHandle:)
                                      name:notificationName
                                    object:nil];
}

- (void)autoSaveHandle:(NSNotification *)notification {
    
    [self.privateWriterContext QM_saveToPersistentStoreAndWait];
}

@end
