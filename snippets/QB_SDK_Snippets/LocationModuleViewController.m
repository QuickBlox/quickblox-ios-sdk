//
//  LocationModuleViewController.m
//  QB_SDK_Samples
//
//  Created by Igor Khomenko on 6/12/12.
//  Copyright (c) 2012 Injoit. All rights reserved.
//

#import "LocationModuleViewController.h"

@interface LocationModuleViewController ()

@end

@implementation LocationModuleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Location", @"Location");
        self.tabBarItem.image = [UIImage imageNamed:@"circle"];
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0){
        return 6;
    }
    return 5;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(section == 0){
        return @"GeoData";
    }
    
    return @"Places";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    
    switch (indexPath.section) {
            // GeoData
        case 0:
            switch (indexPath.row) {
                // Create GeoData
                case 0:{
                    QBLGeoData *geodata = [QBLGeoData geoData];
                    geodata.latitude = 23.2344;
                    geodata.longitude = -12.23523;
                    geodata.status = @"Hello, world";
                    
                    if(withContext){
                        [QBLocation createGeoData:geodata delegate:self context:testContext];
                    }else{
                        [QBLocation createGeoData:geodata delegate:self];
                    } 
                }
                    break;
                    
                // Get GeoData with ID
                case 1:{
                    if(withContext){
                        [QBLocation geoDataWithID:34706 delegate:self context:testContext];
                    }else{
                        [QBLocation geoDataWithID:34706 delegate:self];
                    } 
                }
                    break;
                    
                // Get multiple GeoData
                case 2:{
                    QBLGeoDataGetRequest *getRequest = [[QBLGeoDataGetRequest alloc] init];
                    getRequest.status = YES;
                    getRequest.lastOnly = YES;
                    getRequest.sortBy = GeoDataSortByKindLatitude;
                    getRequest.radius = 100;
                    getRequest.currentPosition = CLLocationCoordinate2DMake(23.55, -12.66);
                    
                    if(withContext){
                        [QBLocation geoDataWithRequest:getRequest delegate:self context:testContext];
                    }else{
                        [QBLocation geoDataWithRequest:getRequest delegate:self];
                    } 
                    
                    [getRequest release];

                }
                    break;
                    
                // Update GeoData
                case 3:{
                    QBLGeoData *geodata = [QBLGeoData geoData];
                    geodata.ID = 125176;
                    geodata.latitude = 43.2344;
                    geodata.longitude = -12.23523;
                    geodata.status = @"Hello, Man!";
                    
                    if(withContext){
                        [QBLocation updateGeoData:geodata delegate:self context:testContext];
                    }else{
                        [QBLocation updateGeoData:geodata delegate:self];
                    } 
                }
                    break;
                    
                // Delete GeoData with ID
                case 4:{
                    if(withContext){
                        [QBLocation deleteGeoDataWithID:34640 delegate:self context:testContext];
                    }else{
                        [QBLocation deleteGeoDataWithID:34640 delegate:self];
                    } 

                }
                    break;
                    
                // Delete multiple GeoData
                case 5:{
                    QBLGeoDataDeleteRequest *deleteRequest = [[QBLGeoDataDeleteRequest alloc] init];
                    deleteRequest.days = 5;
                    
                    if(withContext){
                        [QBLocation deleteGeoDataWithRequest:deleteRequest delegate:self context:testContext];
                    }else{
                        [QBLocation deleteGeoDataWithRequest:deleteRequest delegate:self];
                    } 
                    
                    [deleteRequest release];
                }
                    break;
            }
            
            break;
            
        // Places    
        case 1:
            switch (indexPath.row) {
                // Create Place
                case 0:{
                    QBLPlace *place = [QBLPlace place];
                    place.geoDataID = 34691;
                    place.photoID = 447;
                    place.title = @"My place title";
                    place.address = @"London, Gadge st, 34";
                    place.placeDescription = @"My place description";
                    
                    if(withContext){
                        [QBLocation createPlace:place delegate:self context:testContext];
                    }else{
                        [QBLocation createPlace:place delegate:self];
                    } 
                }
                    break;
                    
                // Get Places
                case 1:{
                    if(withAdditionalRequest){
                        PagedRequest *pagedRequest = [[PagedRequest alloc] init];
                        pagedRequest.perPage = 2;
                        pagedRequest.page = 1;
                        
                        if(withContext){
                            [QBLocation placesWithPagedRequest:pagedRequest delegate:self context:testContext];
                        }else{
                            [QBLocation placesWithPagedRequest:pagedRequest delegate:self];
                        }  
                        
                        [pagedRequest release];
                    }else{
                        if(withContext){
                            [QBLocation placesWithDelegate:self context:testContext];
                        }else{
                            [QBLocation placesWithDelegate:self];
                        }  
                    }
                }
                    break;
                    
                // Get Place with ID
                case 2:{
                    if(withContext){
                        [QBLocation placeWithID:1190 delegate:self context:testContext];
                    }else{
                        [QBLocation placeWithID:1190 delegate:self];
                    }  
                }
                    break;
                    
                // Update Place
                case 3:{
                    QBLPlace *place = [QBLPlace place];
                    place.ID = 1228;
                    place.placeDescription = @"Cool place";
                    place.title = @"Great place";
                    
                    if(withContext){
                        [QBLocation updatePlace:place delegate:self context:testContext];
                    }else{
                        [QBLocation updatePlace:place delegate:self];
                    }  
                }
                    break;
                    
                // Delete Place with ID
                case 4:{
                    if(withContext){
                        [QBLocation deletePlaceWithID:1230 delegate:self context:testContext];
                    }else{
                        [QBLocation deletePlaceWithID:1230 delegate:self];
                    } 
                }
                    break;
            }
            
            break;
            
        default:
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *reuseIdentifier = [NSString stringWithFormat:@"%d", indexPath.row];
    
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if(cell == nil){
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    switch (indexPath.section) {
        // GeoData
        case 0:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"Create GeoData";
                    break;
                case 1:
                    cell.textLabel.text = @"Get GeoData with ID";
                    break;
                case 2:
                    cell.textLabel.text = @"Get multiple GeoData";
                    break;
                case 3:
                    cell.textLabel.text = @"Update GeoData";
                    break;
                case 4:
                    cell.textLabel.text = @"Delete GeoData with ID";
                    break;
                case 5:
                    cell.textLabel.text = @"Delete multiple GeoData";
                    break;
            }

            break;
            
        // Places    
        case 1:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"Create Place";
                    break;
                case 1:
                    cell.textLabel.text = @"Get Places";
                    break;
                case 2:
                    cell.textLabel.text = @"Get Place with ID";
                    break;
                case 3:
                    cell.textLabel.text = @"Update Place";
                    break;
                case 4:
                    cell.textLabel.text = @"Delete Place with ID";
                    break;
            }

            break;
            
        default:
            break;
    }
    
    return cell;
}

