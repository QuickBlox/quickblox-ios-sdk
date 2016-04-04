//
//  STKStickersShopViewController.m
//  StickerPipe
//
//  Created by Olya Lutsyk on 1/28/16.
//  Copyright © 2016 908 Inc. All rights reserved.
//

#import "STKStickersShopViewController.h"
#import "UIWebView+AFNetworking.h"
#import "STKUtility.h"
#import "STKStickersManager.h"
#import "STKApiKeyManager.h"
#import "STKInAppProductsManager.h"
#import "STKUUIDManager.h"
#import "STKStickersConstants.h"
#import "STKStickersApiService.h"
//#import "STKPurchaseService.h"
#import "STKStickersPurchaseService.h"
#import "STKStickersEntityService.h"
#import "SKProduct+STKStickerSKProduct.h"
#import "STKStickerPackObject.h"

#import "STKStickersShopJsInterface.h"

#import <JavaScriptCore/JavaScriptCore.h>
#import <StoreKit/StoreKit.h>

//static NSString * const mainUrl = @"http://work.stk.908.vc/api/v2/web?";
static NSString * const mainUrl = @"http://api.stickerpipe.com/api/v2/web?";

static NSString * const uri = @"http://demo.stickerpipe.com/work/libs/store/js/stickerPipeStore.js";

static NSUInteger const productsCount = 2;

@interface STKStickersShopViewController () <UIWebViewDelegate, STKStickersShopJsInterfaceDelegate, STKStickersPurchaseDelegate>

@property(nonatomic, strong) STKStickersShopJsInterface *jsInterface;
@property(nonatomic, strong) STKStickersApiService *apiService;
//@property(nonatomic, strong) STKStickersPurchaseService *stickersPurchaseService;
@property(nonatomic, strong) STKStickersEntityService *entityService;

@property(nonatomic, strong) NSMutableArray *prices;

@end

@implementation STKStickersShopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.prices = [NSMutableArray new];
    [self loadShopPrices];
    
    [self setUpButtons];
    
    self.jsInterface.delegate = self;
    //    self.stickersPurchaseService.delegate = self;
    [STKStickersPurchaseService sharedInstance].delegate = self;
    
    self.apiService = [STKStickersApiService new];
}

- (void)packDownloaded {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.stickersShopWebView stringByEvaluatingJavaScriptFromString:@"window.JsInterface.onPackPurchaseSuccess()"];
    });
}

- (void)loadShopPrices {
    if ([STKInAppProductsManager hasProductIds]) {
        __weak typeof(self) wself = self;
        
        //        [self.stickersPurchaseService requestProductsWithIdentifier:[STKInAppProductsManager productIds] completion:^(NSArray *stickerPacks) {
        [[STKStickersPurchaseService sharedInstance] requestProductsWithIdentifier:[STKInAppProductsManager productIds] completion:^(NSArray *stickerPacks) {
            if (stickerPacks.count == productsCount) {
                
                for (SKProduct *product in stickerPacks) {
                    [wself.prices addObject:[product currencyString]];
                }
                [wself loadStickersShop];
                
            } else {
                [wself showErrorAlertWithMessage:@"Can't load products. Try again later" andOkAction:nil andCancelAction:^{
                    [wself dismissViewControllerAnimated:YES completion:nil];
                }];
            }
        } failure:^(NSError *error) {
            [wself showErrorAlertWithMessage:error.localizedDescription andOkAction:nil andCancelAction:nil];
        }];
        
    }
    else {
        if ([STKStickersManager priceBLabel] && [STKStickersManager priceCLabel] ) {
            
            self.prices =  [[NSMutableArray alloc] initWithArray: @[[STKStickersManager priceBLabel], [STKStickersManager priceCLabel]]];
        }
        [self loadStickersShop];
    }
}

