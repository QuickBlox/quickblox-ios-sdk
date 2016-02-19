//
//  QMChatViewController.h
//  QMChatViewController
//
//  Created by Andrey Ivanov on 06.04.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "QMChatCollectionView.h"
#import "QMChatCollectionViewDelegateFlowLayout.h"
#import "QMChatCollectionViewFlowLayout.h"
#import "QMChatActionsHandler.h"
#import "QMInputToolbar.h"
#import <Quickblox/Quickblox.h>
#import "QMChatSectionManager.h"

#import "QMChatContactRequestCell.h"
#import "QMChatIncomingCell.h"
#import "QMChatOutgoingCell.h"
#import "QMChatNotificationCell.h"
#import "QMChatAttachmentIncomingCell.h"
#import "QMChatAttachmentOutgoingCell.h"

@interface QMChatViewController : UIViewController <QMChatCollectionViewDataSource, QMChatCollectionViewDelegateFlowLayout, UITextViewDelegate>


@property (strong, nonatomic) QMChatSectionManager *chatSectionManager;

/**
 *  Cell's contact request delegate.
 */
@property (weak, nonatomic) id <QMChatActionsHandler> actionsHandler;

/**
 *  Returns the collection view object managed by this view controller.
 *  This view controller is the collection view's data source and delegate.
 */
@property (weak, nonatomic, readonly) QMChatCollectionView *collectionView;

/**
 *  Returns the input toolbar view object managed by this view controller.
 *  This view controller is the toolbar's delegate.
 */
@property (weak, nonatomic, readonly) QMInputToolbar *inputToolbar;

/**
 *  The display name of the current user who is sending messages.
 *
 *  @discussion This value does not have to be unique. This value must not be `nil`.
 */
@property (copy, nonatomic) NSString *senderDisplayName;

/**
 *  The string identifier that uniquely identifies the current user sending messages.
 *
 *  @discussion This property is used to determine if a message is incoming or outgoing.
 *  All message data objects returned by `collectionView:messageDataForItemAtIndexPath:` are
 *  checked against this identifier. This value must not be `nil`.
 */
@property (assign, nonatomic) NSUInteger senderID;

/**
 *  The time interval that used to split messages between sections.
 *
 *  @discussion You should set time interval in seconds with '- (NSTimeInterval)timeIntervalBetweenSections' data source method.
 *  The messages that have dateSent difference from the last message in section not greater then the one you set,
 *  will appear in one section under one date of the first message in section.
 *
 *  @warning *Deprecated in QMChatViewController 0.3.3:* Use 'self.chatSectionManager.timeIntervalBetweenSections' instead.
 */
@property (assign, nonatomic) NSTimeInterval timeIntervalBetweenSections DEPRECATED_MSG_ATTRIBUTE("Deprecated in 0.3.3. Use 'self.chatSectionManager.timeIntervalBetweenSections' instead.");

/**
 *  Float value that used as height for section header.
 *
 *  @discussion Set this value with data source method '- (CGFloat)heightForSectionHeader'.
 *  Section header will not be displayed if value is '0'.
 */
@property (assign, nonatomic) CGFloat heightForSectionHeader;

/**
 *  Specifies whether or not the view controller should automatically scroll to the most recent message
 *  when the view appears and when sending, receiving, and composing a new message.
 *
 *  @discussion The default value is `YES`, which allows the view controller to scroll automatically to the most recent message.
 *  Set to `NO` if you want to manage scrolling yourself.
 */
@property (assign, nonatomic) BOOL automaticallyScrollsToMostRecentMessage;

/**
 *  Specifies an additional inset amount to be added to the collectionView's contentInsets.top value.
 *
 *  @discussion Use this property to adjust the top content inset to account for a custom subview at the top of your view controller.
 */
@property (assign, nonatomic) CGFloat topContentAdditionalInset;

/**
 *  Total count of messages in all sections.
 *
 *  @discussion Use this to know how many messages are displayed in chat controller.
 *
 *  @warning *Deprecated in QMChatViewController 0.3.3:* Use 'self.chatSectionManager.totalMessagesCount' instead.
 */
