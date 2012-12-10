//
//  MapViewController.m
//  SimpleSample-chat_users-ios
//
//  Created by Alexey Voitenko on 24.02.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "ChatViewController.h"
#import "CustomTableViewCellCell.h"

@implementation ChatViewController


@synthesize loginController;
@synthesize registrationController;
@synthesize currentUser = _currentUser;
@synthesize textField;
@synthesize messages, myTableView, _cell, messagesIdsArray;

- (void)dealloc
{
    [messagesIdsArray release];
    [_cell release];
    [myTableView release];
    [textField release];
    [loginController release];
    [registrationController release];
    [_currentUser release];
    [messages release];
    [super dealloc];
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
                        // create an array of message for current user
    if (self)
    {
        messagesIdsArray = [[NSMutableArray alloc] init];
        messages = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // retrieve messages
    [self retrieveMessages:nil];
    
    // Retrieve new messages every 30 sec
    [NSTimer scheduledTimerWithTimeInterval:30.0
                                     target:self
                                   selector:@selector(retrieveMessages:)
                                   userInfo:nil
                                    repeats:YES];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [textField resignFirstResponder];                   // hide keyboard
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// retrieve messages
- (void) retrieveMessages:(NSTimer *) timer{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    // create QBLGeoDataSearchRequest entity
	QBLGeoDataSearchRequest *searchRequest = [[QBLGeoDataSearchRequest alloc] init];
	searchRequest.status = YES;
    searchRequest.sort_by = GeoDataSortByKindCreatedAt;             // sorted by the date of creation
    searchRequest.perPage = 15; // last 15 messages                 
    
    // retrieve messages
	[QBLocationService findGeoData:searchRequest delegate:self];
	
    [searchRequest release];
}

// Create new message
- (IBAction) send:(id)sender
{
    // Show alert if user did not logged in
    if(_currentUser == nil)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You must first be authorized." message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Sign Up", @"Sign In", nil];
        [alert show];
        [alert release];
        return;
    }
    
    if([textField.text length] == 0){
        return;
    }
    
    // hide keyboard
    [self dismissKeyboard];
    
    
                                            // if user is not authorised - 
    // create QBLGeoData entity
    QBLGeoData *geoData = [QBLGeoData currentGeoData];
	geoData.user = _currentUser;
    geoData.status = textField.text;
    
    // create new message
	[QBLocationService postGeoData:geoData delegate:self];              // send message with status(message text) and coordinates
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}


#pragma mark -
#pragma mark ActionStatusDelegate

// QuickBlox API queries delegate
- (void)completedWithResult:(Result *)result
{
     [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    // Retrieve messages result
    if([result isKindOfClass:[QBLGeoDataPagedResult class]])        
    {
        // Success result
        if (result.success)
        {
            QBLGeoDataPagedResult *geoDataSearchRes = (QBLGeoDataPagedResult *)result;

            // update table
            BOOL isChanged = NO;
            for (QBLGeoData* geodata in geoDataSearchRes.geodatas)          // check if there is new message
            {
                NSNumber *geodataID = [NSNumber numberWithUnsignedInteger:geodata.ID];
                if(![messagesIdsArray containsObject:geodataID])
                {
                    isChanged = YES;
                    [messagesIdsArray addObject:geodataID];
                    [messages addObject:geodata];
                }
            }
            
            if(isChanged)
            {
                [myTableView reloadData];
            }
        
        // Errors
        }else{
            NSLog(@"Errors=%@", result.errors);
        }
        
    // Create new message result - don't need to reload all messages    
    }else if ([result isKindOfClass:[QBLGeoDataResult class]]){
        
        // Success result
        if (result.success)
        {
            // add new message to table
            NSIndexPath* newMessageIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            ((QBLGeoDataResult*)result).geoData.user = _currentUser;
            [messages insertObject:((QBLGeoDataResult*)result).geoData atIndex:0];
    
            [myTableView insertRowsAtIndexPaths:[NSArray arrayWithObjects:newMessageIndexPath, nil] withRowAnimation:UITableViewRowAnimationTop];
        
        // Errors
        }else{
            NSLog(@"Errors=%@", result.errors);
        }
    }
}

#pragma mark -
#pragma mark UITableViewDataSource & UITableViewDelegate

- (NSIndexPath*)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [textField resignFirstResponder];
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.messages count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* SimpleTableIdentifier = @"SimpleTableIdentifier";
    
    CustomTableViewCellCell* cell = [tableView dequeueReusableCellWithIdentifier:SimpleTableIdentifier];
    if (cell == nil)
    {
        [[NSBundle mainBundle] loadNibNamed:@"CustomTableViewCell" owner:self options:nil];
        cell = _cell;
    }
    QBLGeoData* geodata = [messages objectAtIndex:[indexPath row]];
    
    cell.user.text = geodata.user.login;
    cell.status.text = geodata.status;
    cell.lon.text = [NSString stringWithFormat:@"%0.4f", geodata.longitude];
    cell.lat.text = [NSString stringWithFormat:@"%0.4f", geodata.latitude];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 66;
}


#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) 
    {
        case 1:
            // show registration controller
            [self presentModalViewController:registrationController animated:YES];
            break;
        case 2:
            // show login controller
            [self presentModalViewController:loginController animated:YES];
            break;
        default:
            break;
    }
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)_textField
{
    [_textField resignFirstResponder];
    [self send:_textField];
    return YES;
}

- (void)textFieldDoneEditing:(id)sender
{
    [sender resignFirstResponder];
}

-(void)dismissKeyboard
{
    [textField resignFirstResponder];
}

@end
