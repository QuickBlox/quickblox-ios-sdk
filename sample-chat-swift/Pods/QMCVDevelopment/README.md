# QMChatViewController
An elegant ready-to-go chat view controller for iOS chat applications that use Quickblox communication backend.

#Features
- Ready-to-go chat view controller with a set of cells.
- Automatic cell size calculation.
- UI customisation  for chat cells.
- Flexibility in improving and extending functionality.
- Easy to connect with Quickblox.
- Optimised and performant.
- Supports portrait and landscape orientations.
- Auto Layout inside.
- Time header view with custom time intervals

# Screenshots

<img src="Screenshots/screenshot4.png" border="5" alt="Chat View Controller" width="300"> 

# Requirements
- iOS 7.0+
- ARC
- Xcode 6+
- Quickblox SDK 2.0+
- TTTAttributedLabel
- SDWebImage

# Installation
## CocoaPods
	pod 'QMChatViewController'
	
## Manually
* Drag QMChatViewController folder to your project folder and link to the appropriate target.

* Install dependencies.

# Dependencies
- [TTTAttributedLabel](https://github.com/TTTAttributedLabel/TTTAttributedLabel)
- [SDWebImage](https://github.com/rs/SDWebImage) 
- [Quickblox iOS SDK v2.0+](https://github.com/QuickBlox/quickblox-ios-sdk/archive/master.zip)

# Getting started
Example is included in repository. Try it out to see how chat view controller works.

Steps to add QMChatViewController to Your app:

1. Create a subclass of QMChatViewController. You could create it both from code and Interface Builder.
2. Open your subclass of QMChatViewController and do the following in *viewDidLoad* method:
    * Configure chat sender ID and display name:

	````objective-c
		self.senderID = 2000;
		self.senderDisplayName = @"user1";
	````

    * Insert messages using corresponding methods:

	````objective-c
    	[self.chatSectionManager addMessages:<array of messages>];
	````    

3. Handle message sending.

	````objective-c
    	- (void)didPressSendButton:(UIButton *)button
			       withMessageText:(NSString *)text
					      senderId:(NSUInteger)senderId
         		 senderDisplayName:(NSString *)senderDisplayName
                      		  date:(NSDate *)date {
			// Add sending message - for example:
            QBChatMessage *message = [QBChatMessage message];
    		message.text = text;
    		message.senderID = senderId;
    
			QBChatAttachment *attacment = [[QBChatAttachment alloc] init];
    		message.attachments = @[attacment];
    
    		[self.chatSectionManager addMessage:message];
    
    		[self finishSendingMessageAnimated:YES];
    
	     	// Save message to your cache/memory storage.                     
     		// Send message using Quickblox SDK
		}
	````    

4. Return cell view classes specific to chat message:

	````objective-c
    	- (Class)viewClassForItem:(QBChatMessage *)item {
	 		// Cell class for message
        	if (item.senderID != self.senderID) {
            
            	return [QMChatIncomingCell class];
        	} else {
            
            	return [QMChatOutgoingCell class];
       		}
    
    		return nil;
		}
	````
  
5. Calculate size of cell and minimum width:

	````objective-c
		- (CGSize)collectionView:(QMChatCollectionView *)collectionView dynamicSizeAtIndexPath:(NSIndexPath 	*)indexPath maxWidth:(CGFloat)maxWidth {
    
			QBChatMessage *item = self.items[indexPath.item];
    
			NSAttributedString *attributedString = [self attributedStringForItem:item];
    
			CGSize size = [TTTAttributedLabel sizeThatFitsAttributedString:attributedString
	        	                                       withConstraints:CGSizeMake(maxWidth, MAXFLOAT)
        	        	                        limitedToNumberOfLines:0];
			return size;
		}

		- (CGFloat)collectionView:(QMChatCollectionView *)collectionView minWidthAtIndexPath:(NSIndexPath *)indexPath {
			QBChatMessage *item = [self messageForIndexPath:indexPath];
    
			NSAttributedString *attributedString =
			[item senderID] == self.senderID ?  [self bottomLabelAttributedStringForItem:item] : [self topLabelAttributedStringForItem:item];
    
			CGSize size = [TTTAttributedLabel sizeThatFitsAttributedString:attributedString
                                                       withConstraints:CGSizeMake(1000, 10000)
                                                limitedToNumberOfLines:1];
    
    		return size.width;
		}
	````

6. Top, bottom and text labels.

	````objective-c
		- (NSAttributedString *)attributedStringForItem:(QBChatMessage *)messageItem {
			UIColor *textColor = [messageItem senderID] == self.senderID ? [UIColor whiteColor] : [UIColor colorWithWhite:0.290 alpha:1.000];
			UIFont *font = [UIFont fontWithName:@"Helvetica" size:15];
			NSDictionary *attributes = @{ NSForegroundColorAttributeName:textColor, NSFontAttributeName:font};

			NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:messageItem.text attributes:attributes];
    
			return attrStr;
		}

		- (NSAttributedString *)topLabelAttributedStringForItem:(QBChatMessage *)messageItem {
			UIFont *font = [UIFont fontWithName:@"Helvetica" size:14];
    
			if ([messageItem senderID] == self.senderID) {
	    		return nil;
    		}
    		NSDictionary *attributes = @{ NSForegroundColorAttributeName:[UIColor colorWithRed:0.184 green:0.467 blue:0.733 alpha:1.000], NSFontAttributeName:font};
    
			NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] 	initWithString:messageItem.senderNick attributes:attributes];
    
	    	return attrStr;
		}

		- (NSAttributedString *)bottomLabelAttributedStringForItem:(QBChatMessage *)messageItem {
    		UIColor *textColor = [messageItem senderID] == self.senderID ? [UIColor colorWithWhite:1.000 alpha:0.510] : [UIColor colorWithWhite:0.000 alpha:0.490];
    		UIFont *font = [UIFont fontWithName:@"Helvetica" size:12];
    
    		NSDictionary *attributes = @{ NSForegroundColorAttributeName:textColor, NSFontAttributeName:font};
    		NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:[messageItem.dateSent description] attributes:attributes];
    
    		return attrStr;
		}
	````
  
