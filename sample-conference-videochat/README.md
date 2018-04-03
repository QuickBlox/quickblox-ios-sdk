# Quickblox WebRTC Conference
This README introduces new way for Quickblox WebRTC users to participate in video chats.
Multi-conference server is available only for Enterprise plans. Please refer to https://quickblox.com/developers/EnterpriseFeatures for more information and contacts.

# Config
**QBRTCConfig** class introduces two new settings for Conference, conference endpoint itself.

To set a specific conference endpoint use this method.
```objc
+ (void)setConferenceEndpoint:(NSString *)conferenceEndpoint;
```

**_Note:_** Endpoint should be a correct Quickblox Conference server endpoint.

Use this method to get a current conference endpoint (default is nil):
```objc
+ (NSString *)conferenceEndpoint;
```

# Conference client
Conference module has its own client which is described in current part.

## Conference client delegate
Conference client delegate is inherited from base client delegate and has all of its protocol methods implemented as well.

### Base client delegate protocol methods
All protocol methods down below have their own explanation inlined and are optional to be implemented.

```objc
/**
 *  Called by timeout with updated stats report for user ID.
 *
 *  @param session QBRTCSession instance
 *  @param report  QBRTCStatsReport instance
 *  @param userID  user ID
 *
 *  @remark Configure time interval with [QBRTCConfig setStatsReportTimeInterval:timeInterval].
 */
- (void)session:(__kindof QBRTCBaseSession *)session updatedStatsReport:(QBRTCStatsReport *)report forUserID:(NSNumber *)userID;

/**
 *  Called when session state has been changed.
 *
 *  @param session QBRTCSession instance
 *  @param state session state
 *
 *  @discussion Use this to track a session state. As SDK 2.3 introduced states for session, you can now manage your own states based on this.
 */
- (void)session:(__kindof QBRTCBaseSession *)session didChangeState:(QBRTCSessionState)state;

/**
 *  Called when received remote audio track from user.
 *
 *  @param audioTrack QBRTCAudioTrack instance
 *  @param userID     ID of user
 */
- (void)session:(__kindof QBRTCBaseSession *)session receivedRemoteAudioTrack:(QBRTCAudioTrack *)audioTrack fromUser:(NSNumber *)userID;

/**
 *  Called when received remote video track from user.
 *
 *  @param videoTrack QBRTCVideoTrack instance
 *  @param userID     ID of user
 */
- (void)session:(__kindof QBRTCBaseSession *)session receivedRemoteVideoTrack:(QBRTCVideoTrack *)videoTrack fromUser:(NSNumber *)userID;

/**
 *  Called when connection is closed for user.
 *
 *  @param session QBRTCSession instance
 *  @param userID  ID of user
 */
- (void)session:(__kindof QBRTCBaseSession *)session connectionClosedForUser:(NSNumber *)userID;

/**
 *  Called when connection is initiated with user.
 *
 *  @param session QBRTCSession instance
 *  @param userID  ID of user
 */
- (void)session:(__kindof QBRTCBaseSession *)session startedConnectingToUser:(NSNumber *)userID;

/**
 *  Called when connection is established with user.
 *
 *  @param session QBRTCSession instance
 *  @param userID  ID of user
 */
- (void)session:(__kindof QBRTCBaseSession *)session connectedToUser:(NSNumber *)userID;

/**
 *  Called when disconnected from user.
 *
 *  @param session QBRTCSession instance
 *  @param userID  ID of user
 */
- (void)session:(__kindof QBRTCBaseSession *)session disconnectedFromUser:(NSNumber *)userID;

/**
 *  Called when connection failed with user.
 *
 *  @param session QBRTCSession instance
 *  @param userID  ID of user
 */
- (void)session:(__kindof QBRTCBaseSession *)session connectionFailedForUser:(NSNumber *)userID;

/**
 *  Called when session connection state changed for a specific user.
 *
 *  @param session QBRTCSession instance
 *  @param state   state - @see QBRTCConnectionState
 *  @param userID  ID of user
 */
- (void)session:(__kindof QBRTCBaseSession *)session didChangeConnectionState:(QBRTCConnectionState)state forUser:(NSNumber *)userID;
```

### Conference client delegate protocol methods
All protocol methods down below are conference client specific, optional to be implemented and have their own explanation inlined.

