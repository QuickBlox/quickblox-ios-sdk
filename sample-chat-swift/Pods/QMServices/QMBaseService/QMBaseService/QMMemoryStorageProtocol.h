//
//  QMMemoryStorageProtocol.h
//  QMServices
//
//  Created by Andrey Ivanov on 28.04.15.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol QMMemoryStorageProtocol <NSObject>

/**
 *  This method used for clean all storage data in memory
 */
- (void)free;

@end
