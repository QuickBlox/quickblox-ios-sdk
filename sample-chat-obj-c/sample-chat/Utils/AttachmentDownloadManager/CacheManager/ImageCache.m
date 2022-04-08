//
//  ImageCache.m
//  sample-chat
//
//  Created by Injoit on 28.02.2022.
//  Copyright © 2022 Quickblox. All rights reserved.
//

#import "ImageCache.h"

@interface ImageCache ()
@property (strong, nonatomic) NSCache *imageCache;
@property (strong, nonatomic) NSFileManager *fileManager;
@end

@implementation ImageCache

//Shared Instance
+ (instancetype)instance {
    static ImageCache *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

//MARK: - Life Cycle
- (instancetype)init {
    self = [super init];
    if (self) {
        self.imageCache = [[NSCache alloc] init];
        self.imageCache.name = @"chat.imageCache";
        self.imageCache.countLimit = 100; // Max 100 images in memory.
        self.imageCache.totalCostLimit = 90*1024*1024; // Max 90MB used.
        self.fileManager = [NSFileManager defaultManager];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        self.cachesDirectory = paths.firstObject;
    }
    return self;
}

- (UIImage *)imageFromCacheForKey:(NSString *)key {
    UIImage *image = [self.imageCache objectForKey:key];
    if (image) {
        return image;
    }
    return nil;
}

- (void)storeImage:(UIImage *)image forKey:(NSString *)key {
    if (!image) {
        return [self removeImageForKey:key];
    }
    [self.imageCache setObject:image forKey:key cost:1];
}

- (void)removeImageForKey:(NSString *)key {
    [self.imageCache removeObjectForKey:key];
}
- (void)removeAllImages {
    [self.imageCache removeAllObjects];
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
            if (downloadedData) {
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

- (void)clearCache {
    [self removeAllImages];
  NSArray *directoryContents = [self.fileManager contentsOfDirectoryAtPath:self.cachesDirectory error:nil];
    for (NSString *file in directoryContents ) {
        [self.fileManager removeItemAtPath:file error:nil];
    }
}

- (NSURL *)directoryForStringUrl:(NSString *)stringUrl {
    NSString *fileURL = [NSURL URLWithString:stringUrl].lastPathComponent;
    NSString *path = [NSString stringWithFormat:@"%@/%@", self.cachesDirectory, fileURL];
    return [NSURL fileURLWithPath:path];
}
@end
