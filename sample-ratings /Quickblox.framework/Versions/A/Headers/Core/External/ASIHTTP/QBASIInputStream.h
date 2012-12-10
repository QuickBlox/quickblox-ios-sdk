//
//  QBASIInputStream.h
//  Part of QBASIHTTPRequest -> http://allseeing-i.com/QBASIHTTPRequest
//
//  Created by Ben Copsey on 10/08/2009.
//  Copyright 2009 All-Seeing Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QBASIHTTPRequest;

// This is a wrapper for NSInputStream that pretends to be an NSInputStream itself
// Subclassing NSInputStream seems to be tricky, and may involve overriding undocumented methods, so we'll cheat instead.
// It is used by QBASIHTTPRequest whenever we have a request body, and handles measuring and throttling the bandwidth used for uploading

@interface QBASIInputStream : NSObject {
	NSInputStream *stream;
	QBASIHTTPRequest *request;
}
+ (id)inputStreamWithFileAtPath:(NSString *)path request:(QBASIHTTPRequest *)request;
+ (id)inputStreamWithData:(NSData *)data request:(QBASIHTTPRequest *)request;

@property (retain, nonatomic) NSInputStream *stream;
@property (assign, nonatomic) QBASIHTTPRequest *request;
@end
