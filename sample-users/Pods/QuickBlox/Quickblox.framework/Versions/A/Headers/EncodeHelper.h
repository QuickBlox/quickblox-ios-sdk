//
//  EncodeHelper.h
//  Core
//

//  Copyright 2010 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface EncodeHelper : NSObject {

}
+(NSString*)urlencode:(NSString*)unencodedString;
+(NSString*)urldecode:(NSString*)encodedString;
@end
