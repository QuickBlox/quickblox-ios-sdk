//
//  QBASIHTTPRequestConfig.h
//  Part of QBASIHTTPRequest -> http://allseeing-i.com/QBASIHTTPRequest
//
//  Created by Ben Copsey on 14/12/2009.
//  Copyright 2009 All-Seeing Interactive. All rights reserved.
//


// ======
// Debug output configuration options
// ======

// If defined will use the specified function for debug logging
// Otherwise use NSLog
#ifndef QBASI_DEBUG_LOG
    #define QBASI_DEBUG_LOG NSLog
#endif

// When set to 1 QBASIHTTPRequests will print information about what a request is doing
#ifndef DEBUG_REQUEST_STATUS
	#define DEBUG_REQUEST_STATUS 0
#endif

// When set to 1, QBASIFormDataRequests will print information about the request body to the console
#ifndef DEBUG_FORM_DATA_REQUEST
	#define DEBUG_FORM_DATA_REQUEST 0
#endif

// When set to 1, QBASIHTTPRequests will print information about bandwidth throttling to the console
#ifndef DEBUG_THROTTLING
	#define DEBUG_THROTTLING 0
#endif

// When set to 1, QBASIHTTPRequests will print information about persistent connections to the console
#ifndef DEBUG_PERSISTENT_CONNECTIONS
	#define DEBUG_PERSISTENT_CONNECTIONS 0
#endif

// When set to 1, QBASIHTTPRequests will print information about HTTP authentication (Basic, Digest or NTLM) to the console
#ifndef DEBUG_HTTP_AUTHENTICATION
    #define DEBUG_HTTP_AUTHENTICATION 0
#endif
