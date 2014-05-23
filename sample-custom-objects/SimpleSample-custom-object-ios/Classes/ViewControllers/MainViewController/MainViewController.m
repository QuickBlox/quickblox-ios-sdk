//
//  MainViewController.m
//  SimpleSample-custom-object-ios
//
//  Created by Ruslan on 9/14/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "MainViewController.h"
#import "NoteDetailsViewController.h"
#import "NewNoteViewController.h"
#import "CustomTableViewCell.h"

@interface MainViewController ()

@end

@implementation MainViewController
@synthesize tableView;
@synthesize searchBar;
@synthesize searchArray;

- (id)init{
    self = [super init];
    if (self) {
        searchArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"Notes"];
}

- (void)viewDidAppear:(BOOL)animated{
    [self.searchArray removeAllObjects];
    [self.searchArray addObjectsFromArray:[[DataManager shared] notes]];
    [self.tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [tableView release];
    [searchBar release];
    [searchArray release];
    [super dealloc];
}

- (IBAction)addNewNote:(id)sender {
    NewNoteViewController *newNoteViewController = [[NewNoteViewController alloc] init];
    [self presentModalViewController:newNoteViewController animated:YES];
    [newNoteViewController release];
}


#pragma mark -
#pragma mark TableViewDataSource & TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.searchBar resignFirstResponder];
    
    // Show particular note
    NoteDetailsViewController *noteDetailsViewController = [[NoteDetailsViewController alloc] init];
    QBCOCustomObject *customObject = (QBCOCustomObject *)[[[DataManager shared] notes] objectAtIndex:indexPath.row];
    noteDetailsViewController.customObject = customObject;
    [self.navigationController pushViewController:noteDetailsViewController animated:YES];
    [noteDetailsViewController release];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.searchArray count];
}

// Making table view using custom cells
- (UITableViewCell*)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* SimpleTableIdentifier = @"SimpleTableIdentifier";
    
    CustomTableViewCell* cell = [_tableView dequeueReusableCellWithIdentifier:SimpleTableIdentifier];
    if (cell == nil){
        cell = [[[CustomTableViewCell alloc] init] autorelease];
    }
    
    // set note name & status
    [cell.noteLabel setText:[[[self.searchArray objectAtIndex:indexPath.row] fields] objectForKey:@"note"]];
    [cell.statusLabel setText:[[[self.searchArray objectAtIndex:indexPath.row] fields] objectForKey:@"status"]];
    
    // set createdAt/updatedAt date
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"yyyy-MMMM-dd HH:mm"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
    NSString *stringFromDate;
    if([[[[DataManager shared] notes] objectAtIndex:indexPath.row] updatedAt]){
        stringFromDate = [formatter stringFromDate:[[self.searchArray objectAtIndex:indexPath.row] updatedAt]];
    }else{
        stringFromDate = [formatter stringFromDate:[[self.searchArray objectAtIndex:indexPath.row] createdAt]];
    }
    [cell.dataLabel setText:stringFromDate];
    [formatter release];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}


#pragma mark -
#pragma mark UISearchBarDelegate

-(void) searchBarSearchButtonClicked:(UISearchBar *)SearchBar{
    [self.searchBar resignFirstResponder];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    [self.searchArray removeAllObjects];
    
    if([searchText length] == 0){
        [self.searchArray addObjectsFromArray:[[DataManager shared] notes]];
        [self.searchBar resignFirstResponder];
        
    // search
    }else{
        for(QBCOCustomObject *object in [[DataManager shared] notes]){
            NSRange note = [[object.fields objectForKey:@"note"] rangeOfString:searchText options:NSCaseInsensitiveSearch];
            if(note.location != NSNotFound){
                [self.searchArray addObject:object];
            }
        }
    }
    
    [self.tableView reloadData];
}

@end
