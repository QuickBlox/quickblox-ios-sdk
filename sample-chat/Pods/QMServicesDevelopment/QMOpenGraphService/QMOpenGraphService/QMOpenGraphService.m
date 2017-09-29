//
//  QMOpenGraphService.m
//  QMOpenGraphService
//
//  Created by Andrey Ivanov on 14/06/2017.
//  Copyright © 2017 QuickBlox. All rights reserved.
//

#import "QMOpenGraphService.h"
#import "QMSLog.h"

@interface QMOpenGraphLoadOperation : NSBlockOperation

@property (nonatomic) NSString *identifier;
@property (copy, nonatomic) dispatch_block_t cancelBlock;
@property (strong, nonatomic) QBRequest *request;

@end

static NSString *const kQMBaseGraphURL = @"https://ogs.quickblox.com";
static NSString *const kQMKeyTitle = @"ogTitle";
static NSString *const kQMKeyDescription = @"ogDescription";
static NSString *const kQMKeyImageURL = @"ogImage";

@interface QMOpenGraphService()

@property (strong, nonatomic) QBMulticastDelegate <QMOpenGraphServiceDelegate> *multicastDelegate;
@property (nonatomic, weak) id <QMOpenGraphCacheDataSource> cahceDataSource;
@property (nonatomic) QBHTTPClient *ogsClient;
@property (nonatomic) NSOperationQueue *operationQueue;
@property (nonatomic) dispatch_queue_t ogsQueue;

@end

@implementation QMOpenGraphService

- (instancetype)initWithServiceManager:(id<QMServiceManagerProtocol>)serviceManager
                       cacheDataSource:(id<QMOpenGraphCacheDataSource>)cacheDataSource {
    
    if (self = [super initWithServiceManager:serviceManager]) {
        
        _cahceDataSource = cacheDataSource;
        _memoryStorage = [[QMOpenGraphMemoryStorage alloc] init];
        _multicastDelegate = (id<QMOpenGraphServiceDelegate>)[[QBMulticastDelegate alloc] init];
        _ogsClient = [[QBHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:kQMBaseGraphURL]];
        _ogsClient.completionQueue = dispatch_queue_create("com.q-municate.ogsClient", DISPATCH_QUEUE_SERIAL);
        _ogsQueue = dispatch_queue_create("com.q-municate.ogs", DISPATCH_QUEUE_CONCURRENT);
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.maxConcurrentOperationCount = 1;
    }
    
    return self;
}

- (void)addDelegate:(id <QMOpenGraphServiceDelegate>)delegate {
    [_multicastDelegate addDelegate:delegate];
}

- (void)removeDelegate:(id <QMOpenGraphServiceDelegate>)delegate {
    [_multicastDelegate addDelegate:delegate];
}

- (void)loadOpenGraphForURL:(NSString *)url ID:(NSString *)ID {
    
    for (QMOpenGraphLoadOperation *o in _operationQueue.operations) {
        
        if ([o.identifier isEqualToString:ID]) {
            return;
        }
    }
    
    QMOpenGraphLoadOperation *operation = [[QMOpenGraphLoadOperation alloc] init];
    __weak __typeof(operation)weakOperation = operation;
    __weak __typeof(self)weakSelf = self;
    
    operation.cancelBlock = ^{
        
        [weakOperation.request cancel];
        @synchronized(self.memoryStorage) {
            
            self.memoryStorage[ID] = nil;
        }
    };
    
    operation.identifier = ID;
    [operation addExecutionBlock:^{
        
        QMOpenGraphItem *item = [self.memoryStorage openGraphItemWithBaseURL:url];
        NSParameterAssert(!self.memoryStorage[ID]);
        if (item) {
            
            item = [item copy];
            NSParameterAssert(![item.ID isEqualToString:ID]);
            item.ID = ID;
            self.memoryStorage[ID] = item;
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.multicastDelegate openGraphSerivce:self
                      didAddOpenGraphItemToMemoryStorage:item];
                QMSLog(@"ID: %@, url %@ - exists", ID, url);
            });
            
            return;
        }
        
        dispatch_semaphore_t sem = dispatch_semaphore_create(0);
        
        weakOperation.request =
        [self.ogsClient GET:@""
                 parameters:@{@"url": url}
                   progress:nil
                    success:^(NSURLSessionDataTask *task, NSData *responseObject)
         {
             //serial queue (com.q-municate.ogs)
             NSError *jsonError = nil;
             NSDictionary * jsonObject =
             [NSJSONSerialization JSONObjectWithData:responseObject
                                             options:NSJSONReadingAllowFragments
                                               error:&jsonError];
             if (jsonObject) {
                 
                 QMSLog(@"open graph item:"
                       "\r%@",
                       jsonObject);
                 
                 QMOpenGraphItem *openGraphItem =
                 [weakSelf openGraphWithID:ID dictionary:jsonObject baseUrl:url];
                 
                 dispatch_group_t group = dispatch_group_create();
                 // Load Preview image
                 if (openGraphItem.imageURL) {
                     
                     NSURL *previewImageURL = [NSURL URLWithString:openGraphItem.imageURL];
                     dispatch_group_enter(group);
                     [weakSelf.multicastDelegate openGraphSerivce:weakSelf hasImageURL:previewImageURL completion:^{
                         
                         QMSLog(@"--->: %tu, Finish load preview image %@",
                               task.taskIdentifier, previewImageURL.absoluteString);
                         
                         dispatch_group_leave(group);
                     }];
                 }
                 // Load favicon
                 NSURL *faviconURL = [NSURL URLWithString:openGraphItem.faviconUrl];
                 dispatch_group_enter(group);
                 [weakSelf.multicastDelegate openGraphSerivce:weakSelf
                                             hasFaviconURL:faviconURL completion:^
                  {
                      QMSLog(@"--->: %tu, Finish load favicon %@",
                            task.taskIdentifier, faviconURL.absoluteString);
                      dispatch_group_leave(group);
                  }];
                 
                 dispatch_group_notify(group, _ogsQueue, ^{
                     
                     weakSelf.memoryStorage[ID] = openGraphItem;
                     [weakSelf.multicastDelegate openGraphSerivce:weakSelf
                               didAddOpenGraphItemToMemoryStorage:openGraphItem];
                     
                     dispatch_semaphore_signal(sem);
                 });
             }
             
         } failure:^(NSURLSessionDataTask *task, NSError *error) {
             QMSLog(@"Failure task %tu, error - %@", task.taskIdentifier, error.localizedDescription);
             dispatch_semaphore_signal(sem);
         }];
        
        QMSLog(@"Task: %tu, ID: %@, load for %@", weakOperation.request.task.taskIdentifier, ID, url);
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
        QMSLog(@"Done: %tu, ID: %@, %@", weakOperation.request.task.taskIdentifier, ID, url);
    }];
    
    QMSLog(@"Add: %@, %@", operation, url);
    [_operationQueue addOperation:operation];
}