@property (assign, nonatomic, readonly) NSUInteger totalMessagesCount DEPRECATED_MSG_ATTRIBUTE("Deprecated in 0.3.3. Use 'self.chatSectionManager.totalMessagesCount' instead.");

/**
 *  Updating data source with messages without reloading of collection view.
 *
 *  @param messages QBChatMessage instances to update data source with
 *
 *  @return dictionary with section indexes and items index pathes to insert
 *
 *  @discussion Use this method to update data source without reloading collection view. For example in viewWillAppear method.
 *
 *  @warning *Deprecated in QMChatViewController 0.3.3:* Use '[self.chatSectionManager addMessage:]' or '[self.chatSectionManager addMessages:]' instead.
 */
- (NSDictionary *)updateDataSourceWithMessages:(NSArray QB_GENERIC(QBChatMessage *) *)messages DEPRECATED_MSG_ATTRIBUTE("Deprecated in 0.3.3. Use '[self.chatSectionManager addMessage:]' or '[self.chatSectionManager addMessages:]' instead.");

/**
 *  Insert messages to the top.
 *
 *  @param messages array of messages to insert
 *
 *  @discussion Use this method to insert older messages in chat.
 *
 *  @warning *Deprecated in QMChatViewController 0.3.3:* Use '[self.chatSectionManager addMessage:]' or '[self.chatSectionManager addMessages:]' instead.
 */
- (void)insertMessagesToTheTopAnimated:(NSArray QB_GENERIC(QBChatMessage *) *)messages DEPRECATED_MSG_ATTRIBUTE("Deprecated in 0.3.3. Use '[self.chatSectionManager addMessage:]' or '[self.chatSectionManager addMessages:]' instead.");

/**
 *  Insert message to the bottom.
 *
 *  @param message  message to insert
 *
 *  @discussion Use this method to insert new message to the chat controller.
 *
 *  @warning *Deprecated in QMChatViewController 0.3.3:* Use '[self.chatSectionManager addMessage:]' or '[self.chatSectionManager addMessages:]' instead.
 */
- (void)insertMessageToTheBottomAnimated:(QBChatMessage *)message DEPRECATED_MSG_ATTRIBUTE("Deprecated in 0.3.3. Use '[self.chatSectionManager addMessage:]' or '[self.chatSectionManager addMessages:]' instead.");

/**
 *  Insert messages to the bottom.
 *
 *  @param messages array of messages
 *
 *  @discussion Use this method to insert new messages to the chat controller.
 *
 *  @warning *Deprecated in QMChatViewController 0.3.3:* Use '[self.chatSectionManager addMessage:]' or '[self.chatSectionManager addMessages:]' instead.
 */
- (void)insertMessagesToTheBottomAnimated:(NSArray QB_GENERIC(QBChatMessage *) *)messages DEPRECATED_MSG_ATTRIBUTE("Deprecated in 0.3.3. Use '[self.chatSectionManager addMessage:]' or '[self.chatSectionManager addMessages:]' instead.");

/**
 *  Update message in chat controller.
 *
 *  @param message  updated message
 *
 *  @discussion Use this method to update message in chat controller. As parameter use updated message, it will be replaced in items by it's ID
 *  and reloaded in collection view.
 *
 *  @warning *Deprecated in QMChatViewController 0.3.3:* Use '[self.chatSectionManager updateMessage:]' or '[self.chatSectionManager updateMessages:]' instead.
 */
- (void)updateMessage:(QBChatMessage *)message DEPRECATED_MSG_ATTRIBUTE("Deprecated in 0.3.3. Use '[self.chatSectionManager updateMessage:]' or '[self.chatSectionManager updateMessages:]' instead.");

/**
 *  Update messages in chat controller.
 *
 *  @param messages array of messages to update
 *
 *  @discussion Use this method to update messages in chat controller. As parameter use updated message, it will be replaced in items by it's ID
 *  and reloaded in collection view.
 *
 *  @warning *Deprecated in QMChatViewController 0.3.3:* Use '[self.chatSectionManager updateMessage:]' or '[self.chatSectionManager updateMessages:]' instead.
 */
