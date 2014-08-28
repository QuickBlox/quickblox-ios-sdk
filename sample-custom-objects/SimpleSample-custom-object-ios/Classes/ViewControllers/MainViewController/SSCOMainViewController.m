//
//  MainViewController.m
//  SimpleSample-custom-object-ios
//
//  Created by Ruslan on 9/14/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "SSCOMainViewController.h"
#import "SSCONoteDetailsViewController.h"
#import "SSCONewNoteViewController.h"
#import "CustomTableViewCell.h"

@interface SSCOMainViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *searchArray;
@property (readonly) NSDateFormatter* dateFormatter;

@end

@implementation SSCOMainViewController

- (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter* dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"yyyy-MMMM-dd HH:mm";
        dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"..."];
    });
    return dateFormatter;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.searchArray = [NSMutableArray array];
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.hidesBackButton = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Notes";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Add note" style:UIBarButtonItemStylePlain
                                                                             target:self action:@selector(addNewNote:)];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.searchArray removeAllObjects];
    [self.searchArray addObjectsFromArray:[[SSCONotesStorage shared] notes]];
    [self.tableView reloadData];
}

- (void)addNewNote:(id)sender
{
    SSCONewNoteViewController *newNoteViewController = [SSCONewNoteViewController new];
    [self.navigationController pushViewController:newNoteViewController animated:YES];
}

#pragma mark -
#pragma mark TableViewDataSource & TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.searchDisplayController.searchBar resignFirstResponder];
    
    // Show particular note
    SSCONoteDetailsViewController *noteDetailsViewController = [[SSCONoteDetailsViewController alloc] init];
    QBCOCustomObject *customObject = (QBCOCustomObject *)[[SSCONotesStorage shared] notes][indexPath.row];
    noteDetailsViewController.customObject = customObject;
    [self.navigationController pushViewController:noteDetailsViewController animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.searchArray count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* SimpleTableIdentifier = @"SimpleTableIdentifier";
    
    CustomTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:SimpleTableIdentifier];
    if (cell == nil) {
        cell = [[CustomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SimpleTableIdentifier];
    }
    
    QBCOCustomObject* object = (self.searchArray)[indexPath.row];
    
    // set note name & status
    cell.noteLabel.text = object.fields[@"note"];
    cell.statusLabel.text = object.fields[@"status"];
    
    // set createdAt/updatedAt date
    NSString *stringFromDate = nil;
    if (object.updatedAt) {
        stringFromDate = [self.dateFormatter stringFromDate:object.updatedAt];
    } else {
        stringFromDate = [self.dateFormatter stringFromDate:object.createdAt];
    }
    
    cell.dataLabel.text = stringFromDate;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

#pragma mark -
#pragma mark UISearchDisplayControllerDelegate

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    [self.searchArray removeAllObjects];
    
    if ([searchText length] == 0) {
        [self.searchArray addObjectsFromArray:[[SSCONotesStorage shared] notes]];
        [self.searchDisplayController.searchBar resignFirstResponder];
    } else {
        for (QBCOCustomObject *object in [[SSCONotesStorage shared] notes]) {
            NSRange note = [(object.fields)[@"note"] rangeOfString:searchText options:NSCaseInsensitiveSearch];
            if (note.location != NSNotFound) {
                [self.searchArray addObject:object];
            }
        }
    }
    
    [self.tableView reloadData];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    NSString* scope = [self.searchDisplayController.searchBar scopeButtonTitles][[self.searchDisplayController.searchBar selectedScopeButtonIndex]];
    [self filterContentForSearchText:searchString
                               scope:scope];
    
    return YES;
}

@end
