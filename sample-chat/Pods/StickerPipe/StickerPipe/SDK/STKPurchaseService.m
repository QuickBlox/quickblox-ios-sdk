//
// Created by Vadim Degterev on 10.08.15.
// Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "STKPurchaseService.h"
#import <StoreKit/StoreKit.h>
#import <DFImageManager/DFImageFetching.h>
#import "STKStickersConstants.h"

@interface STKPurchaseService() <SKProductsRequestDelegate, SKPaymentTransactionObserver>

//TODO: FIX THIS HELL
@property (nonatomic, copy) STKProductsBlock productsCompletionBlock;
@property (nonatomic, copy) STKRestoreCompletionBlock restoreCompletionBlock;
@property (nonatomic, copy) STKPurchaseCompletionBlock purchaseCompletionBlock;
@property (nonatomic, strong) STKPurchaseFailureBlock purchaseFailureBlock;
@property (nonatomic, strong) SKProductsRequest *productRequest;

@property (nonatomic, strong) NSMutableDictionary *purchasedRecord;

@end

@implementation STKPurchaseService

- (instancetype) shared {
    static STKPurchaseService *entity = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        entity = [[STKPurchaseService alloc] init];
    });
    
    return entity;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self restorePurchaseRecord];
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(savePurchaseRecord)
                                                     name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    [self.productRequest cancel];
}


- (NSString *)purchaseRecordFilePath {
    NSString *documentDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    return [documentDirectory stringByAppendingPathComponent:@"stickerpurchases.plist"];
}

- (void)restorePurchaseRecord {
    self.purchasedRecord = (NSMutableDictionary *)[[NSKeyedUnarchiver unarchiveObjectWithFile:[self purchaseRecordFilePath]] mutableCopy];
    if (self.purchasedRecord == nil) {
        self.purchasedRecord = [NSMutableDictionary dictionary];
    }
}

- (void)savePurchaseRecord {
    NSError *error = nil;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.purchasedRecord];
    [data writeToFile:[self purchaseRecordFilePath] options:NSDataWritingAtomic | NSDataWritingFileProtectionComplete error:&error];

}

- (BOOL)isPurchasedProductWithIdentifier:(NSString *)identifier {
    id object = self.purchasedRecord[identifier];
    BOOL isPurchased = object != nil;
    return isPurchased;
}

- (void)purchaseProduct:(SKProduct *)product
             completion:(STKPurchaseCompletionBlock)completion
                failure:(STKPurchaseFailureBlock)failure {

    self.purchaseCompletionBlock = completion;
    self.purchaseFailureBlock = failure;

    SKPayment *payment = [SKPayment paymentWithProduct:product];
    SKPaymentQueue *defaultQueue = [SKPaymentQueue defaultQueue];
    [defaultQueue addPayment:payment];
}

- (void)purchaseProductWithIdentifier:(NSString*)productIdentifier
                           completion:(STKPurchaseCompletionBlock)completion
                              failure:(STKPurchaseFailureBlock)failure
{
    self.purchaseCompletionBlock = completion;
    self.purchaseFailureBlock = failure;

    [self requestProductsWithIdentifiers:[NSSet setWithObject:productIdentifier] completion:^(NSArray *products, NSArray *invalidProductsIdentifier) {
        for (SKProduct *product in products) {
            if ([product.productIdentifier isEqualToString:productIdentifier]) {
                SKPayment *payment = [SKPayment paymentWithProduct:product];
                [[SKPaymentQueue defaultQueue] addPayment:payment];
            }
        }
    }];

}

- (void)requestProductsWithIdentifiers:(NSSet *)identifiers completion:(STKProductsBlock)completion {

    self.productRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:identifiers];
    self.productsCompletionBlock = completion;
    self.productRequest.delegate = self;
    [self.productRequest start];
}


#pragma mark - SKPaymentTransactionObserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions  {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchasing:
                break;

            case SKPaymentTransactionStateDeferred:
                break;

            case SKPaymentTransactionStatePurchased:
            case SKPaymentTransactionStateRestored:
            {
                [self completeTransaction:transaction];
            }
                break;

            case SKPaymentTransactionStateFailed:
            {
                [self failedTransaction:transaction];
            }
                break;
            default:
                break;
        }
    }
}


#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response  {

    if (self.productsCompletionBlock) {
        self.productsCompletionBlock(response.products, response.invalidProductIdentifiers);
    }
}

#pragma mark - Transaction

- (void)completeTransaction:(SKPaymentTransaction *)transaction {

    SKPaymentQueue *defaultQueue = [SKPaymentQueue defaultQueue];

    if (transaction.transactionState == SKPaymentTransactionStateRestored) {
        [defaultQueue finishTransaction:transaction];
        if (self.restoreCompletionBlock) {
            self.restoreCompletionBlock(transaction);
        }
    } else {
        {
            [defaultQueue finishTransaction:transaction];
            if (self.purchaseCompletionBlock) {
                self.purchaseCompletionBlock(transaction);
            }
        }
    }
    //TODO:Refactoring
    self.purchasedRecord[transaction.payment.productIdentifier] = @YES;
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    SKPaymentQueue *defaultQueue = [SKPaymentQueue defaultQueue];
    [defaultQueue finishTransaction:transaction];
    if (self.purchaseFailureBlock) {
        self.purchaseFailureBlock(transaction.error);
    }
}

- (void) restorePurchaseWithCompletion:(STKRestoreCompletionBlock)completion {
    self.restoreCompletionBlock = completion;
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

#pragma mark - purchases

- (void)purchaseSucceedForPack:(NSString *)packName withPrice:(NSString *)packPrice {
    [[NSNotificationCenter defaultCenter] postNotificationName:STKPurchaseSucceededNotification object:self userInfo:@{@"packName": packName, @"packPrice": packPrice}];
}

- (void)purchaseFailed {
    [[NSNotificationCenter defaultCenter] postNotificationName:STKPurchaseFailedNotification object:self];
}

@end