7. Modifying collection chat cell attributes without changing constraints:

	````objective-c
		struct QMChatLayoutModel {
	    
	    	CGSize avatarSize;
	    	CGSize containerSize;
	    	UIEdgeInsets containerInsets;
	    	CGFloat topLabelHeight;
	    	CGFloat bottomLabelHeight;
	    	CGSize staticContainerSize;
	    	CGFloat maxWidthMarginSpace;
		};
	
		typedef struct QMChatLayoutModel QMChatCellLayoutModel;
	````
	
	* size of the avatar image view
	* message view container size
	* top label height
	* bottom label height
	* static size of container view
	* margin space between message and screen end

	You can modify this attributes in this method:
	
	````objective-c
		- (QMChatCellLayoutModel)collectionView:(QMChatCollectionView *)collectionView layoutModelAtIndexPath:(NSIndexPath *)indexPath {
			QMChatCellLayoutModel layoutModel = [super collectionView:collectionView layoutModelAtIndexPath:indexPath];
			// update attributes here
    
			return layoutModel;
		}
	````
	
	So if you want to hide top label or bottom label you just need to set their height to 0.

## Attachemnts

*QMChatViewController* supports image attachment cell messages. *QMChatAttachmentIncomingCell* is used for incoming attachments, *QMChatAttachmentOutgoingCell* is used for outgoing attachments. Both of them have progress label to display loading progress. XIB's are also included.

## Time headers

*QMChatViewController* supports time headers for messages. Default value is 300 seconds (e.g. 5 minutes). You can setup your own time interval between headers using QMChatSectionManager property:

````objective-c
	self.chatSectionManager.timeIntervalBetweenSections = 500.0f;
````

You can also customize header height using this QMChatCollectionViewDataSource data source method:

````objective-c
	- (CGFloat)heightForSectionHeader {
    	return 40.0f;
	}
````

If you are not happy with default time header view, you can override this method and have your own one:

````objective-c
	- (UICollectionReusableView *)collectionView:(QMChatCollectionView *)collectionView
                    	sectionHeaderAtIndexPath:(NSIndexPath *)indexPath;
````

## Chat section manager

QMChatViewController contains its section manager called QMChatSectionManager. It has implementation of all methods, which you need to work with QMChatViewController chat sections.
This class should be used to add, update and delete messages from data source. QMChatSectionManager has delegate, which called whenever  data source were modified.
You can also disable animation for collection view changes using this property:

````objective-c
/**
 *  Determines whether animation for inserting or deleting is enabled.
 *  Default value: YES
 */
@property (assign, nonatomic) BOOL animationEnabled;
````

For more information on methods and its usage check out our inline doc in QMChatSectionManager.h.

# Questions & Help
- You could create an issue on GitHub if you are experiencing any problems. We will be happy to help you. 
- Or you can ask a 'quickblox' tagged question on StackOverflow http://stackoverflow.com/questions/ask

# Documentation
Inline code documentation available.

# License
See [LICENSE](LICENSE)

#Coming soon
CocoaPods distribution.