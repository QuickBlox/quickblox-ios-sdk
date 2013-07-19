//
//  CustomObjectsModuleViewController.m
//  QB_SDK_Snippets
//
//  Created by IgorKh on 8/18/12.
//  Copyright (c) 2012 Injoit. All rights reserved.
//

#import "CustomObjectsModuleViewController.h"

@interface CustomObjectsModuleViewController ()

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
    }else{
        return 3;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    // objects
    if(indexPath.section == 0){
        switch (indexPath.row) {
            // Get object with ID
            case 0:{
                if(withContext){
                    [QBCustomObjects objectWithClassName:@"SuperSample" ID:@"51c9aafe535c127d98004a13" delegate:self context:testContext];
                }else{
                    [QBCustomObjects objectWithClassName:@"SuperSample" ID:@"51c9aafe535c127d98004a13" delegate:self];
                }
            }
                break;
                
            // Get object with IDs
            case 1:{
                if(withContext){
                    [QBCustomObjects objectsWithClassName:@"SuperSample" IDs:@[@"51c9aafe535c127d98004a13",@"51c9aafe535c127d98004a14", @"51c9aafe535c127d98004a16"] delegate:self context:testContext];
                }else{
                    [QBCustomObjects objectsWithClassName:@"SuperSample" IDs:@[@"51c9aafe535c127d98004a13",@"51c9aafe535c127d98004a14", @"51c9aafe535c127d98004a16"] delegate:self];
                }
            }
                break;
                
            // Get objects
            case 2:{
                if(withAdditionalRequest){
                    NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
//                   [getRequest setObject:@"10" forKey:@"rating[gt]"];
                    [getRequest setObject:@"10" forKey:@"limit"];
                    
                    if(withContext){ //SuperSample
                        [QBCustomObjects objectsWithClassName:@"SuperSample" extendedRequest:getRequest delegate:self context:testContext];
                    }else{
                        [QBCustomObjects objectsWithClassName:@"SuperSample" extendedRequest:getRequest delegate:self];
                    }
                }else{
                    if(withContext){
                        [QBCustomObjects objectsWithClassName:@"SuperSample" delegate:self context:testContext];
                    }else{
                        [QBCustomObjects objectsWithClassName:@"SuperSample" delegate:self];
                    }
                }
            }
                break;
                
            // Create object
            case 3:{
                QBCOCustomObject *object = [QBCOCustomObject customObject];
                object.className = @"SuperSample";
                [object.fields setObject:@"2049124" forKey:@"rating"];
                [object.fields setObject:@"21312" forKey:@"test_signal"];
                [object.fields setObject:@"NO" forKey:@"vote"];
                [object.fields setObject:@"Hello world!" forKey:@"text"];
                [object.fields setObject:@[@"car", @"man", @"golf"] forKey:@"interests"];
                [object.fields setObject:@"1231223124124124" forKey:@"_parent_id"];
                
                if(withContext){
                    [QBCustomObjects createObject:object delegate:self context:testContext];
                }else{
                    [QBCustomObjects createObject:object delegate:self];
                }
            }
                break;
                
            // Update object
            case 4:{
                QBCOCustomObject *object = [QBCOCustomObject customObject];
                object.className = @"SuperSample";
                [object.fields setObject:@"21312" forKey:@"test_signal"];
                [object.fields setObject:@"NO" forKey:@"vote"];
                [object.fields setObject:@[@"football", @"golf", @"car", @"tag"] forKey:@"interests"];
                object.ID = @"51e69e1e535c127ef000141c";
                
                NSMutableDictionary *specialUpdateParams = [NSMutableDictionary dictionary];
                [specialUpdateParams setObject:@"phone" forKey:@"push[interests]"];
                
                if(withContext){
                    [QBCustomObjects updateObject:object specialUpdateOperators:specialUpdateParams delegate:self context:testContext];
                }else{
                    [QBCustomObjects updateObject:object specialUpdateOperators:specialUpdateParams delegate:self];
                }
            }
                break;
                
            // Delete object
            case 5:{
                NSString *ID = @"51c9aafe535c127d98004a15";
                NSString *className = @"SuperSample";
                
                if(withContext){
                    [QBCustomObjects deleteObjectWithID:ID className:className delegate:self context:testContext];
                }else{
                    [QBCustomObjects deleteObjectWithID:ID className:className delegate:self];
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
                if(withContext){
                    [QBCustomObjects permissionsForObjectWithClassName:@"SuperSample" ID:@"51c9aafe535c127d98004a13" delegate:self context:testContext];
                }else{
                    [QBCustomObjects permissionsForObjectWithClassName:@"SuperSample" ID:@"51c9aafe535c127d98004a13" delegate:self];
                }
            }
                break;
                
            // Update permission
            case 1:{
                QBCOCustomObject *object = [QBCOCustomObject customObject];
                object.className = @"SuperSample";
                object.ID = @"51c9aafe535c127d98004a13";
                
                QBCOPermissions *permissions = [QBCOPermissions permissions];
                permissions.readAccess = QBCOPermissionsAccessOpenForUsersIDs;
                permissions.usersIDsForReadAccess = @[@22, @34];
                //
                permissions.updateAccess = QBCOPermissionsAccessOpenForGroups;
                permissions.usersGroupsForUpdateAccess = @[@"golf", @"women"];
                //
                permissions.deleteAccess = QBCOPermissionsAccessOpenForUsersIDs;
                permissions.usersIDsForDeleteAccess = @[@134234, @14123123, @1212124];
                
                object.permissions = permissions;
                
                if(withContext){
                    [QBCustomObjects updateObject:object specialUpdateOperators:nil delegate:self context:testContext];
                }else{
                    [QBCustomObjects updateObject:object specialUpdateOperators:nil delegate:self];
                }
            }
                break;
                
            // Create object with custom permissions
            case 2:{
                QBCOCustomObject *object = [QBCOCustomObject customObject];
                object.className = @"SuperSample";
                [object.fields setObject:@"345" forKey:@"rating"];
                
                QBCOPermissions *permissions = [QBCOPermissions permissions];
//                permissions.readAccess = QBCOPermissionsAccessOpen;
//                //
                permissions.updateAccess = QBCOPermissionsAccessOpenForGroups;
                permissions.usersGroupsForUpdateAccess = @[@"go,lf", @"women"];
                //
                permissions.deleteAccess = QBCOPermissionsAccessOpenForUsersIDs;
                permissions.usersIDsForDeleteAccess = @[@3060, @63635];
                
                object.permissions = permissions;
                
                if(withContext){
                    [QBCustomObjects createObject:object delegate:self context:testContext];
                }else{
                    [QBCustomObjects createObject:object delegate:self];
                }
            }
                break;
                
            default:
                break;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *reuseIdentifier = [NSString stringWithFormat:@"%d", indexPath.row];
    
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if(cell == nil){
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if(indexPath.section == 0){
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"Get object by ID";
                break;
            case 1:
                cell.textLabel.text = @"Get object by IDs";
                break;
            case 2:
                cell.textLabel.text = @"Get objects";
                break;
            case 3:
                cell.textLabel.text = @"Create object";
                break;
            case 4:
                cell.textLabel.text = @"Update object";
                break;
            case 5:
                cell.textLabel.text = @"Delete object";
                break;
            default:
                break;
        }
        
    }else if(indexPath.section == 1){
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"Get permissions for object by ID";
                break;
            case 1:
                cell.textLabel.text = @"Update permissions";
                break;
            case 2:
                cell.textLabel.text = @"Create object with permissions";
                break;
            default:
                break;
        }

    }
    
    return cell;
}


// QuickBlox queries delegate
- (void)completedWithResult:(Result *)result{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    // success result
    if(result.success){
        
        // Create/Update/Delete object
        if([result isKindOfClass:QBCOCustomObjectResult.class]){
            QBCOCustomObjectResult *res = (QBCOCustomObjectResult *)result;
            NSLog(@"QBCOCustomObjectResult, object=%@", res.object);
            
        // Get objects
        }else if([result isKindOfClass:QBCOCustomObjectPagedResult.class]){
            QBCOCustomObjectPagedResult *res = (QBCOCustomObjectPagedResult *)result;
            NSLog(@"QBCOCustomObjectPagedResult, objects=%@, count=%d, skip=%d, limit=%d", res.objects, res.count, res.skip, res.limit);
            
        // get permissions
        }else if([result isKindOfClass:QBCOPermissionsResult.class]){
            QBCOPermissionsResult *res = (QBCOPermissionsResult *)result;
            NSLog(@"QBCOPermissionsResult, permissions=%@", res.permissions);
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
