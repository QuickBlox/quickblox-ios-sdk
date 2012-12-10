//
//  QBCOCustomObjectAnswer.h
//  Quickblox
//
//  Created by IgorKh on 8/17/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

@interface QBCOCustomObjectAnswer : XmlAnswer{
@private
    QBCOCustomObject *_object;
}

@property (nonatomic, readonly) QBCOCustomObject *object;

@end
