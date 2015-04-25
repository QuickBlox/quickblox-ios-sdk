#import <Foundation/Foundation.h>

typedef struct {
    UInt32 m[3];
} QBMongoDBObjectID;

@interface QBMongoDB : NSObject

+ (QBMongoDBObjectID) objectID;
+ (NSString *)stringWithId:(QBMongoDBObjectID)ID;
+ (QBMongoDBObjectID)idWithString:(NSString *)string;

@end
