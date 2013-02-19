//
//  BaseService.h
//  BaseService
//
//

#import <Foundation/Foundation.h>

@class QBASessionCreationRequest;

@interface BaseService : NSObject{
}

@property (nonatomic, retain) NSString *token;
@property (nonatomic, assign) enum QBSessionType sessionType;
@property (nonatomic, retain) QBASessionCreationRequest *sessionCreationRequest;

+ (void) createSharedService;
+ (BaseService *) sharedService;

- (void)reset;


#pragma mark -
#pragma mark Server endpoint url

+ (NSString *)serverEndpointURL;
+ (NSString *)chatServerEndpointURL;
+ (NSString *)chatMUCServerEndpointURL;

@end