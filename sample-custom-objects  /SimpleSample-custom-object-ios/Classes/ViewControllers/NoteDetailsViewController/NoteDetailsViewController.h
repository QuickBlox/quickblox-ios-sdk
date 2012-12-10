//
//  NoteDetailsViewController.h
//  SimpleSample-custom-object-ios
//
//  Created by Ruslan on 9/14/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//
//
// This class shows particular note's details. It allow to add comments to note, delete note.
//

#import <UIKit/UIKit.h>

@interface NoteDetailsViewController : UIViewController <QBActionStatusDelegate, UIAlertViewDelegate, UIActionSheetDelegate>

@property (retain, nonatomic) IBOutlet UILabel *noteLabel;
@property (retain, nonatomic) IBOutlet UILabel *statusLabel;
@property (retain, nonatomic) IBOutlet UITextView *comentsTextView;
@property (retain, nonatomic) QBCOCustomObject *customObject;

- (void) reloadData;

- (IBAction)addComment:(id)sender;
- (IBAction)changeStatus:(id)sender;
- (IBAction)deleteNote:(id)sender;

@end
