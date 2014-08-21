//
//  QBCOFileUploadQuery.h
//  Quickblox
//
//  Created by Igor Khomenko on 10/10/13.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

@interface QBCOFileUploadQuery : QBCOFileQuery{
    QBCOFile *file;
}
@property (nonatomic,retain) QBCOFile *file;

@end
