//
//  NoteDetailsViewController.m
//  SimpleSample-custom-object-ios
//
//  Created by Ruslan on 9/14/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "NoteDetailsViewController.h"

@interface NoteDetailsViewController ()

@end

@implementation NoteDetailsViewController

@synthesize noteLabel;
@synthesize statusLabel;
@synthesize comentsTextView;
@synthesize customObject;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self reloadData];
    
    [self setTitle:@"Note"];
    
}

- (void)viewDidUnload
{
    [self setNoteLabel:nil];
    [self setStatusLabel:nil];
    [self setComentsTextView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [noteLabel release];
    [statusLabel release];
    [comentsTextView release];
    [customObject release];
    [super dealloc];
}

- (IBAction)addComment:(id)sender {
    // Show alert for enter new comment
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New comment"
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Add", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    [alert show];
    [alert release];
}

- (IBAction)changeStatus:(id)sender {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select status"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"New", @"In Progress", @"Done", nil];
    
    [actionSheet showInView:self.view];
    [actionSheet release];
}

- (IBAction)deleteNote:(id)sender {
    // remove note
    [QBCustomObjects deleteObjectWithID: customObject.ID className:customClassName delegate:self];
    
    [[[DataManager shared] notes] removeObjectIdenticalTo:customObject];
}

- (void) reloadData{
    // set note & status
    self.noteLabel.text = [[customObject fields] objectForKey:@"note"];
    self.statusLabel.text = [[customObject fields] objectForKey:@"status"];
    
    // set comments
    NSString *commentsAsString = [[customObject fields] objectForKey:@"comment"];
    if(![commentsAsString isKindOfClass:NSNull.class]){
        NSArray *comments = [commentsAsString componentsSeparatedByString:@"-c-"];
        [self.comentsTextView setText:nil];
        int count = 1;
        for(NSString *comment in comments){
            if(count == 1){
                NSString *str = [[NSString alloc] initWithFormat:@"#%d %@\n\n",count, comment];
                [self.comentsTextView setText:str];
                [str release];
            }else{
                NSString *str = [[NSString alloc] initWithFormat:@"%@#%d %@\n\n", self.comentsTextView.text, count, comment];
                [self.comentsTextView setText:str];
                [str release];
            }
            count++;
        }
    }
}


#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    NSString *status = nil;
    switch (buttonIndex) {
        case 0:{
            status = @"New";
            break;
        }
        case 1:{
            status = @"In Progress";
            break;
        }
        case 2:{
            status = @"Done";
            break;
        }
    }
    
    if(status){
        
        // chabge status & update custom object
        [[customObject fields] setObject:status forKey:@"status"];
        [QBCustomObjects updateObject:customObject delegate:self];
        
        // refresh table
        [self reloadData];
    }
}


#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    // delete note alert
    if(alertView.tag == 2){
        [self.navigationController popViewControllerAnimated:YES];
        
    // Add new comment alert
    }else{
        switch (buttonIndex) {
            case 1:{
                // change comments & update custom object
                NSString *comments = [[[NSString alloc] initWithFormat:@"%@-c-%@", [[customObject fields] objectForKey:@"comment"], [alertView textFieldAtIndex:0].text] autorelease];

                [[customObject fields] setObject:comments forKey:@"comment"];
            
                [QBCustomObjects updateObject:customObject delegate:self];
            
                // refresh table
                [self reloadData];
            
                break;
            }
            default:
                break;
        }
    }
}


#pragma mark -
#pragma mark QBActionStatusDelegate

// QuickBlox API queries delegate
-(void)completedWithResult:(Result*)result{
    
    // Update/Delete note result
    if([result isKindOfClass:QBCOCustomObjectResult.class]){
        
        // Success result
        if(result.success){
            QBCOCustomObjectResult *res = (QBCOCustomObjectResult *)result;
            
            if(!res.object){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Note successfully deleted"
                                                                message:@""
                                                               delegate:self
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
                [alert setTag:2];
                [alert show];
                [alert release];
                
            }
        }
    }
}


@end
