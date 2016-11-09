//
//  QMBaseService.h
//  QMServices
//
//  Created by Andrey Ivanov on 04.08.14.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quickblox/QBMulticastDelegate.h>
#import <Bolts/Bolts.h>

#import "QMMemoryStorageProtocol.h"
#import "QMServiceManagerProtocol.h"
#import "QMDeferredQueueManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface QMBaseService : NSObject <QMMemoryStorageProtocol>

/**
 *  Service manager reference.
 */
@property (weak, nonatomic, readonly, nullable) id <QMServiceManagerProtocol> serviceManager;
@property (strong, nonatomic, readonly) QMDeferredQueueManager *deferredQueueManager;

- (id)init NS_UNAVAILABLE;

- (instancetype)initWithServiceManager:(id<QMServiceManagerProtocol>)serviceManager;

/**
 *  Called when the servise is will begin start
 */
- (void)serviceWillStart;

@end

NS_ASSUME_NONNULL_END
