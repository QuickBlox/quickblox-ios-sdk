//
//  QMBaseService.m
//  QMServices
//
//  Created by Andrey Ivanov on 04.08.14.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMBaseService.h"

#import "QMSLog.h"


@interface QMBaseService() <QMDeferredQueueManagerDelegate>

@property (weak, nonatomic) id <QMServiceManagerProtocol> serviceManager;

@property (strong, nonatomic, readwrite) QMDeferredQueueManager *deferredQueueManager;

@end

@implementation QMBaseService

- (instancetype)initWithServiceManager:(id<QMServiceManagerProtocol>)serviceManager {
    
    self = [super init];
    if (self) {
        self.serviceManager = serviceManager;
        QMSLog(@"Init - %@ service...", NSStringFromClass(self.class));
        [self serviceWillStart];
    }
    return self;
}

- (void)serviceWillStart {
    
}

- (QMDeferredQueueManager *)deferredQueueManager {
    
    static QMDeferredQueueManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        manager = [[QMDeferredQueueManager alloc] init];
        [manager addDelegate:self];
    });
    
    return manager;
}

#pragma mark - QMMemoryStorageProtocol

- (void)free {
    
}

@end
