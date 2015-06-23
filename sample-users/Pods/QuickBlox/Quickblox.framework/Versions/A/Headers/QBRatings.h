//
//  QBRatings.h
//  QuickBlox
//
//  Created by Igor Khomenko on 4/13/11.
//  Copyright 2011 QuickBlox. All rights reserved.
//

#import "QBBaseModule.h"

@protocol Cancelable;
@protocol QBActionStatusDelegate;
@class QBRGameMode;
@class QBRScore;
@class QBRScoreGetRequest;
@class QBRGameModeParameterValue;

@interface QBRatings : QBBaseModule {
    
}

#pragma mark -
#pragma mark Game Mode

#pragma mark -
#pragma mark Create Game Mode

/**
 Create game mode
 
 Type of Result - QBRGameModeResult
 
 @param title Title of new game mode
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBRGameModeResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable>*) createGameModeWithTitle:(NSString*)title 
                                      delegate:(NSObject<QBActionStatusDelegate>*)delegate __attribute__((deprecated("Use Custom Objects module API instead.")));
///
+ (NSObject<Cancelable>*) createGameModeWithTitle:(NSString*)title 
                                      delegate:(NSObject<QBActionStatusDelegate>*)delegate 
                                       context:(void*)context __attribute__((deprecated("Use Custom Objects module API instead.")));


#pragma mark -
#pragma mark Get Game Mode with ID

/**
 Get game mode with ID
 
 Type of Result - QBRGameModeResult
 
 @param gameModeId ID of game mode
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBRGameModeResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable>*) gameModeWithID:(NSUInteger)gameModeId
                                delegate:(NSObject<QBActionStatusDelegate>*)delegate __attribute__((deprecated("Use Custom Objects module API instead.")));
///
+ (NSObject<Cancelable>*) gameModeWithID:(NSUInteger)gameModeId
                                delegate:(NSObject<QBActionStatusDelegate>*)delegate 
                                 context:(void*)context __attribute__((deprecated("Use Custom Objects module API instead.")));


#pragma mark -
#pragma mark Get Game Modes

/**
 Get all game modes
 
 Type of Result - QBRGameModePagedResult
 
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBRGameModePagedResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable>*) gameModesWithDelegate:(NSObject<QBActionStatusDelegate>*)delegate __attribute__((deprecated("Use Custom Objects module API instead.")));
///
+ (NSObject<Cancelable>*) gameModesWithDelegate:(NSObject<QBActionStatusDelegate>*)delegate 
                                 context:(void*)context __attribute__((deprecated("Use Custom Objects module API instead.")));


#pragma mark -
#pragma mark Update Game Mode

/**
 Update game mode
 
 Type of Result - QBRGameModeResult
 
 @param gameMode An instance of QBRGameMode which will be updated
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBRGameModeResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable>*) updateGameMode:(QBRGameMode *)gameMode
                                delegate:(NSObject<QBActionStatusDelegate>*)delegate __attribute__((deprecated("Use Custom Objects module API instead.")));
///
+ (NSObject<Cancelable>*) updateGameMode:(QBRGameMode *)gameMode
                                delegate:(NSObject<QBActionStatusDelegate>*)delegate 
                                 context:(void*)context __attribute__((deprecated("Use Custom Objects module API instead.")));


#pragma mark -
#pragma mark Delete Game Mode

/**
 Delete game mode
 
 Type of Result - QBRGameModeResult
 
 @param gameModeId ID of game mode
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBRGameModeResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable>*) deleteGameModeWithID:(NSUInteger)gameModeId
                                      delegate:(NSObject<QBActionStatusDelegate>*)delegate __attribute__((deprecated("Use Custom Objects module API instead.")));
///
+ (NSObject<Cancelable>*) deleteGameModeWithID:(NSUInteger)gameModeId
                                      delegate:(NSObject<QBActionStatusDelegate>*)delegate 
                                       context:(void*)context __attribute__((deprecated("Use Custom Objects module API instead.")));


#pragma mark -
#pragma mark Score


#pragma mark -
#pragma mark Create Score

/**
 Create score
 
 Type of Result - QBRScoreResult
 
 @param score An instance of QBRScore
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBRScoreResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)createScore:(QBRScore *)score delegate:(NSObject<QBActionStatusDelegate> *)delegate __attribute__((deprecated("Use Custom Objects module API instead.")));
///
+ (NSObject<Cancelable> *)createScore:(QBRScore *)score delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context __attribute__((deprecated("Use Custom Objects module API instead.")));


#pragma mark -
#pragma mark Update Score

/**
 Update score
 
 Type of Result - QBRScoreResult
 
 @param score An instance of QBRScore
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBRScoreResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)updateScore:(QBRScore *)score delegate:(NSObject<QBActionStatusDelegate> *)delegate __attribute__((deprecated("Use Custom Objects module API instead.")));
///
+ (NSObject<Cancelable> *)updateScore:(QBRScore *)score delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context __attribute__((deprecated("Use Custom Objects module API instead.")));


#pragma mark -
#pragma mark Get Score with ID

/**
 Get score with ID
 
 Type of Result - QBRScoreResult
 
 @param scoreId An ID of QBRScore that will be retrieved
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBRScoreResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)scoreWithID:(NSUInteger)scoreId delegate:(NSObject<QBActionStatusDelegate> *)delegate __attribute__((deprecated("Use Custom Objects module API instead.")));
///
+ (NSObject<Cancelable> *)scoreWithID:(NSUInteger)scoreId delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context __attribute__((deprecated("Use Custom Objects module API instead.")));


#pragma mark -
#pragma mark Delete Score by ID

/**
 Delete score with ID
 
 Type of Result - QBRScoreResult
 
 @param scoreId An ID of QBRScore that will be deleted
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBRScoreResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)deleteScoreWithID:(NSUInteger)scoreId delegate:(NSObject<QBActionStatusDelegate> *)delegate __attribute__((deprecated("Use Custom Objects module API instead.")));
///
+ (NSObject<Cancelable> *)deleteScoreWithID:(NSUInteger)scoreId delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context __attribute__((deprecated("Use Custom Objects module API instead.")));


#pragma mark -
#pragma mark Get Top N Scores by Game Mode ID

/**
 Retrieve top N results by GameMode identifier (max last 10 results, for more - use equivalent method with 'extendedRequest' argument).
 
 Type of Result - QBRScorePagedResult
 
 @param topN A number of the results, which is specified as a limit of Scores
 @param gameModeId ID of game mode
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBRScorePagedResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)topNScores:(int)topN gameModeID:(NSUInteger)gameModeID delegate:(NSObject<QBActionStatusDelegate> *)delegate __attribute__((deprecated("Use Custom Objects module API instead.")));
///
+ (NSObject<Cancelable> *)topNScores:(int)topN gameModeID:(NSUInteger)gameModeID delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context __attribute__((deprecated("Use Custom Objects module API instead.")));

/**
 Retrieve top N results by GameMode identifier.
 
 Type of Result - QBRScorePagedResult
 
 @param topN A number of the results, which is specified as a limit of Scores
 @param gameModeId ID of game mode
 @param extendedRequest  Extended set of request parameters (pagination included)
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBRScorePagedResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)topNScores:(int)topN gameModeID:(NSUInteger)gameModeID extendedRequest:(QBRScoreGetRequest *)extendedRequest delegate:(NSObject<QBActionStatusDelegate> *)delegate __attribute__((deprecated("Use Custom Objects module API instead.")));
///
+ (NSObject<Cancelable> *)topNScores:(int)topN gameModeID:(NSUInteger)gameModeID extendedRequest:(QBRScoreGetRequest *)extendedRequest delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context __attribute__((deprecated("Use Custom Objects module API instead.")));


#pragma mark -
#pragma mark Get Scores for User

/**
 Retrieve Scores for user (last 10 scores, for more - use equivalent method with 'extendedRequest' argument)".
 
 Type of Result - QBRScorePagedResult
 
 @param userID ID of QBUUser who scores will be retrieved
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBRScorePagedResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)scoresWithUserID:(NSUInteger)userID delegate:(NSObject<QBActionStatusDelegate> *)delegate __attribute__((deprecated("Use Custom Objects module API instead.")));
+ (NSObject<Cancelable> *)scoresWithUserID:(NSUInteger)userID delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context __attribute__((deprecated("Use Custom Objects module API instead.")));

/**
 Retrieve Scores for user.
 
 Type of Result - QBRScorePagedResult
 
 @param userID ID of QBUUser who scores will be retrieved
 @param extendedRequest  Extended set of request parameters (pagination included)
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBRScorePagedResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)scoresWithUserID:(NSUInteger)userID extendedRequest:(QBRScoreGetRequest *)extendedRequest delegate:(NSObject <QBActionStatusDelegate> *)delegate __attribute__((deprecated("Use Custom Objects module API instead.")));
///
+ (NSObject<Cancelable> *)scoresWithUserID:(NSUInteger)userID extendedRequest:(QBRScoreGetRequest *)extendedRequest delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context __attribute__((deprecated("Use Custom Objects module API instead.")));


#pragma mark -
#pragma mark Average


#pragma mark -
#pragma mark Get Average Scores by GameModeID

/**
 Retrieve average scores by GameMode identifier for all users of the current game mode
 
 Type of Result - QBRAvarageResult
 
 @param gameModeId ID of game mode
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBRAvarageResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)averageWithGameModeID:(NSUInteger)gameModeId delegate:(NSObject<QBActionStatusDelegate> *)delegate __attribute__((deprecated("Use Custom Objects module API instead.")));
///
+ (NSObject<Cancelable> *)averageWithGameModeID:(NSUInteger)gameModeId delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context __attribute__((deprecated("Use Custom Objects module API instead.")));


#pragma mark -
#pragma mark Get Average Scores for Application

/**
 Retrieve average Scores for current application.
 
 Type of Result - QBRAvaragePagedResult
 
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBRAvaragePagedResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)averagesForApplicationWithDelegate:(NSObject<QBActionStatusDelegate> *)delegate __attribute__((deprecated("Use Custom Objects module API instead.")));
///
+ (NSObject<Cancelable> *)averagesForApplicationWithDelegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context __attribute__((deprecated("Use Custom Objects module API instead.")));


#pragma mark -
#pragma mark Game Mode Parameter Value


#pragma mark -
#pragma mark Create GameModeParameterValue

/**
 Create the values for the parameters of the game mode (GameModeParameter). A "gameModeID" which has been specified while creating a game mode parameter and 'scoreID' should be the same.
 
 Type of Result - QBRGameModeParameterValueResult
 
 @param gameModeParameterValue An instance of QBRGameModeParameterValue
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBRGameModeParameterValueResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)createGameModeParameterValue:(QBRGameModeParameterValue *)gameModeParameterValue delegate:(NSObject<QBActionStatusDelegate> *)delegate __attribute__((deprecated("Use Custom Objects module API instead.")));
+ (NSObject<Cancelable> *)createGameModeParameterValue:(QBRGameModeParameterValue *)gameModeParameterValue delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context __attribute__((deprecated("Use Custom Objects module API instead.")));


#pragma mark -
#pragma mark Get GameModeParameterValue with ID

/**
 Get Game Mode Parameter Value with ID
 
 Type of Result - QBRGameModeParameterValueResult
 
 @param gameModeParameterValueID An ID of instance of QBRGameModeParameterValue that will be retrieved
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBRGameModeParameterValueResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)gameModeParameterValueWithID:(NSUInteger)gameModeParameterValueID delegate:(NSObject<QBActionStatusDelegate> *)delegate __attribute__((deprecated("Use Custom Objects module API instead.")));

+ (NSObject<Cancelable> *)gameModeParameterValueWithID:(NSUInteger)gameModeParameterValueID delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context __attribute__((deprecated("Use Custom Objects module API instead.")));


#pragma mark -
#pragma mark Update GameModeParameterValue

/**
 Update Game Mode Parameter Value
 
 Type of Result - QBRGameModeParameterValueResult
 
 @param gameModeParameterValue An instance of QBRGameModeParameterValue
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBRGameModeParameterValueResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)updateGameModeParameterValue:(QBRGameModeParameterValue *)gameModeParameterValue delegate:(NSObject<QBActionStatusDelegate> *)delegate __attribute__((deprecated("Use Custom Objects module API instead.")));

+ (NSObject<Cancelable> *)updateGameModeParameterValue:(QBRGameModeParameterValue *)gameModeParameterValue delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context __attribute__((deprecated("Use Custom Objects module API instead.")));

@end
