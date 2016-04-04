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

#import "DFImageTask.h"

@implementation DFImageTask

- (void)resume {
    [NSException raise:NSInternalInconsistencyException format:@"Abstract method called %@", NSStringFromSelector(_cmd)];
}

- (void)cancel {
    [NSException raise:NSInternalInconsistencyException format:@"Abstract method called %@", NSStringFromSelector(_cmd)];
}

- (void)setPriority:(DFImageRequestPriority)priority {
    [NSException raise:NSInternalInconsistencyException format:@"Abstract method called %@", NSStringFromSelector(_cmd)];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (BOOL)isEqual:(id)object {
    return self == object;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ %p> { state = %lu, error = %@ }", [self class], self, (unsigned long)self.state, self.error];
}

@end
