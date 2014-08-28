//
//  CustomObjectsModuleViewController.m
//  QB_SDK_Snippets
//
//  Created by IgorKh on 8/18/12.
//  Copyright (c) 2012 Injoit. All rights reserved.
//

#import "CustomObjectsModuleViewController.h"
#import "CustomObjectsDataSource.h"

#define MovieClass @"Movie"

@interface CustomObjectsModuleViewController ()
@property (nonatomic) CustomObjectsDataSource *dataSource;
@end

@implementation CustomObjectsModuleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Custom Objects", @"Custom Objects");
        self.tabBarItem.image = [UIImage imageNamed:@"circle"];
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.dataSource = [[CustomObjectsDataSource alloc] init];
    tableView.dataSource = self.dataSource;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    // objects
    if(indexPath.section == 0){
        switch (indexPath.row) {
            // Get object with ID
            case 0:{
				if (useNewAPI) {
					[QBRequest objectWithClassName:MovieClass ID:@"53f0ae93535c129aa10270b7" successBlock:^(QBResponse *response, QBCOCustomObject *object) {
						NSLog(@"Successfull response!");
					} errorBlock:^(QBResponse *response) {
						NSLog(@"Response error:%@", response.error);
					}];
				} else {
					if(withQBContext){
						[QBCustomObjects objectWithClassName:MovieClass ID:@"53f0ae93535c129aa10270b7" delegate:self context:testContext];
					}else{
						[QBCustomObjects objectWithClassName:MovieClass ID:@"53f0ae93535c129aa10270b7" delegate:self];
					}
				}
            }
                break;
                
            // Get objects with IDs
            case 1:{
				if (useNewAPI) {
					[QBRequest objectsWithClassName:MovieClass IDs:@[@"53f0ae93535c129aa10270b7", @"53f0aeaf535c129aa10270c4"]
									   successBlock:^(QBResponse *response, NSArray *objects) {
										   NSLog(@"Successfull response!");
									   } errorBlock:^(QBResponse *response) {
										   NSLog(@"Response error:%@", response.error);
									   }];
				} else {
					if(withQBContext){
						[QBCustomObjects objectsWithClassName:MovieClass IDs:@[@"53f0ae93535c129aa10270b7",@"53f0aeaf535c129aa10270c4"] delegate:self context:testContext];
					}else{
						[QBCustomObjects objectsWithClassName:MovieClass IDs:@[@"53f0ae93535c129aa10270b7",@"53f0aeaf535c129aa10270c4"] delegate:self];
					}
				}
				
            }
                break;
                
            // Get objects
            case 2:{
                NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
                [getRequest setObject:@"1" forKey:@"rating[gt]"];
                [getRequest setObject:@"10" forKey:@"limit"];

				if (useNewAPI) {
					[QBRequest objectsWithClassName:MovieClass extendedRequest:getRequest
									   successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
										   NSLog(@"Successfull response!");
									   } errorBlock:^(QBResponse *response) {
										   NSLog(@"Response error:%@", response.error);
									   }];
				} else {
					[QBCustomObjects objectsWithClassName:MovieClass extendedRequest:getRequest delegate:self];
				}
            }
                break;
                
            // Count of objects
            case 3:{
                NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
                [getRequest setObject:@(1) forKey:@"rating[gt]"];
                
                if (useNewAPI) {
                    [QBRequest countObjectsWithClassName:MovieClass extendedRequest:getRequest successBlock:^(QBResponse *response, NSUInteger count) {
                        NSLog(@"Successfull response! Count: %d", count);
                    } errorBlock:^(QBResponse *response) {
                        NSLog(@"Response error:%@", response.error);
                    }];
                } else {
                    getRequest[@"count"] = @1;
                    [QBCustomObjects objectsWithClassName:MovieClass extendedRequest:getRequest delegate:self];
                }

            }
                break;
                
            // Create object
            case 4:{
                QBCOCustomObject *object = [QBCOCustomObject customObject];
                object.className = MovieClass;
                [object.fields setObject:@"Terminator4" forKey:@"name"];
                [object.fields setObject:@"best movie ever!" forKey:@"description"];
                [object.fields setObject:@(5) forKey:@"rating"];
                
				if (useNewAPI) {
					[QBRequest createObject:object successBlock:^(QBResponse *response, QBCOCustomObject *object) {
						NSLog(@"Successfull response!");
					} errorBlock:^(QBResponse *response) {
						NSLog(@"Response error:%@", response.error);
					}];
				} else {
					if(withQBContext){
						[QBCustomObjects createObject:object delegate:self context:testContext];
					}else{
						[QBCustomObjects createObject:object delegate:self];
					}
				}

            }
                break;
                
            // Create objects
            case 5:{
                QBCOCustomObject *object1 = [QBCOCustomObject customObject];
                [object1.fields setObject:@"The Dark Knight" forKey:@"name"];
                [object1.fields setObject:@"About Batman" forKey:@"description"];
                [object1.fields setObject:@(9) forKey:@"rating"];
                //
                //
                QBCOCustomObject *object2 = [QBCOCustomObject customObject];
                [object2.fields setObject:@"The Godfather" forKey:@"name"];
                [object2.fields setObject:@"The aging patriarch of an organized crime dynasty transfers control of his clandestine empire to his reluctant son." forKey:@"description"];
                [object2.fields setObject:@(12) forKey:@"rating"];
                
				if (useNewAPI) {
					[QBRequest createObjects:@[object1, object2] className:MovieClass
								successBlock:^(QBResponse *response, NSArray *objects) {
									NSLog(@"Successfull response!");
								} errorBlock:^(QBResponse *response) {
									NSLog(@"Response error:%@", response.error);
								}];
				} else {
					if(withQBContext){
						[QBCustomObjects createObjects:@[object1, object2] className:MovieClass delegate:self context:testContext];
					}else{
						[QBCustomObjects createObjects:@[object1, object2] className:MovieClass delegate:self];
					}
				}
            }
                break;
                
            // Update object
            case 6:{
                QBCOCustomObject *object = [QBCOCustomObject customObject];
                object.className = MovieClass;
                [object.fields setObject:@"6" forKey:@"rating"];
                object.ID = @"53f0c7b2535c126482029666";
                
				if (useNewAPI) {
					[QBRequest updateObject:object specialUpdateOperators:nil
							   successBlock:^(QBResponse *response, QBCOCustomObject *object) {
								   NSLog(@"Successfull response!");
							   } errorBlock:^(QBResponse *response) {
								   NSLog(@"Response error:%@", response.error);
							   }];
				} else {
					if(withQBContext){
						[QBCustomObjects updateObject:object specialUpdateOperators:nil delegate:self context:testContext];
					}else{
						[QBCustomObjects updateObject:object specialUpdateOperators:nil delegate:self];
					}
				}
				
            }
                break;
                
            // Update objects
            case 7:{
                QBCOCustomObject *object1 = [QBCOCustomObject customObject];
                object1.ID = @"53f0c0dc6fd1dfa9c43c8af5";
                [object1.fields setObject:@"5" forKey:@"rating"];
                //
                //
                QBCOCustomObject *object2 = [QBCOCustomObject customObject];
                object2.ID = @"53f0c0dc6fd1dfa9c43c8af6";
                [object2.fields setObject:@"5" forKey:@"rating"];
                
				if (useNewAPI) {
					[QBRequest updateObjects:@[object1, object2] className:MovieClass
								successBlock:^(QBResponse *response, NSArray *objects, NSArray *notFoundObjectsIds) {
									NSLog(@"Successfull response!");
								} errorBlock:^(QBResponse *response) {
									NSLog(@"Response error:%@", response.error);
								}];
				} else {
					if(withQBContext){
						[QBCustomObjects updateObjects:@[object1, object2] className:MovieClass delegate:self context:testContext];
					}else{
						[QBCustomObjects updateObjects:@[object1, object2] className:MovieClass delegate:self];
					}
				}
				
            }
                break;
                
            // Delete object
            case 8:{
                NSString *ID = @"53f0c1016fd1dfa9c43c8af8";
                NSString *className = MovieClass;
                
				if (useNewAPI) {
					[QBRequest deleteObjectWithID:ID className:className
									 successBlock:^(QBResponse *response) {
										 NSLog(@"Successfull response!");
									 } errorBlock:^(QBResponse *response) {
										 NSLog(@"Response error:%@", response.error);
									 }];
				} else {
					if(withQBContext){
						[QBCustomObjects deleteObjectWithID:ID className:className delegate:self context:testContext];
					}else{
						[QBCustomObjects deleteObjectWithID:ID className:className delegate:self];
					}
				}

            }
                break;
                
            // Delete objects by IDs
            case 9:{
                NSArray *IDs = @[@"53f0c1016fd1dfa9c43c8af7", @"53f0c0dc6fd1dfa9c43c8af6", @"2"];
                NSString *className = MovieClass;
                
				if (useNewAPI) {
					[QBRequest deleteObjectWithID:[IDs componentsJoinedByString:@","] className:className
									 successBlock:^(QBResponse *response) {
										 NSLog(@"Successfull response!");
									 } errorBlock:^(QBResponse *response) {
										 NSLog(@"Response error:%@", response.error);
									 }];
				} else {
					if(withQBContext){
						[QBCustomObjects deleteObjectsWithIDs:IDs className:className delegate:self context:testContext];
					}else{
						[QBCustomObjects deleteObjectsWithIDs:IDs className:className delegate:self];
					}
				}
            }
                break;
            default:
                break;
        }
    
    // permissions
    }else if(indexPath.section == 1){
        switch (indexPath.row) {
            // Get permission
            case 0:{
				if (useNewAPI) {
					[QBRequest permissionsForObjectWithClassName:MovieClass ID:@"53f0c0dc6fd1dfa9c43c8af5"
													successBlock:^(QBResponse *response, QBCOPermissions *permissions) {
														NSLog(@"Successfull response!");
													} errorBlock:^(QBResponse *response) {
														NSLog(@"Response error:%@", response.error);
													}];
				} else {
					if(withQBContext){
						[QBCustomObjects permissionsForObjectWithClassName:MovieClass ID:@"53f0c0dc6fd1dfa9c43c8af5" delegate:self context:testContext];
					}else{
						[QBCustomObjects permissionsForObjectWithClassName:MovieClass ID:@"53f0c0dc6fd1dfa9c43c8af5" delegate:self];
					}
				}

            }
                break;
                
            // Update permission
            case 1:{
                QBCOCustomObject *object = [QBCOCustomObject customObject];
                object.className = MovieClass;
                object.ID = @"53f2217d535c1227d9037a9b";
                
                QBCOPermissions *permissions = [QBCOPermissions permissions];
                permissions.readAccess = QBCOPermissionsAccessOpenForUsersIDs;
                permissions.usersIDsForReadAccess = [@[@22, @34] mutableCopy];
                //
                permissions.updateAccess = QBCOPermissionsAccessOpenForGroups;
                permissions.usersGroupsForUpdateAccess = [@[@"golf", @"women", @"men"] mutableCopy];
                //
                permissions.deleteAccess = QBCOPermissionsAccessOpenForUsersIDs;
                permissions.usersIDsForDeleteAccess = [@[@134234, @14123123, @1212124] mutableCopy];
                
                object.permissions = permissions;
				
                if (useNewAPI) {
					[QBRequest updateObject:object specialUpdateOperators:nil
							   successBlock:^(QBResponse *response, QBCOCustomObject *object) {
								   NSLog(@"Successfull response!");
							   } errorBlock:^(QBResponse *response) {
								   NSLog(@"Response error:%@", response.error);
							   }];
				} else {
					if(withQBContext){
						[QBCustomObjects updateObject:object specialUpdateOperators:nil delegate:self context:testContext];
					}else{
						[QBCustomObjects updateObject:object specialUpdateOperators:nil delegate:self];
					}
				}
            }
                break;
                
            // Create object with custom permissions
            case 2:{
                QBCOCustomObject *object = [QBCOCustomObject customObject];
                object.className = MovieClass;
                [object.fields setObject:@"Terminator7" forKey:@"name"];
                [object.fields setObject:@"best movie ever!" forKey:@"description"];
                [object.fields setObject:@(5) forKey:@"rating"];
                
                QBCOPermissions *permissions = [QBCOPermissions permissions];
                permissions.readAccess = QBCOPermissionsAccessOpen;
                //
                permissions.updateAccess = QBCOPermissionsAccessOpenForGroups;
                permissions.usersGroupsForUpdateAccess = [@[@"golf", @"women"] mutableCopy];
                //
                permissions.deleteAccess = QBCOPermissionsAccessOpenForUsersIDs;
                permissions.usersIDsForDeleteAccess = [@[@3060, @63635] mutableCopy];
                
                object.permissions = permissions;
                
				if (useNewAPI) {
					[QBRequest createObject:object successBlock:^(QBResponse *response, QBCOCustomObject *object) {
						NSLog(@"Successfull response!");
					} errorBlock:^(QBResponse *response) {
						NSLog(@"Response error:%@", response.error);
					}];
				} else {
					if(withQBContext){
						[QBCustomObjects createObject:object delegate:self context:testContext];
					}else{
						[QBCustomObjects createObject:object delegate:self];
					}
				}
            }
                break;
                
            default:
                break;
        }
        
    // File
    }else if(indexPath.section == 2){
        switch (indexPath.row) {
            // Upload file
            case 0:{
                QBCOFile *file = [QBCOFile file];
                file.name = @"London";
                file.contentType = @"image/jpg";
                file.data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"London" ofType:@"jpg"]];
                
                if (useNewAPI) {
                    [QBRequest uploadFile:file
                                className:MovieClass
                                 objectID:@"53f0c0dc6fd1dfa9c43c8af5"
                            fileFieldName:@"image"
                             successBlock:^(QBResponse *response, QBCOFileUploadInfo* info) {
                                NSLog(@"Response succeded");
                            } statusBlock:^(QBRequest *request, QBRequestStatus *status) {
                                NSLog(@"upload progress: %f", status.percentOfCompletion);
                            } errorBlock:^(QBResponse *response) {
                                NSLog(@"Error: %@", response.error);
                            }];
                } else {
                    if(withQBContext){
                        [QBCustomObjects uploadFile:file className:MovieClass objectID:@"5256c265535c128020000182" fileFieldName:@"image" delegate:self];
                    }else{
                        [QBCustomObjects uploadFile:file className:MovieClass objectID:@"5256c265535c128020000182" fileFieldName:@"image" delegate:self context:testContext];
                    }
                }

            }
                break;
                
            // Download file
            case 1:{
                if (useNewAPI) {
                    [QBRequest downloadFileFromClassName:MovieClass objectID:@"53f0c0dc6fd1dfa9c43c8af5" fileFieldName:@"image" successBlock:^(QBResponse *response, NSData *loadedData) {
                        NSLog(@"Response succeded");
                    } statusBlock:^(QBRequest *request, QBRequestStatus *status) {
                        NSLog(@"download progress: %f", status.percentOfCompletion);
                    } errorBlock:^(QBResponse *response) {
                        NSLog(@"Error: %@", response.error);
                    }];
                } else {
                    if(withQBContext){
                        [QBCustomObjects downloadFileFromClassName:MovieClass objectID:@"5256c265535c128020000182" fileFieldName:@"image" delegate:self];
                    }else{
                        [QBCustomObjects downloadFileFromClassName:MovieClass objectID:@"5256c265535c128020000182" fileFieldName:@"image" delegate:self context:testContext];
                    }
                }
            }
                break;
                
            // Delete file
            case 2:{
                if (useNewAPI) {
                    [QBRequest deleteFileFromClassName:MovieClass objectID:@"53f0c0dc6fd1dfa9c43c8af5" fileFieldName:@"image" successBlock:^(QBResponse *response) {
                        NSLog(@"Response succeded");
                    } errorBlock:^(QBResponse *response) {
                        NSLog(@"Error: %@", response.error);
                    }];
                } else {
                    if(withQBContext){
                        [QBCustomObjects deleteFileFromClassName:MovieClass objectID:@"5256c265535c128020000182" fileFieldName:@"image" delegate:self];
                    }else{
                        [QBCustomObjects deleteFileFromClassName:MovieClass objectID:@"5256c265535c128020000182" fileFieldName:@"image" delegate:self context:testContext];
                    }
                }
            }
                break;
                
            default:
                break;
        }
    }
}


