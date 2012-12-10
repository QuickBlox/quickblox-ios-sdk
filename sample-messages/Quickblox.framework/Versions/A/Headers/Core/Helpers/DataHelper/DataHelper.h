//
//  DataHelper.h
//  BaseService
//
//

#import <Foundation/Foundation.h>


@interface DataHelper : NSObject {}
+(NSString*)stringFromData:(NSData*)data encoding:(NSStringEncoding)encoding;
+(NSString*)stringFromData:(NSData*)data;
+(NSData*)dataFromString:(NSString*)string encoding:(NSStringEncoding)encoding;
+(NSData*)dataFromString:(NSString*)string;
+ (NSString *)encodeBase64WithData:(NSData *)objData; 
+ (NSString *)encodeBase64WithString:(NSString *)strData;
+ (NSData *)decodeBase64WithString:(NSString *)strBase64;
@end