- (void)updateMessages:(NSArray QB_GENERIC(QBChatMessage *) *)messages DEPRECATED_MSG_ATTRIBUTE("Deprecated in 0.3.3. Use '[self.chatSectionManager updateMessage:]' or '[self.chatSectionManager updateMessages:]' instead.");

/**
 *  Delete message from chat controller.
 *
 *  @param message message to delete
 *
 *  @warning *Deprecated in QMChatViewController 0.3.3:* Use '[self.chatSectionManager deleteMessage:]' or '[self.chatSectionManager deleteMessages:]' instead.
 */
- (void)deleteMessage:(QBChatMessage *)message DEPRECATED_MSG_ATTRIBUTE("Deprecated in 0.3.3. Use '[self.chatSectionManager deleteMessage:]' or '[self.chatSectionManager deleteMessages:]' instead.");

/**
 *  Delete messages from chat controller.
 *
 *  @param messages array of messages to remove from chat controller
 */
- (void)deleteMessages:(NSArray QB_GENERIC(QBChatMessage *) *)messages;

/**
 *  Method to create chat message text attributed string. Have to be overriden in subclasses.
 *
 *  @param messageItem Chat message instance.
 *
 *  @return Configured attributed string.
 */
- (NSAttributedString *)attributedStringForItem:(QBChatMessage *)messageItem;

/**
 *  Method to create chat message top label attributed string (Usually - chat message owner name). Have to be overriden in subclasses.
 *
 *  @param messageItem Chat message instance.
 *
 *  @return Configured attributed string.
 */
- (NSAttributedString *)topLabelAttributedStringForItem:(QBChatMessage *)messageItem;

/**
 *  Method to create chat message bottom label attributed string (Usually - chat message date sent). Have to be overriden in subclasses.
 *
 *  @param messageItem Chat message instance.
 *
 *  @return Configured attributed string.
 */
- (NSAttributedString *)bottomLabelAttributedStringForItem:(QBChatMessage *)messageItem;

/**
 *  Collection Cell View class for specific message. Have to be overriden in subclasses. Defaults cells are supplied with QMChatViewController.
 *
 *  @param item Chat message instance.
 *
 *  @return Collection Cell View Class
 */
- (Class)viewClassForItem:(QBChatMessage *)item;

- (void)collectionView:(QMChatCollectionView *)collectionView configureCell:(UICollectionViewCell *)cell forIndexPath:(NSIndexPath *)indexPath;

/**
 *  Collection view reusable section header.
 *
 *  @param collectionView   collection view to dequeue reusable header
 *  @param indexPath        index path of section header
 *
 *  @discussion Override this method if you want to use custom reusable view as section header.
 *  Keep in mind that due to collection view being reversed, section header is actually footer.
 *
 *  @return collection view reusable view to use as section header.
 */
- (UICollectionReusableView *)collectionView:(QMChatCollectionView *)collectionView
                    sectionHeaderAtIndexPath:(NSIndexPath *)indexPath;

#pragma mark - Class methods

/**
 *  Returns the `UINib` object initialized for a `QMChatViewController`.
 *
 *  @return The initialized `UINib` object or `nil` if there were errors during initialization
 *  or the nib file could not be located.
 *
 *  @discussion You may override this method to provide a customized nib. If you do,
 *  you should also override `messagesViewController` to return your
 *  view controller loaded from your custom nib.
 */
+ (UINib *)nib;

/**
 *  Creates and returns a new `QMChatViewController` object.
 *
 *  @discussion This is the designated initializer for programmatic instantiation.
 *
 *  @return An initialized `QMChatViewController` object if successful, `nil` otherwise.
 */
+ (instancetype)messagesViewController;

#pragma mark - Messages view controller

/**
 *  This method is called when the user taps the send button on the inputToolbar
 *  after composing a message with the specified data.
 *
 *  @param button            The send button that was pressed by the user.
 *  @param text              The message text.
 *  @param senderId          The message sender identifier.
 *  @param senderDisplayName The message sender display name.
 *  @param date              The message date.
 */
- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSUInteger)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date;

/**
 *  This method is called when the user taps the accessory button on the `inputToolbar`.
 *
 *  @param sender The accessory button that was pressed by the user.
 */
- (void)didPressAccessoryButton:(UIButton *)sender;

/**
 *  This method is called when the user finishes picking attachment image.
 *
 *  @param image    image that was picked by user
 */
- (void)didPickAttachmentImage:(UIImage *)image;

/**
 *  Animates the sending of a new message. See `finishSendingMessageAnimated:` for more details.
 *
 *  @see `finishSendingMessageAnimated:`.
 */
- (void)finishSendingMessage;

/**
 *  Completes the "sending" of a new message by resetting the `inputToolbar`, adding a new collection view cell in the collection view,
 *  reloading the collection view, and scrolling to the newly sent message as specified by `automaticallyScrollsToMostRecentMessage`.
 *  Scrolling to the new message can be animated as specified by the animated parameter.
 *
 *  @param animated Specifies whether the sending of a message should be animated or not. Pass `YES` to animate changes, `NO` otherwise.
 *
 *  @discussion You should call this method at the end of `didPressSendButton: withMessageText: senderId: senderDisplayName: date`
 *  after adding the new message to your data source and performing any related tasks.
 *
 *  @see `automaticallyScrollsToMostRecentMessage`.
 */
- (void)finishSendingMessageAnimated:(BOOL)animated;

/**
 *  Animates the receiving of a new message. See `finishReceivingMessageAnimated:` for more details.
 *
 *  @see `finishReceivingMessageAnimated:`.
 */
- (void)finishReceivingMessage;

/**
 *  Completes the "receiving" of a new message by adding a new collection view cell in the collection view,
 *  reloading the collection view, and scrolling to the newly sent message as specified by `automaticallyScrollsToMostRecentMessage`.
 *  Scrolling to the new message can be animated as specified by the animated parameter.
 *
 *  @param animated Specifies whether the receiving of a message should be animated or not. Pass `YES` to animate changes, `NO` otherwise.
 *
 *  @discussion You should call this method after adding a new "received" message to your data source and performing any related tasks.
 *
 *  @see `automaticallyScrollsToMostRecentMessage`.
 */
- (void)finishReceivingMessageAnimated:(BOOL)animated;

/**
 *  Scrolls the collection view such that the bottom most cell is completely visible, above the `inputToolbar`.
 *
 *  @param animated Pass `YES` if you want to animate scrolling, `NO` if it should be immediate.
 */
- (void)scrollToBottomAnimated:(BOOL)animated;

#pragma mark - Helpers

/**
 *  Generating name for section with date.
 *
 *  @param date Date of section
 *
 *  @discussion override this method if you want to generate custom name for section with it's date.
 */
- (NSString *)nameForSectionWithDate:(NSDate *)date;

/**
 *  Message for index path.
 *
 *  @param indexPath    index path to find message
 *
 *  @return QBChatMessage instance that conforms to indexPath
 *
 *  @warning *Deprecated in QMChatViewController 0.3.3:* Use '[self.chatSectionManager messageForIndexPath:]' instead.
 */
- (QBChatMessage *)messageForIndexPath:(NSIndexPath *)indexPath DEPRECATED_MSG_ATTRIBUTE("Deprecated in 0.3.3. Use '[self.chatSectionManager messageForIndexPath:]' instead.");

/**
 *  Index path for message.
 *
 *  @param message  message to return index path
 *
 *  @return NSIndexPath instance that conforms message or nil if not found
 *
 *  @warning *Deprecated in QMChatViewController 0.3.3:* Use '[self.chatSectionManager indexPathForMessage:]' instead.
 */
- (NSIndexPath *)indexPathForMessage:(QBChatMessage *)message DEPRECATED_MSG_ATTRIBUTE("Deprecated in 0.3.3. Use '[self.chatSectionManager indexPathForMessage:]' instead.");

@end
