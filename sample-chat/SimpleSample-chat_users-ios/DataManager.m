//
//  DataManager.m
//  SimpleSample-chat_users-ios
//
//  Created by Ruslan on 9/18/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "DataManager.h"

static DataManager *dataManager;

@implementation DataManager

@synthesize users;
@synthesize currentUser;
@synthesize rooms;

+(DataManager *) shared{
    if(!dataManager){
        dataManager = [[DataManager alloc] init];
        dataManager.rooms = [NSMutableArray array];
    }
    return dataManager;
}

- (NSMutableArray *)chatHistoryWithOpponentID:(NSUInteger)opponentID{
     NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *key = [NSString stringWithFormat:@"%d%d", currentUser.ID, opponentID];
    
    if([NSKeyedUnarchiver unarchiveObjectWithData:[standardUserDefaults objectForKey:key]]){
        
        return [[[NSMutableArray alloc] initWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:[standardUserDefaults objectForKey:key]]] autorelease];
    }
    
    return nil;
}

- (void)saveMessage:(id)message toHistoryWithOpponentID:(NSUInteger)opponentID{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"%d%d", currentUser.ID, opponentID];
    [standardUserDefaults setObject:message forKey:key];
    [standardUserDefaults synchronize];
}

- (void)dealloc{
    [users release];
    [rooms release];
    [currentUser release];
    [super dealloc];
}

@end
