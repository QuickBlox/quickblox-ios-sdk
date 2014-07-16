//
//  NewNoteViewController.h
//  SimpleSample-custom-object-ios
//
//  Created by Ruslan on 9/14/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//
//
// This class shows how to add new note
//

#import <UIKit/UIKit.h>

@interface NewNoteViewController : UIViewController <QBActionStatusDelegate, UITextViewDelegate>

@property (strong, nonatomic) IBOutlet UITextView *noteTextField;
@property (strong, nonatomic) IBOutlet UITextView *commentTextField;

- (IBAction)back:(id)sender;
- (IBAction)next:(id)sender;

@end
