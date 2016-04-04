## About
[![Version](https://cocoapod-badges.herokuapp.com/v/StickerPipe/badge.png)](http://stickerpipe.com)
[![Platform](https://cocoapod-badges.herokuapp.com/p/StickerPipe/badge.png)](http://stickerpipe.com)
[![License](https://cocoapod-badges.herokuapp.com/l/StickerPipe/badge.(png|svg))](http://stickerpipe.com)

**StickerPipe** is a stickers SDK for iOS

![ios](ios.gif)

## Installation

Get the API key on the [StickerPipe](http://stickerpipe.com/)

CocoaPods:
```ruby
pod "StickerPipe", "~> 0.2.5"
```
# Usage

### API key 

Add API key in your AppDelegate.m 

```objc
[STKStickersManager initWitApiKey:@"API_KEY"];
[STKStickersManager setStartTimeInterval];
```

You can get your own API Key on http://stickerpipe.com to have customized packs set.

### Users

```objc
[STKStickersManager setUserKey:@"USER_ID"];
```

You have an ability to sell content via your internal currency, inApp purchases or provide via subscription model. We use price points for selling our content. Currently we have A, B and C price points. We use A to mark FREE content and B/C for the paid content. Basically B is equal to 0.99$ and C equal to 1.99$ but the actual price can be vary depend on the countries and others circumstances.


To sell content via inApp purchases, you have to create products for B and C content at your iTunes Connect developer console and then set ids to sdk

### In-app purchase product identifiers 

```objc
   [STKStickersManager setPriceBProductId:@"com.priceB.example"         andPriceCProductId:@"com.priceC.example"];
```
To sell content via internal currency, you have to set your prices to sdk. This price labels will be showed at stickers shop, values you will received at callback from shop.


### Internal currency

 ```objc
    [STKStickersManager setPriceBWithLabel:@"0.99 USD" andValue:0.99f];
    [STKStickersManager setPriceCwithLabel:@"1.99 USD" andValue:1.99f];
```

 When your purchase was failed you have to call failed method:
 ```objc
 [[STKStickersPurchaseService sharedInstance] purchaseFailedError:error];
 ```
### Subscription 
If you want to use subscription model, you need to set subscription flag to sdk, when user became or ceased to be subscriber(or premium user). After this, content with B price point be available for free for subscribers(premium users)

```objc
    [STKStickersManager setUserIsSubscriber:NO];
```

You hava to subscribe on purchase notification
 ```objc
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(purchasePack:) name:STKPurchasePackNotification object:nil];
    
- (void)purchasePack:(NSNotification *)notification {
    packName = notification.userInfo[@"packName"];
    packPrice = notification.userInfo[@"packPrice"];
}
 ```
  When your purchase was succeeded you have to call success method:
 ```objc
 [[STKStickersPurchaseService sharedInstance] purchasInternalPackName:packName andPackPrice:packPrice];
 ```


Init STKStickerController and add stickersView like inputView for your UITextView/UITextField

```objc
@property (strong, nonatomic) STKStickerController *stickerController;


 self.stickerController.textInputView = self.inputTextView;
```

Use delegate method for reciving sticker messages from sticker view controller


```objc
- (void)stickerController:(STKStickerController *)stickerController didSelectStickerWithMessage:(NSString *)message {
    
    //Send sticker message
    
}
```

Use delegate method to set base controller for presenting modal controllers 

```objc
- (UIViewController *)stickerControllerViewControllerForPresentingModalView {
    return self;
}
```

### Text message send

```objc
    [self.stickerController textMessageSent:message];

```


## Layout sticker fames 

```objc
- (void)viewDidLayoutSubviews {
[super viewDidLayoutSubviews];
[self.stickerController updateFrames];
}
```

## Сustomizations

**You can change default placeholders color:**


Placeholder in stickers view

```objc
[self.stickerController setColorForStickersPlaceholder:[UIColor redColor]];
```

Placeholder in stickers view header

```objc
[self.stickerController setColorForStickersHeaderPlaceholderColor:[UIColor blueColor]];
```

## Credits

908 Inc.

## Contact

mail@908.vc

## License

StickerPipe is available under the Apache 2 license. See the [LICENSE](LICENSE) file for more information.
