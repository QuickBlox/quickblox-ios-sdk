//
//  QBASICacheDelegate.h
//  Part of QBASIHTTPRequest -> http://allseeing-i.com/QBASIHTTPRequest
//
//  Created by Ben Copsey on 01/05/2010.
//  Copyright 2010 All-Seeing Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
@class QBASIHTTPRequest;

// Cache policies control the behaviour of a cache and how requests use the cache
// When setting a cache policy, you can use a combination of these values as a bitmask
// For example: [request setCachePolicy:QBASIAskServerIfModifiedCachePolicy|QBASIFallbackToCacheIfLoadFailsCachePolicy|QBASIDoNotWriteToCacheCachePolicy];
// Note that some of the behaviours below are mutally exclusive - you cannot combine QBASIAskServerIfModifiedWhenStaleCachePolicy and QBASIAskServerIfModifiedCachePolicy, for example.
typedef enum _QBASICachePolicy {

	// The default cache policy. When you set a request to use this, it will use the cache's defaultCachePolicy
	// QBASIDownloadCache's default cache policy is 'QBASIAskServerIfModifiedWhenStaleCachePolicy'
	QBASIUseDefaultCachePolicy = 0,

	// Tell the request not to read from the cache
	QBASIDoNotReadFromCacheCachePolicy = 1,

	// The the request not to write to the cache
	QBASIDoNotWriteToCacheCachePolicy = 2,

	// Ask the server if there is an updated version of this resource (using a conditional GET) ONLY when the cached data is stale
	QBASIAskServerIfModifiedWhenStaleCachePolicy = 4,

	// Always ask the server if there is an updated version of this resource (using a conditional GET)
	QBASIAskServerIfModifiedCachePolicy = 8,

	// If cached data exists, use it even if it is stale. This means requests will not talk to the server unless the resource they are requesting is not in the cache
	QBASIOnlyLoadIfNotCachedCachePolicy = 16,

	// If cached data exists, use it even if it is stale. If cached data does not exist, stop (will not set an error on the request)
	QBASIDontLoadCachePolicy = 32,

	// Specifies that cached data may be used if the request fails. If cached data is used, the request will succeed without error. Usually used in combination with other options above.
	QBASIFallbackToCacheIfLoadFailsCachePolicy = 64
} QBASICachePolicy;

// Cache storage policies control whether cached data persists between application launches (QBASICachePermanentlyCacheStoragePolicy) or not (QBASICacheForSessionDurationCacheStoragePolicy)
// Calling [QBASIHTTPRequest clearSession] will remove any data stored using QBASICacheForSessionDurationCacheStoragePolicy
typedef enum _QBASICacheStoragePolicy {
	QBASICacheForSessionDurationCacheStoragePolicy = 0,
	QBASICachePermanentlyCacheStoragePolicy = 1
} QBASICacheStoragePolicy;


@protocol QBASICacheDelegate <NSObject>

@required

// Should return the cache policy that will be used when requests have their cache policy set to QBASIUseDefaultCachePolicy
- (QBASICachePolicy)defaultCachePolicy;

// Returns the date a cached response should expire on. Pass a non-zero max age to specify a custom date.
- (NSDate *)expiryDateForRequest:(QBASIHTTPRequest *)request maxAge:(NSTimeInterval)maxAge;

// Updates cached response headers with a new expiry date. Pass a non-zero max age to specify a custom date.
- (void)updateExpiryForRequest:(QBASIHTTPRequest *)request maxAge:(NSTimeInterval)maxAge;

// Looks at the request's cache policy and any cached headers to determine if the cache data is still valid
- (BOOL)canUseCachedDataForRequest:(QBASIHTTPRequest *)request;

// Removes cached data for a particular request
- (void)removeCachedDataForRequest:(QBASIHTTPRequest *)request;

// Should return YES if the cache considers its cached response current for the request
// Should return NO is the data is not cached, or (for example) if the cached headers state the request should have expired
- (BOOL)isCachedDataCurrentForRequest:(QBASIHTTPRequest *)request;

// Should store the response for the passed request in the cache
// When a non-zero maxAge is passed, it should be used as the expiry time for the cached response
- (void)storeResponseForRequest:(QBASIHTTPRequest *)request maxAge:(NSTimeInterval)maxAge;

// Removes cached data for a particular url
- (void)removeCachedDataForURL:(NSURL *)url;

// Should return an NSDictionary of cached headers for the passed URL, if it is stored in the cache
- (NSDictionary *)cachedResponseHeadersForURL:(NSURL *)url;

// Should return the cached body of a response for the passed URL, if it is stored in the cache
- (NSData *)cachedResponseDataForURL:(NSURL *)url;

// Returns a path to the cached response data, if it exists
- (NSString *)pathToCachedResponseDataForURL:(NSURL *)url;

// Returns a path to the cached response headers, if they url
- (NSString *)pathToCachedResponseHeadersForURL:(NSURL *)url;

// Returns the location to use to store cached response headers for a particular request
- (NSString *)pathToStoreCachedResponseHeadersForRequest:(QBASIHTTPRequest *)request;

// Returns the location to use to store a cached response body for a particular request
- (NSString *)pathToStoreCachedResponseDataForRequest:(QBASIHTTPRequest *)request;

// Clear cached data stored for the passed storage policy
- (void)clearCachedResponsesForStoragePolicy:(QBASICacheStoragePolicy)cachePolicy;

@end
