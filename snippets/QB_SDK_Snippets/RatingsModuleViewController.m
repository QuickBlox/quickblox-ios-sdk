//
//  RatingsModuleViewController.m
//  QB_SDK_Samples
//
//  Created by Igor Khomenko on 6/7/12.
//  Copyright (c) 2012 Injoit. All rights reserved.
//

#import "RatingsModuleViewController.h"

@interface RatingsModuleViewController ()

@end

@implementation RatingsModuleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Ratings", @"Ratings");
        self.tabBarItem.image = [UIImage imageNamed:@"circle"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        // Game Mode
        case 0:
            return 5;
            break;
            
        // Score
        case 1:
            return 6;
            break;
            
        // Average
        case 2:
            return 2;
            break;
            
        // Game Mode Parameter Value
        case 3:
            return 3;
            break;
            
        default:
            break;
    }
    
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return @"Game Mode";
        case 1:
            return @"Score";
        case 2:
            return @"Average";
        case 3:
            return @"Game Mode Parameter Value";
            
        default:
            break;
    }
    
    return @"";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    switch (indexPath.section) {
        // Game Mode
        case 0:
            switch (indexPath.row) {
                // Create game mode
                case 0:{
                    if(withContext){
                        [QBRatings createGameModeWithTitle:@"Car3D Game" delegate:self context:testContext];
                    }else{
                        [QBRatings createGameModeWithTitle:@"Car3D Game" delegate:self];
                    }
                }
                    break;
                    
                // Get Game Mode with ID
                case 1:
                    if(withContext){
                        [QBRatings gameModeWithID:113 delegate:self context:testContext];
                    }else{
                        [QBRatings gameModeWithID:113 delegate:self];
                    }

                    break;
                    
                // Get Game Modes
                case 2:
                    if(withContext){
                        [QBRatings gameModesWithDelegate:self context:testContext];
                    }else{
                        [QBRatings gameModesWithDelegate:self];
                    }
                    break;
                    
                // Update Game Modes
                case 3:{
                    
                    QBRGameMode *gameMode = [QBRGameMode gameMode];
                    gameMode.ID = 113;
                    gameMode.title = @"Mozart game";
                    
                    if(withContext){
                        [QBRatings updateGameMode:gameMode delegate:self context:testContext];
                    }else{
                        [QBRatings updateGameMode:gameMode delegate:self];
                    }
                }
                    break;
                    
                // Delete game mode
                case 4:{
                    if(withContext){
                        [QBRatings deleteGameModeWithID:113 delegate:self context:testContext];
                    }else{
                        [QBRatings deleteGameModeWithID:113 delegate:self];
                    }
                }
                    break;
            }
            break;
            
        // Score
        case 1:
            switch (indexPath.row) {
                // Create score
                case 0:{
                    QBRScore *score = [QBRScore score];
                    score.gameModeID = 115;
                    score.value = 100;
                    if(withContext){
                        [QBRatings createScore:score delegate:self context:testContext];
                    }else{
                        [QBRatings createScore:score delegate:self];
                    }
                }
                    break;
                    
                // Get Score with ID
                case 1:
                    if(withContext){
                        [QBRatings scoreWithID:862 delegate:self context:testContext];
                    }else{
                        [QBRatings scoreWithID:862 delegate:self];
                    }
                    
                    break;
                    
                // Update Score
                case 2:{
                    QBRScore *score = [QBRScore score];
                    score.ID = 862;
                    score.value = 200;
                    if(withContext){
                        [QBRatings updateScore:score delegate:self context:testContext];
                    }else{
                        [QBRatings updateScore:score delegate:self];
                    }
                }
                    break;
                    
                // Delete score with ID
                case 3:{
                    if(withContext){
                        [QBRatings deleteScoreWithID:862 delegate:self context:testContext];
                    }else{
                        [QBRatings deleteScoreWithID:862 delegate:self];
                    }
                }
                    break;
                    
                // Get top N scores
                case 4:{
                    if(withAdditionalRequest){
                        QBRScoreGetRequest *getRequest = [[QBRScoreGetRequest alloc] init];
                        getRequest.sortAsc = 1;
                        getRequest.sortBy = ScoreSortByKindValue;
                        
                        if(withContext){
                            [QBRatings topNScores:3 gameModeID:114 extendedRequest:getRequest delegate:self context:testContext];
                        }else{
                            [QBRatings topNScores:3 gameModeID:114 extendedRequest:getRequest delegate:self];
                        } 
                        
                        [getRequest release];
                    }else{
                        if(withContext){
                            [QBRatings topNScores:3 gameModeID:114 delegate:self context:testContext];
                        }else{
                            [QBRatings topNScores:3 gameModeID:114 delegate:self];
                        } 
                    }
                }
                    break;
                    
                // Get scores with user ID
                case 5:{
                    if(withAdditionalRequest){
                        QBRScoreGetRequest *getRequest = [[QBRScoreGetRequest alloc] init];
                        getRequest.sortAsc = 1;
                        getRequest.sortBy = ScoreSortByKindValue;
                        
                        if(withContext){
                            [QBRatings scoresWithUserID:14605 extendedRequest:getRequest delegate:self context:testContext];
                        }else{
                            [QBRatings scoresWithUserID:14605 extendedRequest:getRequest delegate:self];
                        } 
                        
                        [getRequest release];
                    }else{
                        if(withContext){
                            [QBRatings scoresWithUserID:14605 delegate:self context:testContext];
                        }else{
                            [QBRatings scoresWithUserID:14605 delegate:self];
                        } 
                    }
                }
                    break;
            }
            break;

        // Average
        case 2:
            switch (indexPath.row) {
                // Get average with game mode ID
                case 0:{
                    if(withContext){
                        [QBRatings averageWithGameModeID:114 delegate:self context:testContext];
                    }else{
                        [QBRatings averageWithGameModeID:114  delegate:self];
                    }
                }
                    break;
                    
                // Get averages for application
                case 1:
                    if(withContext){
                        [QBRatings averagesForApplicationWithDelegate:self context:testContext];
                    }else{
                        [QBRatings averagesForApplicationWithDelegate:self];
                    }
                    
                    break;
                    
            }
            break;
            
        // Game mode parameter value
        case 3:
            switch (indexPath.row) {
                // Create Game mode parameter value
                case 0:{
                    QBRGameModeParameterValue *gameModeParameterValue = [QBRGameModeParameterValue gameModeParameterValue];
                    gameModeParameterValue.value = @"1234";
                    gameModeParameterValue.gameModeParameterID = 112;
                    gameModeParameterValue.scoreID = 863;
                    if(withContext){
                        [QBRatings createGameModeParameterValue:gameModeParameterValue delegate:self context:testContext];
                    }else{
                        [QBRatings createGameModeParameterValue:gameModeParameterValue  delegate:self];
                    }
                }
                    break;
                    
                // Update Game mode parameter value
                case 1:{
                    QBRGameModeParameterValue *gameModeParameterValue = [QBRGameModeParameterValue gameModeParameterValue];
                    gameModeParameterValue.value = @"234";
                    gameModeParameterValue.ID = 384;
                    gameModeParameterValue.scoreID = 863;
                    if(withContext){
                        [QBRatings updateGameModeParameterValue:gameModeParameterValue delegate:self context:testContext];
                    }else{
                        [QBRatings updateGameModeParameterValue:gameModeParameterValue delegate:self];
                    }
                }
                    
                    break;
                    
                // Get Game mode parameter value with ID
                case 2:
                    if(withContext){
                        [QBRatings gameModeParameterValueWithID:384 delegate:self context:testContext];
                    }else{
                        [QBRatings gameModeParameterValueWithID:384 delegate:self];
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
        // Game Mode
        case 0:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"Create game mode";
                    break;
                case 1:
                    cell.textLabel.text = @"Get game mode with ID";
                    break;
                case 2:
                    cell.textLabel.text = @"Get game modes";
                    break;
                case 3:
                    cell.textLabel.text = @"Update game mode";
                    break;
                case 4:
                    cell.textLabel.text = @"Delete game mode with ID";
                    break;
            }
            break;
            
        // Score
        case 1:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"Create score";
                    break;
                case 1:
                    cell.textLabel.text = @"Get score with ID";
                    break;
                case 2:
                    cell.textLabel.text = @"Update score";
                    break;
                case 3:
                    cell.textLabel.text = @"Delete score with ID";
                    break;
                case 4:
                    cell.textLabel.text = @"Get top N scores";
                    break;
                case 5:
                    cell.textLabel.text = @"Get scores with user ID";
                    break;
            }
            break;
            
        // Average
        case 2:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"Get average with game mode ID";
                    break;
                case 1:
                    cell.textLabel.text = @"Get averages for application";
                    break;
            }
            break;
            
        // Game mode parameter value
        case 3:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"Create game mode parameter value";
                    break;
                case 1:
                    cell.textLabel.text = @"Update game mode parameter value";
                    break;
                case 2:
                    cell.textLabel.text = @"Get game mode parameter value with ID";
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
        
        // Create/Get/Update/Delete gamemode
        if([result isKindOfClass:QBRGameModeResult.class]){
            QBRGameModeResult *res = (QBRGameModeResult *)result;
            NSLog(@"QBRGameModeResult, gamemode=%@", res.gameMode);
            
        // Get game modes
        }else if([result isKindOfClass:QBRGameModePagedResult.class]){
            QBRGameModePagedResult *res = (QBRGameModePagedResult *)result;
            NSLog(@"QBRGameModePagedResult, game modes=%@", res.gameModes);
        
            
            
            
        // Create/Get/Update/Delete score
        }else if([result isKindOfClass:QBRScoreResult.class]){
            QBRScoreResult *res = (QBRScoreResult *)result;
            NSLog(@"QBRScoreResult, score=%@", res.score);
        
        // Get scores
        }else if([result isKindOfClass:QBRScorePagedResult.class]){
            QBRScorePagedResult *res = (QBRScorePagedResult *)result;
            NSLog(@"QBRScorePagedResult, scores=%@", res.scores);
        
        
        
        
        // Get average
        }else if([result isKindOfClass:QBRAverageResult.class]){
            QBRAverageResult *res = (QBRAverageResult *)result;
            NSLog(@"QBRAverageResult, average=%@", res.average);
        
        // Get averages
        }else if([result isKindOfClass:QBRAveragePagedResult.class]){
            QBRAveragePagedResult *res = (QBRAveragePagedResult *)result;
            NSLog(@"QBRAveragePagedResult, averages=%@", res.averages);

        
        
        
        // Get/Create/Update game mode parameter value average
        }else if([result isKindOfClass:QBRGameModeParameterValueResult.class]){
            QBRGameModeParameterValueResult *res = (QBRGameModeParameterValueResult *)result;
            NSLog(@"QBRGameModeParameterValueResult, gamemodeparametervalue=%@", res.gameModeParameterValue);
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
