//
//  NoteDetailsViewController.m
//  SimpleSample-custom-object-ios
//
//  Created by Ruslan on 9/14/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "SSCONoteDetailsViewController.h"

@interface SSCONoteDetailsViewController () <UIAlertViewDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) IBOutlet UILabel *noteLabel;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UITextView *comentsTextView;

@end

@implementation SSCONoteDetailsViewController

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
    [self reloadData];
    
    self.title = @"Note";
}

- (void(^)(QBResponse *))handleErrorBlock
{
    return ^(QBResponse *response) {
        NSLog(@"Response error: %@", [response.error description]);
    };
}

- (IBAction)addComment:(id)sender
{
    // Show alert for enter new comment
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New comment"
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Add", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    [alert show];
}

- (IBAction)changeStatus:(id)sender
{
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select status"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"New", @"In Progress", @"Done", nil];
    
    [actionSheet showInView:self.view];
}

- (IBAction)deleteNote:(id)sender
{
    // remove note
    [QBRequest deleteObjectWithID:self.customObject.ID className:customClassName successBlock:^(QBResponse *response) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Note successfully deleted"
                                                        message:@""
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert setTag:2];
        [alert show];
    } errorBlock:[self handleErrorBlock]];
    
    [[SSCONotesStorage shared] removeNote:self.customObject];
}

- (void)reloadData
{
    // set note & status
    self.noteLabel.text = self.customObject.fields[@"note"];
    self.statusLabel.text = self.customObject.fields[@"status"];
    
    // set comments
    NSString *commentsAsString = self.customObject.fields[@"comment"];
    if (![commentsAsString isKindOfClass:NSNull.class]) {
        NSArray *comments = [commentsAsString componentsSeparatedByString:@"-c-"];
        [self.comentsTextView setText:nil];
        int count = 1;
        for (NSString *comment in comments) {
            if (count == 1) {
                NSString *str = [[NSString alloc] initWithFormat:@"#%d %@\n\n",count, comment];
                [self.comentsTextView setText:str];
            } else {
                NSString *str = [[NSString alloc] initWithFormat:@"%@#%d %@\n\n", self.comentsTextView.text, count, comment];
                [self.comentsTextView setText:str];
            }
            count++;
        }
    }
}


#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSString *status = nil;
    switch (buttonIndex) {
        case 0: {
            status = @"New";
            break;
        }
        case 1: {
            status = @"In Progress";
            break;
        }
        case 2: {
            status = @"Done";
            break;
        }
    }
    
    if (status) {
        // chabge status & update custom object
        self.customObject.fields[@"status"] = status;
        [QBRequest updateObject:self.customObject successBlock:nil errorBlock:[self handleErrorBlock]];
        
        // refresh table
        [self reloadData];
    }
}

#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // delete note alert
    if (alertView.tag == 2) {
        [self.navigationController popViewControllerAnimated:YES];
        
    // Add new comment alert
    } else {
        switch (buttonIndex) {
            case 1: {
                // change comments & update custom object
                NSString *comments = [[NSString alloc] initWithFormat:@"%@-c-%@", self.customObject.fields[@"comment"], [alertView textFieldAtIndex:0].text];

                self.customObject.fields[@"comment"] = comments;
            
                [QBRequest updateObject:self.customObject successBlock:nil errorBlock:[self handleErrorBlock]];
            
                // refresh table
                [self reloadData];
            
                break;
            }
            default:
                break;
        }
    }
}

@end