//// QuickBlox queries delegate
- (void)completedWithResult:(Result *)result{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    // success result
    if(result.success){
        
        // Create/Update/Delete object
        if([result isKindOfClass:QBCOCustomObjectResult.class]){
            QBCOCustomObjectResult *res = (QBCOCustomObjectResult *)result;
            NSLog(@"QBCOCustomObjectResult, object=%@", res.object);
            
        // Get/Update objects
        }else if([result isKindOfClass:QBCOCustomObjectPagedResult.class]){
            QBCOCustomObjectPagedResult *res = (QBCOCustomObjectPagedResult *)result;
            NSLog(@"QBCOCustomObjectPagedResult, objects=%@, count=%lu, skip=%lu, limit=%lu, notFoundObjectsIDs=%@", res.objects, (unsigned long)res.count, (unsigned long)res.skip, (unsigned long)res.limit, res.notFoundObjectsIDs);

        // get permissions
        }else if([result isKindOfClass:QBCOPermissionsResult.class]){
            QBCOPermissionsResult *res = (QBCOPermissionsResult *)result;
            NSLog(@"QBCOPermissionsResult, permissions=%@", res.permissions);
            
        // multi Delete objects
        }else if([result isKindOfClass:QBCOMultiDeleteResult.class]){
            QBCOMultiDeleteResult *res = (QBCOMultiDeleteResult *)result;
            NSLog(@"QBCOMultiDeleteResult, deletedObjectsIDs: %@, notFoundObjectsIDs: %@, wrongPermissionsObjectsIDs: %@",
                  res.deletedObjectsIDs, res.notFoundObjectsIDs, res.wrongPermissionsObjectsIDs);
        
        // Download file result
        }else if([result isKindOfClass:QBCOFileResult.class]){
            QBCOFileResult *res = (QBCOFileResult *)result;
            NSLog(@"QBCOFileResult, file=%@", res.data);
        
        }else{
             NSLog(@"Result");
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
