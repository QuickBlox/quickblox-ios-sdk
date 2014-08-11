#import <Foundation/Foundation.h>
#import "QBXMPPRoster.h"
#import "QBXMPPUserMemoryStorage.h"
#import "QBXMPPResourceMemoryStorage.h"


/**
 * This class is an example implementation of XMPPRosterStorage using core data.
 * You are free to substitute your own storage class.
**/

@interface QBXMPPRosterMemoryStorage : NSObject <QBXMPPRosterStorage>
{
	QBXMPPRoster *parent;
	dispatch_queue_t parentQueue;
	
	Class userClass;
	Class resourceClass;
	
	BOOL isRosterPopulation;
	NSMutableDictionary *roster;
	
	QBXMPPJID *myJID;
	QBXMPPUserMemoryStorage *myUser;
}

- (id)init;

@property (assign, readonly) QBXMPPRoster *parent;

/**
 * You can optionally extend the XMPPUserMemoryStorage and XMPPResourceMemoryStorage classes.
 * Then just set the classes here, and your subclasses will automatically get used.
**/
@property (readwrite, assign) Class userClass;
@property (readwrite, assign) Class resourceClass;

// The methods below provide access to the roster data.
// If invoked from a dispatch queue other than the roster's queue,
// the methods return snapshots (copies) of the roster data.
// These snapshots provide a thread-safe version of the roster data.
// The thread-safety comes from the fact that the copied data will not be altered,
// so it can therefore be used from multiple threads/queues if needed.

- (id <QBXMPPUser>)myUser;
- (id <QBXMPPResource>)myResource;

- (id <QBXMPPUser>)userForJID:(QBXMPPJID *)jid;
- (id <QBXMPPResource>)resourceForJID:(QBXMPPJID *)jid;

- (NSArray *)sortedUsersByName;
- (NSArray *)sortedUsersByAvailabilityName;

- (NSArray *)sortedAvailableUsersByName;
- (NSArray *)sortedUnavailableUsersByName;

- (NSArray *)unsortedUsers;
- (NSArray *)unsortedAvailableUsers;
- (NSArray *)unsortedUnavailableUsers;

- (NSArray *)sortedResources:(BOOL)includeResourcesForMyUserExcludingMyself;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@protocol QBXMPPRosterMemoryStorageDelegate
@optional

/**
 * The XMPPRosterStorage classes use the same delegate as their parent XMPPRoster.
**/

/**
 * Catch-all change notification.
 * 
 * When the roster changes, for any of the reasons listed below, this delegate method fires.
 * This method always fires after the more precise delegate methods listed below.
**/
- (void)xmppRosterDidChange:(QBXMPPRosterMemoryStorage *)sender;

/**
 * Notification that the roster has received the roster from the server.
 * 
 * If parent.autoFetchRoster is YES, the roster will automatically be fetched once the user authenticates.
**/
- (void)xmppRosterDidPopulate:(QBXMPPRosterMemoryStorage *)sender;

/**
 * Notifications that the roster has changed.
 * 
 * This includes times when users are added or removed from our roster, or when a nickname is changed,
 * including when other resources logged in under the same user account as us make changes to our roster.
 * 
 * This does not include when resources simply go online / offline.
**/
- (void)xmppRoster:(QBXMPPRosterMemoryStorage *)sender didAddUser:(QBXMPPUserMemoryStorage *)user;
- (void)xmppRoster:(QBXMPPRosterMemoryStorage *)sender didUpdateUser:(QBXMPPUserMemoryStorage *)user;
- (void)xmppRoster:(QBXMPPRosterMemoryStorage *)sender didRemoveUser:(QBXMPPUserMemoryStorage *)user;

/**
 * Notifications when resources go online / offline.
**/
- (void)xmppRoster:(QBXMPPRosterMemoryStorage *)sender
    didAddResource:(QBXMPPResourceMemoryStorage *)resource
          withUser:(QBXMPPUserMemoryStorage *)user;

- (void)xmppRoster:(QBXMPPRosterMemoryStorage *)sender
 didUpdateResource:(QBXMPPResourceMemoryStorage *)resource
          withUser:(QBXMPPUserMemoryStorage *)user;

- (void)xmppRoster:(QBXMPPRosterMemoryStorage *)sender
 didRemoveResource:(QBXMPPResourceMemoryStorage *)resource
          withUser:(QBXMPPUserMemoryStorage *)user;

@end
