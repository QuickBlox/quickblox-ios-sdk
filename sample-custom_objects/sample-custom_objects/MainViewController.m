//
//  ViewController.m
//  sample-custom_objects
//
//  Created by Igor Khomenko on 6/10/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import "MainViewController.h"
#import "ObjectsPaginator.h"
#import "Storage.h"
#import "MovieDetailsViewController.h"
#import <Quickblox/Quickblox.h>
#import <SVProgressHUD.h>

@interface MainViewController () <UITableViewDelegate, UITableViewDataSource, NMPaginatorDelegate>

@property (nonatomic, strong) ObjectsPaginator *paginator;
@property (nonatomic, strong) UILabel *footerLabel;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.paginator = [[ObjectsPaginator alloc] initWithPageSize:10 delegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        [self setupTableViewFooter];
        
        [SVProgressHUD showWithStatus:@"Downloading movies"];
        
        // Your app connects to QuickBlox server here.
        //
        QBSessionParameters *parameters = [QBSessionParameters new];
        parameters.userLogin = @"igorquickblox2";
        parameters.userPassword = @"igorquickblox2";
        
        [QBRequest createSessionWithExtendedParameters:parameters successBlock:^(QBResponse *response, QBASession *session) {
            
            // Load objects
            //
            [self.paginator fetchFirstPage];
            
        }errorBlock:^(QBResponse *response) {
            NSLog(@"Response error %@:", response.error);
        }];
    });
    
    [self.tableView reloadData];
}


#pragma mark
#pragma mark Paginator

- (void)fetchNextPage
{
    [self.paginator fetchNextPage];
    [self.activityIndicator startAnimating];
}

- (void)setupTableViewFooter
{
    // set up label
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    footerView.backgroundColor = [UIColor clearColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    label.font = [UIFont boldSystemFontOfSize:16];
    label.textColor = [UIColor lightGrayColor];
    label.textAlignment = NSTextAlignmentCenter;
    
    self.footerLabel = label;
    [footerView addSubview:label];
    
    // set up activity indicator
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicatorView.center = CGPointMake(40, 22);
    activityIndicatorView.hidesWhenStopped = YES;
    
    self.activityIndicator = activityIndicatorView;
    [footerView addSubview:activityIndicatorView];
    
    self.tableView.tableFooterView = footerView;
}

- (void)updateTableViewFooter
{
    if ([self.paginator.results count] != 0){
        self.footerLabel.text = [NSString stringWithFormat:@"%lu results out of %ld",
                                 (unsigned long)[self.paginator.results count], (long)self.paginator.total];
    }else{
        self.footerLabel.text = @"";
    }
    
    [self.footerLabel setNeedsDisplay];
}


#pragma mark
#pragma mark Storyboard

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UITableViewCell *)sender{
    if([segue.destinationViewController isKindOfClass:MovieDetailsViewController.class]){
        
        NSUInteger row = sender.tag;
        QBCOCustomObject *movie = [Storage instance].moviesList[row];
        
        MovieDetailsViewController *destinationViewController = (MovieDetailsViewController *)segue.destinationViewController;
        destinationViewController.movie = movie;
    }
}


#pragma mark
#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    // when reaching bottom, load a new page
    if (scrollView.contentOffset.y == scrollView.contentSize.height - scrollView.bounds.size.height){
        // ask next page only if we haven't reached last page
        if(![self.paginator reachedLastPage]){
            // fetch next page of results
            [self fetchNextPage];
        }
    }
}


#pragma mark
#pragma mark UITableViewDelegate & UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[Storage instance].moviesList count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MovieCellIdentifier"];
    cell.tag = indexPath.row;
    
    QBCOCustomObject *movie = [Storage instance].moviesList[indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@). Rating: %@",
                           movie.fields[@"name"], movie.fields[@"year"], movie.fields[@"rating"]];
    cell.detailTextLabel.text = movie.fields[@"description"];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}


#pragma mark
#pragma mark NMPaginatorDelegate

- (void)paginator:(id)paginator didReceiveResults:(NSArray *)results
{
    // save files
    //
    [[Storage instance].moviesList addObjectsFromArray:results];
    
    // update tableview footer
    [self updateTableViewFooter];
    [self.activityIndicator stopAnimating];
    
    // reload table
    [self.tableView reloadData];
    [SVProgressHUD dismiss];
}

@end
