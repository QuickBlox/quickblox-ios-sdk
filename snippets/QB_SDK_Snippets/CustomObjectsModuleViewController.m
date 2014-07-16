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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0){
        return 9;
    }else if(section == 1){
        return 3;
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
                    [QBCustomObjects objectWithClassName:@"SuperSample" ID:@"537a2d78535c12673d0001c5" delegate:self context:testContext];
                }else{
                    [QBCustomObjects objectWithClassName:@"SuperSample" ID:@"537a2d78535c12673d0001c5" delegate:self];
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
                NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
                    [getRequest setObject:@"0" forKey:@"using_gps"];
                    [getRequest setObject:@"1" forKey:@"sex"];
                    [getRequest setObject:@"117" forKey:@"nationality"];
                    [getRequest setObject:@"1000" forKey:@"limit"];
                    [QBCustomObjects objectsWithClassName:@"SuperSample" extendedRequest:getRequest delegate:self];


                
                
//                if(withAdditionalRequest){
//                    NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
//                    [getRequest setObject:@"10" forKey:@"limit"];
////                    [getRequest setObject:@"123123232" forKey:@"created_at[gt]"];
////                    [getRequest setObject:@"How is going on" forKey:@"text[or]"];
//                    [getRequest setObject:@"send,send2" forKey:@"user_id"];
//                        [getRequest setObject:@"send,send2" forKey:@"SenderId"];
//                    [getRequest setObject:@"vote" forKey:@"output"];
//                    
//                    if(withContext){ //SuperSample
//                        [QBCustomObjects objectsWithClassName:@"TestMessageSent" extendedRequest:getRequest delegate:self context:testContext];
//                    }else{
//                        [QBCustomObjects objectsWithClassName:@"TestMessageSent" extendedRequest:getRequest delegate:self];
//                    }
//                }else{
//                    if(withContext){
//                        [QBCustomObjects objectsWithClassName:@"TestMessageSent" delegate:self context:testContext];
//                    }else{
//                        [QBCustomObjects objectsWithClassName:@"TestMessageSent" delegate:self];
//                    }
//                }
            }
                break;
                
            // Create object
            case 3:{
                QBCOCustomObject *object = [QBCOCustomObject customObject];
                object.className = @"SuperSample";
//                [object.fields setObject:@"2049124" forKey:@"interests"];
//                [object.fields setObject:@"21312" forKey:@"test_signal"];
//                [object.fields setObject:@"NO" forKey:@"vote"];
//                [object.fields setObject:@"How is going on" forKey:@"text"];
                [object.fields setObject:@[@"a,b"] forKey:@"interests"];
                
                if(withContext){
                    [QBCustomObjects createObject:object delegate:self context:testContext];
                }else{
                    [QBCustomObjects createObject:object delegate:self];
                }
            }
                break;
                
            // Create objects
            case 4:{
                QBCOCustomObject *object1 = [QBCOCustomObject customObject];
                [object1.fields setObject:@"2049124" forKey:@"rating"];
                //
                //
                QBCOCustomObject *object2 = [QBCOCustomObject customObject];
                [object2.fields setObject:@"12" forKey:@"rating"];
                //
                if(withContext){
                    [QBCustomObjects createObjects:@[object1, object2] className:@"SuperSample" delegate:self context:testContext];
                }else{
                    [QBCustomObjects createObjects:@[object1, object2] className:@"SuperSample" delegate:self];
                }
            }
                break;
                
            // Update object
            case 5:{
                QBCOCustomObject *object = [QBCOCustomObject customObject];
                object.className = @"SuperSample";
//                [object.fields setObject:@"44" forKey:@"push[interests][]"];
                object.ID = @"53bd0980677db314cf104605";
                
                NSMutableDictionary *specialUpdateParams = [NSMutableDictionary dictionary];
                [specialUpdateParams setObject:@"44" forKey:@"push[interests][]"];
                
                if(withContext){
                    [QBCustomObjects updateObject:object specialUpdateOperators:specialUpdateParams delegate:self context:testContext];
                }else{
                    [QBCustomObjects updateObject:object specialUpdateOperators:specialUpdateParams delegate:self];
                }
            }
                break;
                
            // Update objects
            case 6:{
                QBCOCustomObject *object1 = [QBCOCustomObject customObject];
                object1.ID = @"5228ad042195be5d8d41bd99";
                [object1.fields setObject:@"101" forKey:@"rating"];
                //
                //
                QBCOCustomObject *object2 = [QBCOCustomObject customObject];
                object2.ID = @"5228ad042195be5d8d41bd9a";
                [object2.fields setObject:@"201" forKey:@"rating"];
                //
                QBCOPermissions *permissions = [QBCOPermissions permissions];
                permissions.readAccess = QBCOPermissionsAccessOpen;
                permissions.updateAccess = QBCOPermissionsAccessOpenForGroups;
                permissions.usersGroupsForUpdateAccess = [NSMutableArray arrayWithObjects:@"golf", @"women", nil];
                object2.permissions = permissions;
                //
                //
                QBCOCustomObject *object3 = [QBCOCustomObject customObject];
                object3.ID = @"5228ad042195be5d8d41bd9a33";
                [object3.fields setObject:@"201" forKey:@"rating"];
                
                if(withContext){
                    [QBCustomObjects updateObjects:@[object1, object2, object3] className:@"SuperSample" delegate:self context:testContext];
                }else{
                    [QBCustomObjects updateObjects:@[object1, object2, object3] className:@"SuperSample" delegate:self];
                }
            }
                break;
                
            // Delete object
            case 7:{
                NSString *ID = @"53bd0980677db314cf104605";
                NSString *className = @"SuperSample";
                
                if(withContext){
                    [QBCustomObjects deleteObjectWithID:ID className:className delegate:self context:testContext];
                }else{
                    [QBCustomObjects deleteObjectWithID:ID className:className delegate:self];
                }
            }
                break;
                
            // Delete objects by IDs
            case 8:{
                NSArray *IDs = @[@"51c9aafe535c127d98004a15", @"51c9ab92535c12951b0032d6", @"51c9ab92535c12951b0032da", @"51c9ab92535c12951b0032de", @"52283b38535c12fa32010efd"];
                NSString *className = @"SuperSample";
                
                if(withContext){
                    [QBCustomObjects deleteObjectsWithIDs:IDs className:className delegate:self context:testContext];
                }else{
                    [QBCustomObjects deleteObjectsWithIDs:IDs className:className delegate:self];
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
                    [QBCustomObjects permissionsForObjectWithClassName:@"SuperSample" ID:@"522894082195be5d8d41bd98" delegate:self context:testContext];
                }else{
                    [QBCustomObjects permissionsForObjectWithClassName:@"SuperSample" ID:@"522894082195be5d8d41bd98" delegate:self];
                }
            }
                break;
                
            // Update permission
            case 1:{
                QBCOCustomObject *object = [QBCOCustomObject customObject];
                object.className = @"SuperSample";
                object.ID = @"52027b23535c129fa5000eb6";
                
                QBCOPermissions *permissions = [QBCOPermissions permissions];
                permissions.readAccess = QBCOPermissionsAccessOpenForUsersIDs;
                permissions.usersIDsForReadAccess = [NSMutableArray arrayWithObjects:@22, @34, nil];
                //
                permissions.updateAccess = QBCOPermissionsAccessOpenForGroups;
                permissions.usersGroupsForUpdateAccess = [NSMutableArray arrayWithObjects:@"golf", @"women", nil];
                //
                permissions.deleteAccess = QBCOPermissionsAccessOpenForUsersIDs;
                permissions.usersIDsForDeleteAccess = [NSMutableArray arrayWithObjects:@134234, @1342334, nil];
                
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
                [object.fields setObject:@[@"a,b"] forKey:@"interests"];
                
                QBCOPermissions *permissions = [QBCOPermissions permissions];
//                permissions.readAccess = QBCOPermissionsAccessOpen;
//                //
                permissions.updateAccess = QBCOPermissionsAccessOpenForGroups;
                permissions.usersGroupsForUpdateAccess = [NSMutableArray arrayWithObjects:@"golf", @"women", nil];
                //
                permissions.deleteAccess = QBCOPermissionsAccessOpenForUsersIDs;
                permissions.usersIDsForDeleteAccess = [NSMutableArray arrayWithObjects:@3060, @63635, nil];
                
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
        
    // File
    }else if(indexPath.section == 2){
        switch (indexPath.row) {
            // Upload file
            case 0:{
                QBCOFile *file = [QBCOFile file];
                file.name = @"plus";
                file.contentType = @"image/png";
                file.data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"plus" ofType:@"png"]];
                
                if(withContext){
                    [QBCustomObjects uploadFile:file className:@"Movie" objectID:@"5256c265535c128020000182" fileFieldName:@"image" delegate:self];
                }else{
                    [QBCustomObjects uploadFile:file className:@"Movie" objectID:@"5256c265535c128020000182" fileFieldName:@"image" delegate:self context:testContext];
                }
            }
                break;
                
            // Download file
            case 1:{
                if(withContext){
                    [QBCustomObjects downloadFileFromClassName:@"Movie" objectID:@"5256c265535c128020000182" fileFieldName:@"image" delegate:self];
                }else{
                    [QBCustomObjects downloadFileFromClassName:@"Movie" objectID:@"5256c265535c128020000182" fileFieldName:@"image" delegate:self context:testContext];
                }
            }
                break;
                
            // Delete file
            case 2:{
                if(withContext){
                    [QBCustomObjects deleteFileFromClassName:@"Movie" objectID:@"5256c265535c128020000182" fileFieldName:@"image" delegate:self];
                }else{
                    [QBCustomObjects deleteFileFromClassName:@"Movie" objectID:@"5256c265535c128020000182" fileFieldName:@"image" delegate:self context:testContext];
                }
            }
                break;
                
            default:
                break;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *reuseIdentifier = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
    
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
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
                cell.textLabel.text = @"Create objects";
                break;
            case 5:
                cell.textLabel.text = @"Update object";
                break;
            case 6:
                cell.textLabel.text = @"Update objects";
                break;
            case 7:
                cell.textLabel.text = @"Delete object by ID";
                break;
            case 8:
                cell.textLabel.text = @"Delete objects by IDs";
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

    }else if(indexPath.section == 2){
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"Upload file";
                break;
            case 1:
                cell.textLabel.text = @"Download file";
                break;
            case 2:
                cell.textLabel.text = @"Delete file";
                break;
            default:
                break;
        }
    }
    
    return cell;
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
            
        // Get objects
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
