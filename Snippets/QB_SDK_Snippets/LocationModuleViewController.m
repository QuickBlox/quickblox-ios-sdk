//
//  LocationModuleViewController.m
//  QB_SDK_Samples
//
//  Created by Igor Khomenko on 6/12/12.
//  Copyright (c) 2012 Injoit. All rights reserved.
//

#import "LocationModuleViewController.h"
#import "LocationDataSource.h"


@interface LocationModuleViewController ()
@property (nonatomic) LocationDataSource *dataSource;
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

- (void)viewDidLoad{
    [super viewDidLoad];
    self.dataSource = [[LocationDataSource alloc] init];
    tableView.dataSource = self.dataSource;
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
                    
					if (useNewAPI) {
						[QBRequest createGeoData:geodata successBlock:^(QBResponse *response, QBLGeoData *geoData) {
							NSLog(@"Successfull response!");
						} errorBlock:^(QBResponse *response) {
							NSLog(@"Response error:%@", response.error);
						}];
					} else {
						if (withQBContext) {
							[QBLocation createGeoData:geodata delegate:self context:testContext];
						} else {
							[QBLocation createGeoData:geodata delegate:self];
						}
					}
                }
                    break;
                    
                // Get GeoData with ID
                case 1:{
					
					if (useNewAPI) {
						[QBRequest geoDataWithId:1150373 successBlock:^(QBResponse *response, QBLGeoData *geoData) {
							NSLog(@"Successfull response!");
						} errorBlock:^(QBResponse *response) {
							NSLog(@"Response error:%@", response.error);
						}];
					} else {
						if(withQBContext){
							[QBLocation geoDataWithID:1150373 delegate:self context:testContext];
						}else{
							[QBLocation geoDataWithID:1150373 delegate:self];
						}
					}
					
                }
                    break;
                    
                // Get multiple GeoData
                case 2:{
					if (useNewAPI) {
						QBLGeoDataFilter* filter = [QBLGeoDataFilter new];
						filter.status = YES;
						filter.lastOnly = YES;
//						filter.sortBy = GeoDataSortByKindLatitude;
//						filter.radius = 0.4;
//						filter.currentPosition = CLLocationCoordinate2DMake(23.55,  -12.68);
						
						[QBRequest geoDataWithFilter:filter page:[QBGeneralResponsePage responsePageWithCurrentPage:1 perPage:10]
										successBlock:^(QBResponse *response, NSArray *objects, QBGeneralResponsePage *page) {
							NSLog(@"Successfull response!");
						} errorBlock:^(QBResponse *response) {
							NSLog(@"Response error:%@", response.error);
						}];
					} else {
	                    QBLGeoDataGetRequest *getRequest = [[QBLGeoDataGetRequest alloc] init];
    	                getRequest.page = 1;
        	            getRequest.perPage = 100;
            	        getRequest.status = YES;
                	    getRequest.lastOnly = YES;
//                    	getRequest.sortBy = GeoDataSortByKindDistance;
//                    	getRequest.radius = 1000;
//                    	getRequest.userID = 1279282;
//                    	getRequest.currentPosition = CLLocationCoordinate2DMake(23.55445567, -76.66);

						if(withQBContext){
							[QBLocation geoDataWithRequest:getRequest delegate:self context:testContext];
						}else{
							[QBLocation geoDataWithRequest:getRequest delegate:self];
						}
					}
                }
                    break;
                    
                // Update GeoData
                case 3:{
                    QBLGeoData *geodata = [QBLGeoData geoData];
                    geodata.ID = 1150373;
                    geodata.latitude = 43.2344;
                    geodata.longitude = -12.23523;
                    geodata.status = @"Hello, Man!";
                    
					if (useNewAPI) {
						[QBRequest updateGeoData:geodata successBlock:^(QBResponse *response, QBLGeoData *geoData) {
							NSLog(@"Successfull response!");
						} errorBlock:^(QBResponse *response) {
							NSLog(@"Response error:%@", response.error);
						}];
					} else {
						if(withQBContext){
							[QBLocation updateGeoData:geodata delegate:self context:testContext];
						}else{
							[QBLocation updateGeoData:geodata delegate:self];
						}
					}
					
                }
                    break;
                    
                // Delete GeoData with ID
                case 4:{
					if (useNewAPI) {
						[QBRequest deleteGeoDataWithID:1150373 successBlock:^(QBResponse *response) {
							NSLog(@"Successfull response!");
						} errorBlock:^(QBResponse *response) {
							NSLog(@"Response error:%@", response.error);
						}];
					} else {
						if(withQBContext){
							[QBLocation deleteGeoDataWithID:1150373 delegate:self context:testContext];
						}else{
							[QBLocation deleteGeoDataWithID:1150373 delegate:self];
						}
					}
                }
                    break;
                    
                // Delete multiple GeoData
                case 5:{
                    QBLGeoDataDeleteRequest *deleteRequest = [[QBLGeoDataDeleteRequest alloc] init];
                    deleteRequest.days = 5;
                    
					if (useNewAPI) {
						[QBRequest deleteGeoDataWithRemainingDays:5 successBlock:^(QBResponse *response) {
							NSLog(@"Successfull response!");
						} errorBlock:^(QBResponse *response) {
							NSLog(@"Response error:%@", response.error);
						}];
					} else {
						if(withQBContext){
							[QBLocation deleteGeoDataWithRequest:deleteRequest delegate:self context:testContext];
						}else{
							[QBLocation deleteGeoDataWithRequest:deleteRequest delegate:self];
						}
					}
                    
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
                    place.geoDataID = 1150377;
                    place.photoID = 215481;
                    place.title = @"My place title";
                    place.address = @"London, Gadge st, 34";
                    place.placeDescription = @"My place description";
                    
					if (useNewAPI) {
						[QBRequest createPlace:place successBlock:^(QBResponse *response, QBLPlace *place) {
							NSLog(@"Successfull response!");
						} errorBlock:^(QBResponse *response) {
							NSLog(@"Response error:%@", response.error);
						}];
					} else {
						if(withQBContext){
							[QBLocation createPlace:place delegate:self context:testContext];
						}else{
							[QBLocation createPlace:place delegate:self];
						}
					}

                }
                    break;
                    
                // Get Places
                case 1:{
					if (useNewAPI) {
						[QBRequest placesForPage:[QBGeneralResponsePage responsePageWithCurrentPage:1 perPage:10]
									successBlock:^(QBResponse *response, NSArray *objects, QBGeneralResponsePage *page) {
							NSLog(@"Successfull response!");
						} errorBlock:^(QBResponse *response) {
							NSLog(@"Response error:%@", response.error);
						}];
					} else {
						if(withAdditionalRequest){
							PagedRequest *pagedRequest = [[PagedRequest alloc] init];
							pagedRequest.perPage = 2;
							pagedRequest.page = 1;
							
							
							if(withQBContext){
								[QBLocation placesWithPagedRequest:pagedRequest delegate:self context:testContext];
							}else{
								[QBLocation placesWithPagedRequest:pagedRequest delegate:self];
							}  
                        }else{
							if(withQBContext){
								[QBLocation placesWithDelegate:self context:testContext];
							}else{
								[QBLocation placesWithDelegate:self];
							}  
						}
					}
                }
                    break;
                    
                // Get Place with ID
                case 2:{
					if (useNewAPI) {
						[QBRequest placeWithID:34654 successBlock:^(QBResponse *response, QBLPlace *place) {
							NSLog(@"Successfull response!");
						} errorBlock:^(QBResponse *response) {
							NSLog(@"Response error:%@", response.error);
						}];
					} else {
						if(withQBContext){
							[QBLocation placeWithID:1190 delegate:self context:testContext];
						}else{
							[QBLocation placeWithID:1190 delegate:self];
						}
					}
                }
                    break;
                    
                // Update Place
                case 3:{
                    QBLPlace *place = [QBLPlace place];
                    place.ID = 34654;
                    place.placeDescription = @"Cool place";
                    place.title = @"Great place";
                    
					if (useNewAPI) {
						[QBRequest updatePlace:place successBlock:^(QBResponse *response, QBLPlace *place) {
							NSLog(@"Successfull response!");
						} errorBlock:^(QBResponse *response) {
							NSLog(@"Response error:%@", response.error);
						}];
					} else {
						if(withQBContext){
							[QBLocation updatePlace:place delegate:self context:testContext];
						}else{
							[QBLocation updatePlace:place delegate:self];
						}
					}
                }
                    break;
                    
                // Delete Place with ID
                case 4:{
					if (useNewAPI) {
						[QBRequest deletePlaceWithID:34655 successBlock:^(QBResponse *response) {
							NSLog(@"Successfull response!");
						} errorBlock:^(QBResponse *response) {
							NSLog(@"Response error:%@", response.error);
						}];
					} else {
						if(withQBContext){
							[QBLocation deletePlaceWithID:1230 delegate:self context:testContext];
						}else{
							[QBLocation deletePlaceWithID:1230 delegate:self];
						}
					}
				}
                    break;
            }
            
            break;
            
        default:
            break;
    }
}


// QuickBlox queries delegate
- (void)completedWithResult:(QBResult *)result{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    // success result
    if(result.success){
        
        // Create/Get/Update/Delete GeoData result
        if([result isKindOfClass:QBLGeoDataResult.class]){
            QBLGeoDataResult *res = (QBLGeoDataResult *)result;
            NSLog(@", geodataID=%lu", (unsigned long)res.geoData.ID);
       
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
- (void)completedWithResult:(QBResult *)result context:(void *)contextInfo{
    NSLog(@"completedWithResult, context=%@", contextInfo);
    
    [self completedWithResult:result];
}

@end
