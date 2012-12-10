//
//  QBMGetTokenPerformer.h
//  MessagesService
//

//  Copyright 2011 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface QBMGetTokenPerformer : QBApplicationRedelegate<Perform,Cancelable> {
	NSObject<QBActionStatusDelegate> * performDelegate;
	id context;
	NSRecursiveLock *canceledLock;
    
	BOOL completed;
	BOOL isCanceled;
}
@property (nonatomic, retain) NSObject<QBActionStatusDelegate> *performDelegate;
@property (nonatomic, retain) id context;
@property (nonatomic, retain) NSRecursiveLock *canceledLock;

@property (nonatomic) BOOL completed;
@property (nonatomic) BOOL isCanceled;

- (void)actionInBg;
- (void)performAction;

- (void)tokenRequestTimedOut;

@end
