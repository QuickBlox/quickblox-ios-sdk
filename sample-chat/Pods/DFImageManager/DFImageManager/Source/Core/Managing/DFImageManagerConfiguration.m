// The MIT License (MIT)
//
// Copyright (c) 2015 Alexander Grebenyuk (github.com/kean).
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "DFImageManagerConfiguration.h"


@implementation DFImageManagerConfiguration

- (instancetype)initWithFetcher:(id<DFImageFetching>)fetcher {
    if (self = [super init]) {
        NSParameterAssert(fetcher);
        _fetcher = fetcher;
        _processingQueue = [NSOperationQueue new];
        _processingQueue.maxConcurrentOperationCount = 2;
        _maximumConcurrentPreheatingRequests = 2;
    }
    return self;
}

+ (instancetype)configurationWithFetcher:(id<DFImageFetching>)fetcher {
    return [[DFImageManagerConfiguration alloc] initWithFetcher:fetcher];
}

+ (instancetype)configurationWithFetcher:(id<DFImageFetching>)fetcher processor:(id<DFImageProcessing>)processor cache:(id<DFImageCaching>)cache {
    DFImageManagerConfiguration *conf = [self configurationWithFetcher:fetcher];
    conf.processor = processor;
    conf.cache = cache;
    return conf;
}

- (id)copyWithZone:(NSZone *)zone {
    DFImageManagerConfiguration *copy = [[DFImageManagerConfiguration alloc] initWithFetcher:self.fetcher];
    copy.cache = self.cache;
    copy.processor = self.processor;
    copy.processingQueue = self.processingQueue;
    copy.maximumConcurrentPreheatingRequests = self.maximumConcurrentPreheatingRequests;
    return copy;
}

@end
