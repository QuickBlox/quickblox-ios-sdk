//
//  Utils.h
//  CoreAudio iLBC
//
//  Created by Igor Khomenko on 12/26/13.
//
//

#ifndef CoreAudio_iLBC_Utils_h
#define CoreAudio_iLBC_Utils_h

static void QBCheckError(OSStatus error, const char *operation)
{
	if (!error){
        return;
    }
    
    NSError *err = [NSError errorWithDomain:NSOSStatusErrorDomain code:error userInfo:nil];
    NSString *localDesc = [err localizedDescription];
    const char *str = [localDesc UTF8String];
    
	fprintf(stderr, "Error: %s (%s)\n", operation, str);
    
	exit(1);
}

#endif
