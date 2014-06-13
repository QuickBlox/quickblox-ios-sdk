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
	if (error == noErr){
        return;
    }
	
	char str[20];
	// see if it appears to be a 4-char-code
	*(UInt32 *)(str + 1) = CFSwapInt32HostToBig(error);
	if (isprint(str[1]) && isprint(str[2]) && isprint(str[3]) && isprint(str[4])) {
		str[0] = str[5] = '\'';
		str[6] = '\0';
	} else {
		// no, format it as an integer
		sprintf(str, "%d", (int)error);
    }
    
	fprintf(stderr, "Error: %s (%s)\n", operation, str);
    
	exit(1);
}

#endif
