//
//  QMBaseService.m
//  QMServices
//
//  Created by Andrey Ivanov on 04.08.14.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMBaseService.h"
#import "QMSLog.h"

BFTask *make_task(QMTaskSourceBlock b) {
    
    BFTaskCompletionSource *source =
    [BFTaskCompletionSource taskCompletionSource];
    if (b) { b(source); }
    
    return source.task;
}

@interface QMBaseService()

@property (weak, nonatomic) id <QMServiceManagerProtocol> serviceManager;

@end

@implementation QMBaseService

- (instancetype)initWithServiceManager:(id<QMServiceManagerProtocol>)serviceManager {
    
    self = [super init];
    if (self) {
        
        QMSLog(@"Init - %@ service...", NSStringFromClass(self.class));
        _serviceManager = serviceManager;
        [self serviceWillStart];
    }
    return self;
}

- (void)serviceWillStart {
    
}

//MARK: - QMMemoryStorageProtocol

- (void)free {
    
}

@end
