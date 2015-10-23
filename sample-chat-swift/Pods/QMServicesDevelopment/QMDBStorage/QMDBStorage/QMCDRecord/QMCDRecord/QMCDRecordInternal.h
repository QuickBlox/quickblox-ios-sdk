#import <Foundation/Foundation.h>

/**
 @since Available in v2.0 and later.
 */
@interface QMCDRecord : NSObject

/**
 Cleans up by setting the default stack to nil.
 
 @since Available in v2.0 and later.
 */
+ (void) cleanUp;

/**
 Determines the store file name your app should use. This method is used by the QMCDRecord SQLite stacks when a store file is not specified. The file name returned is in the form "<ApplicationName>.sqlite". `<ApplicationName>` is taken from the application's info dictionary, which is retrieved from the method [[NSBundle mainBundle] infoDictionary]. If no bundle name is available, "CoreDataStore.sqlite" will be used.

 @return String of the form <ApplicationName>.sqlite

 @since Available in v2.0 and later.
 */
+ (NSString *) defaultStoreName;

@end
