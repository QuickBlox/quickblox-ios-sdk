//
//  NewNoteViewController.m
//  SimpleSample-custom-object-ios
//
//  Created by Ruslan on 9/14/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "NewNoteViewController.h"
#import "DataManager.h"

@interface NewNoteViewController ()

@end

@implementation NewNoteViewController
@synthesize commentTextField;
@synthesize noteTextField;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)next:(id)sender {
    
    if(self.noteTextField.text.length && self.commentTextField.text.length){
        
        // Create note
        QBCOCustomObject *object = [QBCOCustomObject customObject];
        object.className = customClassName;
        [object.fields setObject:self.noteTextField.text forKey:@"note"];
        [object.fields setObject:self.commentTextField.text forKey:@"comment"];
        [object.fields setObject:@"New" forKey:@"status"];
        
        [QBCustomObjects createObject:object delegate:self];
        
    }else {
        UIAlertView *allert = [[UIAlertView alloc] initWithTitle:@"Errors"
                                                         message:@"Please feel both Note & Comment fields"
                                                        delegate:self
                                               cancelButtonTitle:@"Ok"
                                               otherButtonTitles:nil];
        [allert show];
    }
}


#pragma mark -
#pragma mark UITextViewDelegate

- (BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]){
        [textView resignFirstResponder];
    }
    
    return YES;
}


#pragma mark -
#pragma mark QBActionStatusDelegate

// QuickBlox API queries delegate
-(void)completedWithResult:(Result*)result{
    
    // Create custom object result
    if([result isKindOfClass:QBCOCustomObjectResult.class]){

        // Success result
        if(result.success){
            QBCOCustomObjectResult *res = (QBCOCustomObjectResult *)result;
            
            NSLog(@"new obj: %@", res.object);
            
            // add note to storage
            [[[DataManager shared] notes] addObject:res.object];
            
            // hide screen
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

@end