```objc
/**
 *  Called when session was created on server.
 *
 *  @param session QBRTCConferenceSession instance
 *
 *  @discussion When this method is called, session instance that was already created by QBRTCConferenceClient
 *  will be assigned valid session ID from server.
 *
 *  @see QBRTCConferenceSession, QBRTCConferenceClient
 */
- (void)didCreateNewSession:(QBRTCConferenceSession *)session;

/**
 *  Called when join to session is performed and acknowledged by server.
 *
 *  @param session QBRTCConferenceSession instance
 *  @param chatDialogID chat dialog ID
 *  @param publishersList array of user IDs, that are currently publishers
 *
 *  @see QBRTCConferenceSession
 */
- (void)session:(QBRTCConferenceSession *)session didJoinChatDialogWithID:(NSString *)chatDialogID publishersList:(NSArray <NSNumber *> *)publishersList;

/**
 *  Called when new publisher did join.
 *
 *  @param session QBRTCConferenceSession instance
 *  @param userID new publisher user ID
 *
 *  @see QBRTCConferenceSession
 */
- (void)session:(QBRTCConferenceSession *)session didReceiveNewPublisherWithUserID:(NSNumber *)userID;

/**
 *  Called when publisher did leave.
 *
 *  @param session QBRTCConferenceSession instance
 *  @param userID publisher that left user ID
 *
 *  @see QBRTCConferenceSession
 */
- (void)session:(QBRTCConferenceSession *)session publisherDidLeaveWithUserID:(NSNumber *)userID;

/**
 *  Called when session did receive error from server.
 *
 *  @param session QBRTCConferenceSession instance
 *  @param error received error from server
 *
 *  @note Error doesn't necessarily means that session is closed. Can be just a minor error that can be fixed/ignored.
 *
 *  @see QBRTCConferenceSession
 */
- (void)session:(QBRTCConferenceSession *)session didReceiveError:(NSError *)error;

/**
 *  Called when slowlink was received.
 *
 *  @param session  QBRTCConferenceSession instance
 *  @param uplink   whether the issue is uplink or not
 *  @param nacks    number of nacks
 *
 *  @discussion this callback is triggered when serber reports trouble either sending or receiving media on the
 *  specified connection, typically as a consequence of too many NACKs received from/sent to the user in the last
 *  second: for instance, a slowLink with uplink=true means you notified several missing packets from server,
 *  while uplink=false means server is not receiving all your packets.
 *
 *  @note useful to figure out when there are problems on the media path (e.g., excessive loss), in order to
 *  possibly react accordingly (e.g., decrease the bitrate if most of our packets are getting lost).
 *
 *  @see QBRTCConferenceSession
 */
- (void)session:(QBRTCConferenceSession *)session didReceiveSlowlinkWithUplink:(BOOL)uplink nacks:(NSNumber *)nacks;

/**
 *  Called when media receiving state was changed on server.
 *
 *  @param session QBRTCConferenceSession instance
 *  @param mediaType media type
 *  @param receiving whether media is receiving by server
 *
 *  @see QBRTCConferenceSession, QBRTCConferenceMediaType
 */
- (void)session:(QBRTCConferenceSession *)session didChangeMediaStateWithType:(QBRTCConferenceMediaType)mediaType receiving:(BOOL)receiving;

/**
 *  Session did initiate close request.
 *
 *  @param session QBRTCConferenceSession instance
 *
 *  @discussion 'sessionDidClose:withTimeout:' will be called after server will close session with callback
 *
 *  @see QBRTCConferenceSession
 */
- (void)sessionWillClose:(QBRTCConferenceSession *)session;

/**
 *  Called when session was closed completely on server.
 *
 *  @param session QBRTCConferenceSession instance
 *  @param timeout whether session was closed due to timeout on server
 *
 *  @see QBRTCConferenceSession
 */
- (void)sessionDidClose:(QBRTCConferenceSession *)session withTimeout:(BOOL)timeout;
```

## Conference client interface
**QBRTCConferenceClient** is a singleton based class which is used to create and operate with conference sessions. It has observer (delegates) manager, which can be activated/deactivated with two simple methods:

```objc
/**
 *  Add delegate to the observers list.
 *
 *  @param delegate delegate that conforms to QBRTCConferenceClientDelegate protocol
 *
 *  @see QBRTCConferenceClientDelegate
 */
- (void)addDelegate:(id<QBRTCConferenceClientDelegate>)delegate;

/**
 *  Remove delegate from the observers list.
 *
 *  @param delegate delegate that conforms to QBRTCConferenceClientDelegate protocol
 *
 *  @see QBRTCConferenceClientDelegate
 */
- (void)removeDelegate:(id<QBRTCConferenceClientDelegate>)delegate;
```

