//
//  DataManager.m
//  SimpleSample-custom-object-ios
//
//  Created by Ruslan on 9/14/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "SSCONotesStorage.h"

@interface SSCONotesStorage ()

@property (nonatomic, strong) NSMutableArray* mutableNotes;

@end

@implementation SSCONotesStorage

+ (instancetype)shared
{
	static id instance_ = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		instance_ = [[self alloc] init];
	});
	
	return instance_;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.mutableNotes = [NSMutableArray array];
        _notes = [NSArray array];
    }
    return self;
}

- (void)addNote:(QBCOCustomObject *)note
{
    [self.mutableNotes addObject:note];
    _notes = [NSArray arrayWithArray:self.mutableNotes];
}

- (void)addNotes:(NSArray *)notes
{
    [self.mutableNotes addObjectsFromArray:notes];
    _notes = [NSArray arrayWithArray:self.mutableNotes];
}

- (void)removeNote:(QBCOCustomObject *)customObject
{
    [self.mutableNotes removeObjectIdenticalTo:customObject];
    _notes = [NSArray arrayWithArray:self.mutableNotes];
}

@end
