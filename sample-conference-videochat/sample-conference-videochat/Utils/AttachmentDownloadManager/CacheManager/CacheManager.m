//
//  CacheManager.m
//  sample-conference-videochat
//
//  Created by Injoit on 06.03.2020.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import "CacheManager.h"

@interface CacheManager ()
@property (strong, nonatomic) NSFileManager *fileManager;
@end

@implementation CacheManager

//MARK: - Life Cycle
- (instancetype)init {
    self = [super init];
    if (self) {
        self.fileManager = [NSFileManager defaultManager];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        self.cachesDirectory = paths.firstObject;
    }
    return self;
}

//Shared Instance
+ (instancetype)instance {
    static CacheManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (void)clearCache {
  NSArray *directoryContents = [self.fileManager contentsOfDirectoryAtPath:self.cachesDirectory error:nil];
    for (NSString *file in directoryContents ) {
        [self.fileManager removeItemAtPath:file error:nil];
    }
}

- (void)getFileWithStringUrl:(NSString *)stringUrl completionHandler: (void(^)(NSURL * _Nullable url, NSError * _Nullable error))completion {
    
    NSURL *file = [self directoryForStringUrl:stringUrl];
    
    //return file path if already exists in cache directory
    if ([self.fileManager fileExistsAtPath:file.path]) {
        if (completion) {
            completion(file, nil);
        }
    } else {
        NSData *downloadedData = [NSData dataWithContentsOfURL:[NSURL URLWithString:stringUrl]];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^
                       {
            if (downloadedData)
            {
                [downloadedData writeToURL:file atomically:YES];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completion) {
                        completion(file, nil);
                    }
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSError *error = [NSError errorWithDomain:@"SomeErrorDomain" code:-2001 userInfo:@{@"description": @"Can't download video"}];
                    if (completion) {
                        completion(nil, error);
                    }
                });
            }
        });
    }
}

- (NSURL *)directoryForStringUrl:(NSString *)stringUrl {
    NSString *fileURL = [NSURL URLWithString:stringUrl].lastPathComponent;
    NSString *path = [NSString stringWithFormat:@"%@/%@", self.cachesDirectory, fileURL];
    return [NSURL fileURLWithPath:path];
}

@end