// QuickBlox queries delegate
- (void)completedWithResult:(Result *)result{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    // success result
    if(result.success){
        
        // Create/Get/Update/Delete GeoData result
        if([result isKindOfClass:QBLGeoDataResult.class]){
            QBLGeoDataResult *res = (QBLGeoDataResult *)result;
            NSLog(@"QBLGeoDataResult, geodata=%@", res.geoData);
       
        // Get multiple GeoData result
        }else if([result isKindOfClass:QBLGeoDataPagedResult.class]){
            QBLGeoDataPagedResult *res = (QBLGeoDataPagedResult *)result;
            NSLog(@"QBLGeoDataPagedResult, geodata=%@", res.geodata);
        
        // Create/Get/Update/Delete Place result
        }else if([result isKindOfClass:QBLPlaceResult.class]){
            QBLPlaceResult *res = (QBLPlaceResult *)result;
            NSLog(@"QBLPlaceResult, place=%@", res.place);
            
        // Get places
        }else if([result isKindOfClass:QBLPlacePagedResult.class]){
            QBLPlacePagedResult *res = (QBLPlacePagedResult *)result;
            NSLog(@"QBLPlacePagedResult, places=%@", res.places);
        }

        
    }else{
        NSLog(@"Errors=%@", result.errors); 
    }
}

// QuickBlox queries delegate (with context)
- (void)completedWithResult:(Result *)result context:(void *)contextInfo{
    NSLog(@"completedWithResult, context=%@", contextInfo);
    
    [self completedWithResult:result];
}

@end
