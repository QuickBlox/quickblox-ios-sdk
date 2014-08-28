//
//  RatingsModuleViewController.m
//  QB_SDK_Samples
//
//  Created by Igor Khomenko on 6/7/12.
//  Copyright (c) 2012 Injoit. All rights reserved.
//

#import "RatingsModuleViewController.h"
#import "RatingsDataSource.h"

@interface RatingsModuleViewController ()
@property (nonatomic) RatingsDataSource *dataSource;
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

- (void)viewDidLoad{
    [super viewDidLoad];
    self.dataSource = [[RatingsDataSource alloc] init];
    tableView.dataSource = self.dataSource;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    switch (indexPath.section) {
        // Game Mode
        case 0:
            switch (indexPath.row) {
                // Create game mode
                case 0:{
                    if(withQBContext){
                        [QBRatings createGameModeWithTitle:@"Car3D Game" delegate:self context:testContext];
                    }else{
                        [QBRatings createGameModeWithTitle:@"Car3D Game" delegate:self];
                    }
                }
                    break;
                    
                // Get Game Mode with ID
                case 1:
                    if(withQBContext){
                        [QBRatings gameModeWithID:113 delegate:self context:testContext];
                    }else{
                        [QBRatings gameModeWithID:113 delegate:self];
                    }

                    break;
                    
                // Get Game Modes
                case 2:
                    if(withQBContext){
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
                    
                    if(withQBContext){
                        [QBRatings updateGameMode:gameMode delegate:self context:testContext];
                    }else{
                        [QBRatings updateGameMode:gameMode delegate:self];
                    }
                }
                    break;
                    
                // Delete game mode
                case 4:{
                    if(withQBContext){
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
                    if(withQBContext){
                        [QBRatings createScore:score delegate:self context:testContext];
                    }else{
                        [QBRatings createScore:score delegate:self];
                    }
                }
                    break;
                    
                // Get Score with ID
                case 1:
                    if(withQBContext){
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
                    if(withQBContext){
                        [QBRatings updateScore:score delegate:self context:testContext];
                    }else{
                        [QBRatings updateScore:score delegate:self];
                    }
                }
                    break;
                    
                // Delete score with ID
                case 3:{
                    if(withQBContext){
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
                        
                        if(withQBContext){
                            [QBRatings topNScores:3 gameModeID:114 extendedRequest:getRequest delegate:self context:testContext];
                        }else{
                            [QBRatings topNScores:3 gameModeID:114 extendedRequest:getRequest delegate:self];
                        } 
                        
                    }else{
                        if(withQBContext){
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
                        
                        if(withQBContext){
                            [QBRatings scoresWithUserID:14605 extendedRequest:getRequest delegate:self context:testContext];
                        }else{
                            [QBRatings scoresWithUserID:14605 extendedRequest:getRequest delegate:self];
                        } 
                        
                    }else{
                        if(withQBContext){
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
                    if(withQBContext){
                        [QBRatings averageWithGameModeID:114 delegate:self context:testContext];
                    }else{
                        [QBRatings averageWithGameModeID:114  delegate:self];
                    }
                }
                    break;
                    
                // Get averages for application
                case 1:
                    if(withQBContext){
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
                    if(withQBContext){
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
                    if(withQBContext){
                        [QBRatings updateGameModeParameterValue:gameModeParameterValue delegate:self context:testContext];
                    }else{
                        [QBRatings updateGameModeParameterValue:gameModeParameterValue delegate:self];
                    }
                }
                    
                    break;
                    
                // Get Game mode parameter value with ID
                case 2:
                    if(withQBContext){
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
