//
//  DataManager.h
//  SimpleSample-custom-object-ios
//
//  Created by Ruslan on 9/14/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//
//
// This class presents notes storage
//

@interface SSCONotesStorage : NSObject

@property (nonatomic, readonly) NSArray *notes;

+ (instancetype)shared;

- (void)addNote:(QBCOCustomObject *)note;
- (void)addNotes:(NSArray *)notes;
- (void)removeNote:(QBCOCustomObject *)customObject;

@end
