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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    switch (indexPath.row) {
        // Get object with ID
        case 0:{
            if(withContext){
                [QBCustomObjects objectWithClassName:@"SuperSample" ID:@"503a3fbc36c9ae8e6a00239c--" delegate:self context:testContext];
            }else{
                [QBCustomObjects objectWithClassName:@"SuperSample" ID:@"503a3fbc36c9ae8e6a00239c--" delegate:self];
            }
        }
            break;
            
        // Get objects
        case 1:{
            if(withAdditionalRequest){
                NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
//                [getRequest setObject:@"100" forKey:@"rating[gt]"];
//                [getRequest setObject:@"291" forKey:@"user_id"];
                [getRequest setObject:@"1000" forKey:@"limit"];
//                [getRequest setObject:@"2" forKey:@"skip"];
                
                if(withContext){
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
        case 2:{
            QBCOCustomObject *object = [QBCOCustomObject customObject];
            object.className = @"SuperSample";
            [object.fields setObject:@"345" forKey:@"rating"];
            [object.fields setObject:@"YES" forKey:@"vote"];
            [object.fields setObject:@"2012-11-02 11:26:16 +0200" forKey:@"text"];
            [object.fields setObject:@[@"car", @"man"] forKey:@"interests"];
            [object.fields setObject:@"12312" forKey:@"_parent_id"];
            
            if(withContext){
                [QBCustomObjects createObject:object delegate:self context:testContext];
            }else{
                [QBCustomObjects createObject:object delegate:self];
            }
        }
            break;
            
        // Update object
        case 3:{
            QBCOCustomObject *object = [QBCOCustomObject customObject];
            object.className = @"SuperSample";
            object.parentID = @"ee333";
            [object.fields setObject:@"YES" forKey:@"vote"];
            [object.fields setObject:@[@"football", @"golf"] forKey:@"interests"];
            object.ID = @"50c35cd8535c12df6b077a51";
            
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
        case 4:{
            NSString *ID = @"502f83ed36c9aefa62000002";
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
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *reuseIdentifier = [NSString stringWithFormat:@"%d", indexPath.row];
    
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if(cell == nil){
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"Get object by ID";
            break;
        case 1:
            cell.textLabel.text = @"Get objects";
            break;
        case 2:
            cell.textLabel.text = @"Create object";
            break;
        case 3:
            cell.textLabel.text = @"Update object";
            break;
        case 4:
            cell.textLabel.text = @"Delete object";
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
        
        // Create/Update/Delete object
        if([result isKindOfClass:QBCOCustomObjectResult.class]){
            QBCOCustomObjectResult *res = (QBCOCustomObjectResult *)result;
            NSLog(@"QBCOCustomObjectResult, object=%@", res.object);
            
        // Get objects
        }else if([result isKindOfClass:QBCOCustomObjectPagedResult.class]){
            QBCOCustomObjectPagedResult *res = (QBCOCustomObjectPagedResult *)result;
            NSLog(@"QBCOCustomObjectPagedResult, objects=%@, count=%d", res.objects, res.count);
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