- (void)cancelAllloads {
    
    [self.operationQueue cancelAllOperations];
}

- (void)preloadGraphItemForText:(NSString *)text ID:(NSString *)ID {
    
    if (text.length == 0 || ID.length == 0) {
        return;
    }
    
    QMOpenGraphItem *openGraphItem = self.memoryStorage[ID];
    
    if (!openGraphItem) {
        
        if ([self.cahceDataSource
             respondsToSelector:@selector(cachedOpenGraphItemWithID:)]) {
            
            openGraphItem = [self.cahceDataSource cachedOpenGraphItemWithID:ID];
            
            if (openGraphItem) {
                self.memoryStorage[openGraphItem.ID] = openGraphItem;
                [self.multicastDelegate openGraphSerivce:self didLoadFromCache:openGraphItem];
            }
            else {
                
                dispatch_async(_ogsQueue, ^{
                    
                    NSDataDetector *detector =
                    [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink
                                                    error:nil];
                    
                    NSRange textRenge = NSMakeRange(0, text.length);
                    NSTextCheckingResult *result = [detector firstMatchInString:text options:0 range:textRenge];
                    
                    if (!result ||
                        [result.URL.absoluteString hasPrefix:@"mailto:"]) {
                    }
                    else {
                        
                        [self loadOpenGraphForURL:result.URL.absoluteString ID:ID];
                    }
                });
            }
        }
    }
}

//MARK: - Helpers

- (QMOpenGraphItem *)openGraphWithID:(NSString *)ID
                          dictionary:(NSDictionary *)dictionary
                             baseUrl:(NSString *)baseUrl {
    
    QMOpenGraphItem *openGraphItem = [[QMOpenGraphItem alloc] init];
    
    NSURL *_url = [NSURL URLWithString:baseUrl];
    
    
    openGraphItem.baseUrl = baseUrl;
    openGraphItem.faviconUrl = [NSString stringWithFormat:@"%@://%@/favicon.ico", _url.scheme, _url.host];
    openGraphItem.ID = ID;
    
    if (![dictionary[kQMKeyImageURL] isKindOfClass:[NSNull class]]) {
        
        NSString *imagePath = dictionary[kQMKeyImageURL][@"url"];
        
        imagePath = [imagePath stringByReplacingOccurrencesOfString:@".gif/" withString:@".gif"];
        
        if (imagePath != nil) {
            openGraphItem.imageURL = imagePath;
        }
    }
    
    if (![dictionary[kQMKeyTitle] isKindOfClass:[NSNull class]]) {
        
        openGraphItem.siteTitle = dictionary[kQMKeyTitle];
    }
    
    if (![dictionary[kQMKeyDescription] isKindOfClass:[NSNull class]]) {
        
        openGraphItem.siteDescription = dictionary[kQMKeyDescription];
    }
    
    return openGraphItem;
}

- (NSString *)qm_standartitizedURLStringFromString:(NSString *)stringURL {
    
    NSArray *prefixes = @[@"https:", @"http:", @"//", @"/", @"www."];
    
    for (NSString *prefix in prefixes) {
        
        if ([stringURL hasPrefix:prefix]) {
            stringURL =
            [stringURL stringByReplacingOccurrencesOfString:prefix
                                                 withString:@""
                                                    options:NSAnchoredSearch
                                                      range:NSMakeRange(0,stringURL.length)];
        }
    }
    
    return stringURL;
}

@end

@implementation QMOpenGraphLoadOperation

- (void)setCancelBlock:(dispatch_block_t)cancelBlock {
    // check if the operation is already cancelled, then we just call the cancelBlock
    if (self.isCancelled) {
        if (cancelBlock) {
            cancelBlock();
        }
        _cancelBlock = nil; // don't forget to nil the cancelBlock, otherwise we will get crashes
    } else {
        _cancelBlock = [cancelBlock copy];
    }
}

- (void)cancel {
    
    [super cancel];
    
    if (self.cancelBlock) {
        self.cancelBlock();
        
        // TODO: this is a temporary fix to #809.
        // Until we can figure the exact cause of the crash, going with the ivar instead of the setter
        //        self.cancelBlock = nil;
        _cancelBlock = nil;
    }
}


- (void)dealloc {
    
    QMSLog(@"%@, class: %@, id: %@", NSStringFromSelector(_cmd), NSStringFromClass(self.class), _identifier);
}

- (NSString *)description {
    
    NSMutableString *result = [NSMutableString stringWithString:[super description]];
    [result appendFormat:@" ->>> %@", _identifier];
    
    return result.copy;
}

@end
