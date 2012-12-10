//
//  MapViewController.h
//  SimpleSample-chat_users-ios
//
//  Created by Alexey Voitenko on 24.02.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapKit/MapKit.h"
#import "CustomTableViewCellCell.h"

@class MyCustomAnnotationView;

@interface ChatViewController : UIViewController <ActionStatusDelegate, UITextFieldDelegate,UITableViewDelegate, UITableViewDataSource> 
{
}

@property (nonatomic, retain) IBOutlet UIViewController *loginController;
@property (nonatomic, retain) IBOutlet UIViewController *registrationController;
@property (nonatomic, retain) QBUUser *currentUser;
@property (nonatomic, retain) IBOutlet UITextField* textField;
@property (nonatomic, retain) IBOutlet UITableView* myTableView;
@property (nonatomic, retain) IBOutlet CustomTableViewCellCell* _cell;
@property (nonatomic, assign) NSMutableArray* messages;
@property (nonatomic, assign) NSMutableArray* messagesIdsArray;

- (IBAction) send: (id)sender;
- (void) retrieveMessages:(NSTimer *) timer;
- (IBAction)textFieldDoneEditing:(id)sender;

@end