- (NSString *)shopUrlString {
    
    NSMutableString *urlstr = [NSMutableString stringWithFormat:@"%@&apiKey=%@&platform=IOS&userId=%@&density=%@&is_subscriber=%d&primaryColor=%@", mainUrl, [STKApiKeyManager apiKey], [STKStickersManager userKey], [STKUtility scaleString], [STKStickersManager isSubscriber], @"047aff"];
    
    if (self.prices.count > 0) {
        [urlstr appendString: [NSMutableString stringWithFormat:
                               @"&priceB=%@&priceC=%@", [self.prices firstObject], [self.prices lastObject]]];
    }
    
    NSMutableString *escapedPath = [NSMutableString stringWithString: [urlstr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
    
    if (self.packName) {
        [escapedPath appendString:[NSString stringWithFormat:@"#/packs/%@", self.packName]];
    } else {
        [escapedPath appendString:@"#/store"];
    }
    
    return escapedPath;
}
- (NSURLRequest *)shopRequest {
    NSURL *url =[NSURL URLWithString:[self shopUrlString]];
    return [NSURLRequest requestWithURL:url];
}

- (void)loadStickersShop {
    [self setJSContext];
    [self.stickersShopWebView loadRequest:[self shopRequest] progress:nil success:^NSString * _Nonnull(NSHTTPURLResponse * _Nonnull response, NSString * _Nonnull HTML) {
        return HTML;
    } failure:^(NSError * error) {
        [self showErrorAlertWithMessage:error.localizedDescription andOkAction:^{
            [self loadStickersShop];
        } andCancelAction:^{
            [self dismissViewControllerAnimated:YES completion:^{
                 [[NSNotificationCenter defaultCenter] postNotificationName:STKCloseModalViewNotification object:self];
            }];
        }];
    }];
}

- (STKStickersShopJsInterface *)jsInterface {
    if (!_jsInterface) {
        _jsInterface = [STKStickersShopJsInterface new];
    }
    return _jsInterface;
}

//- (STKStickersPurchaseService *)stickersPurchaseService {
//    if (!_stickersPurchaseService) {
//        _stickersPurchaseService = [STKStickersPurchaseService new];
//    }
//    return _stickersPurchaseService;
//}

- (STKStickersEntityService *)entityService {
    if (!_entityService) {
        _entityService = [STKStickersEntityService new];
    }
    return _entityService;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUpButtons {
    
    UIBarButtonItem *closeBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed: @"STKBackIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(closeAction:)];
    
    self.navigationItem.leftBarButtonItem = closeBarButton;
    [self.navigationController.navigationBar setBarTintColor: [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1.0]];
    self.navigationController.navigationBar.translucent = NO;
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"STKSettingsIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(showCollections:)];
    self.navigationItem.rightBarButtonItem = settingsButton;
}

- (void)setJSContext {
    
    JSContext *context = [self.stickersShopWebView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    [context setExceptionHandler:^(JSContext *context, JSValue *value) {
        NSLog(@"WEB JS: %@", value);
    }];
    
    context[@"IosJsInterface"] = self.jsInterface;
}

- (void)loadPackWithName:(NSString *)packName andPrice:(NSString *)packPrice {
    __weak typeof(self) wself = self;
    
    [self.apiService loadStickerPackWithName:packName andPricePoint:packPrice success:^(id response) {
        //        [wself.entityService downloadNewPack:response[@"data"]
        //                                   onSuccess:^(NSArray *stickerPacks) {
        [wself.entityService downloadNewPack:response[@"data"] onSuccess:^{
            [wself dismissViewControllerAnimated:YES completion:^{
                [[NSNotificationCenter defaultCenter] postNotificationName:STKNewPackDownloadedNotification object:self userInfo:@{@"packName": packName}];
            }];
        }];
        
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.stickersShopWebView stringByEvaluatingJavaScriptFromString:@"window.JsInterface.onPackPurchaseFail()"];
        });
    }];
}

#pragma mark - Actions

- (IBAction)closeAction:(id)sender {
    
    NSString *currentURL = [self.stickersShopWebView stringByEvaluatingJavaScriptFromString:@"window.location.href"];
    if ([currentURL isEqualToString:[self shopUrlString]] || [currentURL isEqualToString:@"about:blank"]) {
        [self dismissViewControllerAnimated:YES completion:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:STKCloseModalViewNotification object:self];
        }];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.stickersShopWebView stringByEvaluatingJavaScriptFromString:@"window.JsInterface.goBack()"];
        });
    }
    
}

