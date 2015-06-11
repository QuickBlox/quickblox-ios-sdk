//
//  QBCOUtils.h
//  Quickblox
//
//  Created by Igor Khomenko on 9/5/13.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QBCOCustomObject;

@interface QBCOUtils : NSObject

+ (NSDictionary *)extractPermissionsFromRecord:(QBCOCustomObject *)record;
+ (NSDictionary *)extractFieldsFromRecord:(QBCOCustomObject *)record;

#pragma mark
#pragma mark Object extractions

+ (void)extractFieldsToRequestParams:(QBCOCustomObject *)record
                       requestParams:(NSMutableDictionary *)requestParams
                           keyFormat:(NSString *)keyFormat;

+ (void)extractPermissionsToRequestParams:(QBCOCustomObject *)record
                            requestParams:(NSMutableDictionary *)requestParams
                                keyFormat:(NSString *)keyFormat;

+ (void)extractSpecialUpdateOperatorsToRequestParams:(NSDictionary *)specialUpdateOperators
                                       requestParams:(NSMutableDictionary *)requestParams
                                           keyFormat:(NSString *)keyFormat;


#pragma mark
#pragma mark General extractions

+ (void)extractParametersToRequestURL:(NSDictionary *)parameters
                           requestURL:(NSMutableString *)requestURL
                            keyFormat:(NSString *)keyFormat;

@end
