//
//  QBCOCustomObjectAnswer.h
//  Quickblox
//
//  Created by IgorKh on 8/17/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "XmlAnswer.h"

@class QBCOCustomObject;
@class QBCOPermissionsAnswer;

@interface QBCOCustomObjectAnswer : XmlAnswer{
@private
    QBCOCustomObject *_object;
    
    NSString *currentArrayElement;
    QBCOPermissionsAnswer *permissionsAnswer;
}

@property (nonatomic, readonly) QBCOCustomObject *object;

@end
