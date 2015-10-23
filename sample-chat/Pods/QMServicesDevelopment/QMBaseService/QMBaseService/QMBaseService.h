//
//  QMBaseService.h
//  QMServices
//
//  Created by Andrey Ivanov on 04.08.14.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMMemoryStorageProtocol.h"
#import "QMServiceManagerProtocol.h"

@interface QMBaseService : NSObject <QMMemoryStorageProtocol>

/**
 *  Service manager reference.
 */
@property (weak, nonatomic, readonly) id <QMServiceManagerProtocol> serviceManager;

- (id)init __attribute__((unavailable("init is not a supported initializer for this class.")));

- (instancetype)initWithServiceManager:(id<QMServiceManagerProtocol>)serviceManager;

/**
 *  Called when the servise is will begin start
 */
- (void)serviceWillStart;

@end