- (IBAction)showCollections:(id)sender {
    
    [self showCollections];
    
}

#pragma mark - UIWebviewDelegate

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    // [self showError:error.localizedDescription];
    [self showErrorAlertWithMessage:error.localizedDescription andOkAction:^{
        [self loadStickersShop];
    } andCancelAction:^{
        [self dismissViewControllerAnimated:YES completion:^{
             [[NSNotificationCenter defaultCenter] postNotificationName:STKCloseModalViewNotification object:self];
        }];
    }];
}

#pragma mark - STKStickersShopJsInterfaceDelegate

- (void)showCollectionsView {
    
    [self showCollections];
}

- (void)purchasePack:(NSString *)packTitle withName:(NSString *)packName
            andPrice:(NSString *)packPrice {
    
    if ([packPrice isEqualToString:@"A"] || ([packPrice isEqualToString:@"B"] && [STKStickersManager isSubscriber]) || [self.entityService hasPackWithName:packName]) {
        
        [self loadPackWithName:packName andPrice:packPrice];
        
    } else {
        
        if ([STKInAppProductsManager hasProductIds]) {
            //            [self.stickersPurchaseService purchaseProductWithPackName:packName andPackPrice:packPrice];
            [[STKStickersPurchaseService sharedInstance] purchaseProductWithPackName:packName andPackPrice:packPrice];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:STKPurchasePackNotification object:self userInfo:@{@"packName":packName, @"packPrice":packPrice}];
        }
    }
    
}

- (void)setInProgress:(BOOL)show {
    self.activity.hidden = !show;
}

- (void)removePack:(NSString *)packName {
    
    __weak typeof(self) wself = self;
    
    [self.apiService deleteStickerPackWithName:packName success:^(id response) {
        STKStickerPackObject *stickerPack = [wself.entityService getStickerPackWithName:packName];
        [wself.entityService togglePackDisabling:stickerPack];
        dispatch_async(dispatch_get_main_queue(), ^{
//            [[NSNotificationCenter defaultCenter]postNotificationName:STKStickersReorderStickersNotification object:self];
            [[NSNotificationCenter defaultCenter] postNotificationName:STKPackRemovedNotification object:self userInfo:@{@"pack":stickerPack}];
            [self.stickersShopWebView stringByEvaluatingJavaScriptFromString:@"window.JsInterface.onPackRemoveSuccess()"];
        });
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.stickersShopWebView stringByEvaluatingJavaScriptFromString:@"window.JsInterface.onPackRemoveFail()"];
        });
    }];
}

- (void)showPack:(NSString *)packName {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:STKShowPackNotification object:self userInfo:@{@"packName": packName}];
        }];
    });
}

#pragma mark - Purchase service delegate

- (void)purchaseSucceededWithPackName:(NSString *)packName andPackPrice:(NSString *)packPrice {
    
    [self loadPackWithName:packName andPrice:packPrice];
}

- (void)purchaseFailedWithError:(NSError *)error {
    [self purchaseFailedError:error];
}


#pragma mark - Show views

- (void)showErrorAlertWithMessage:(NSString *)errorMessage
                      andOkAction:(void(^)(void))completion
                  andCancelAction:(void(^)(void))cancel {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
        
        if (completion) {
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                completion();
            }];
            [alertController addAction:okAction];
        }
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (cancel) {
                cancel();
            } else {
                [alertController dismissViewControllerAnimated:YES completion:nil];
            }
        }];
        [alertController addAction:cancelAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)showCollections {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:STKShowStickersCollectionsNotification object:self];
        }];
    });
}

#pragma mark - purchses

- (void)purchaseFailedError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error) {
            [self showErrorAlertWithMessage:error.localizedDescription andOkAction:nil andCancelAction:nil];
        }
        [self.stickersShopWebView stringByEvaluatingJavaScriptFromString:@"window.JsInterface.onPackPurchaseFail()"];
    });
    
}

@end