Delegate should conform to **QBRTCConferenceClientDelegate** protocol, which is inherited from base client delegate.

In order to create new conference session you should use method down below:
```objc
/**
 *  Send create session request.
 *
 *  @note Returns session without ID. When session will be created on server
 *  ID will be assigned and session will be returned in 'didCreateNewSession:' callback.
 *
 *  @see QBRTCConferenceClientDelegate
 *
 *  @param chatDialogID chat dialog ID
 */
- (QBRTCConferenceSession *)createSessionWithChatDialogID:(NSString *)chatDialogID;
```

It will create session locally first, without session ID, until server will perform a ```didCreateNewSession:``` callback in **QBRTCConferenceClientDelegate** protocol, where session ID will be assigned and session will receive its **QBRTCSessionStateNew** state. After that you can join or leave (destroy) it, etc. Conference session is explained in next paragraph.

# Conference session
**QBRTCConferenceSession** is inherited from base session class, and has all of its basics, such as ```state```, ```currentUserID```, ```localMediaStream```, ability to get remote audio and video tracks for a specific user IDs:

```objc
/**
 *  Remote audio track with opponent user ID.
 *
 *  @param userID opponent user ID
 *
 *  @return QBRTCAudioTrack audio track instance
 */
- (QBRTCAudioTrack *)remoteAudioTrackWithUserID:(NSNumber *)userID;

/**
 *  Remote video track with opponent user ID.
 *
 *  @param userID opponent user ID
 *
 *  @return QBRTCVideoTrack video track instance
 */
- (QBRTCVideoTrack *)remoteVideoTrackWithUserID:(NSNumber *)userID;
```

and ability to get a connection state for a specific user ID if his connection is opened:
```objc
/**
 *  Connection state for opponent user ID.
 *
 *  @param userID opponent user ID
 *
 *  @return QBRTCConnectionState connection state for opponent user ID
 */
- (QBRTCConnectionState)connectionStateForUser:(NSNumber *)userID;
```

See **QBRTCBaseSession** class for more inline documentation.
As for conference specific methods, conference session ID is **NSNumber**. Each conference session is tied to a specific Quickblox dialog ID (**NSString**).

It also has a publishers list property. But publisher list will be only valid if you will perform join to that session as publisher using method down below:

```objc
/**
 *  Perform join room as publisher.
 *
 *  @discussion 'session:didJoinChatDialogWithID:publishersList:' will be called upon successful join.
 *
 *  @see QBRTCConferenceClientDelegate
 */
- (void)joinAsPublisher;
```

This method joins session and will publish your feed (make you an active publisher in room). Everyone in room will be able to subscribe and receive your feed.

**_Note:_** Only can be used when session has a valid session ID, e.g. is created on server and notified to you with ```didCreateNewSession:``` callback from **QBRTCConferenceClientDelegate** protocol.

You can subscribe and unsubscribe from publishers using methods down below.

**_Note:_** You do not need to be joined as publisher in order to perform subscription based operations in session.

```objc
/**
 *  Subscribe to publisher's with user ID feed.
 *
 *  @param userID active publisher's user ID
 *
 *  @discussion If you want to receive publishers feeds, you need to subscribe to them.
 *
 *  @note User must be an active publisher.
 */
- (void)subscribeToUserWithID:(NSNumber *)userID;

/**
 *  Unsubscribe from publisher's with user ID feed.
 *
 *  @param userID active publisher's user ID
 *
 *  @discussion Do not need to be used when publisher did leave room, in that case unsibscribing will be performing automatically. Use if you need to unsubscribe from active publisher's feed.
 *
 *  @note User must be an active publisher.
 */
- (void)unsubscribeFromUserWithID:(NSNumber *)userID;
```

**_Note:_** These methods as well only can be used when session has a valid session ID, e.g. is created on server and notified to you with ```didCreateNewSession:``` callback from **QBRTCConferenceClientDelegate** protocol.

And in order to close/leave session you can perform next method:
```objc
/**
 *  Leave chat room and close session.
 *
 *  @discussion 'sessionWillClose:' will be called when all connection are closed, 'sessionDidClose:withTimeout:' will be called when session will be successfully closed by server.
 */
- (void)leave;
```

**_Note:_** This method can be called in any state of the session and will always close it no matter what.

# Examples and implementations
**sample-conference-webrtc** is a great example of our QuickbloxWebRTC Conference module, classes to look at: **CallViewController**.
