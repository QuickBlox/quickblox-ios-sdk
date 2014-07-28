//
//  NewNoteViewController.m
//  SimpleSample-custom-object-ios
//
//  Created by Ruslan on 9/14/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "SSCONewNoteViewController.h"

@interface SSCONewNoteViewController () <UITextViewDelegate>

@property (strong, nonatomic) IBOutlet UITextView *noteTextField;
@property (strong, nonatomic) IBOutlet UITextView *commentTextField;

@end

@implementation SSCONewNoteViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Add note";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(save:)];
}

- (void)save:(id)sender
{
    if (self.noteTextField.text.length && self.commentTextField.text.length) {
        // Create note
        QBCOCustomObject *object = [QBCOCustomObject customObject];
        object.className = customClassName;
        (object.fields)[@"note"] = self.noteTextField.text;
        (object.fields)[@"comment"] = self.commentTextField.text;
        (object.fields)[@"status"] = @"New";
        
        [QBRequest createObject:object successBlock:^(QBResponse *response, QBCOCustomObject *object) {
            [[SSCONotesStorage shared] addNote:object];
            
            [self.navigationController popViewControllerAnimated:YES];
        } errorBlock:^(QBResponse *response) {
            NSLog(@"Response error: %@", [response.error description]);
        }];
    } else {
        UIAlertView *allert = [[UIAlertView alloc] initWithTitle:@"Errors"
                                                         message:@"Please fill both Note & Comment fields"
                                                        delegate:self
                                               cancelButtonTitle:@"Ok"
                                               otherButtonTitles:nil];
        [allert show];
    }
}

#pragma mark -
#pragma mark UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]){
        [textView resignFirstResponder];
    }
    
    return YES;
}

@end
