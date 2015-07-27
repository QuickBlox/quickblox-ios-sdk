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
pod "StickerPipe", "~> 0.1"
```
## Usage

Add API key in your AppDelegate.m 

```objc
[STKStickersManager initWitApiKey:@"API_KEY"];
```

Use category for UIImageView for display sticker

```objc
    if ([STKStickersManager isStickerMessage:message]) {
        [self.stickerImageView stk_setStickerWithMessage:message placeholder:nil placeholderColor:nil progress:nil completion:nil];
        
    }
```
Init STKStickerController and add stickersView like inputView for your UITextView/UITextField

```objc
@property (strong, nonatomic) STKStickerController *stickerController;


self.inputTextView.inputView = self.stickerController.stickersView;
[self reloadStickersInputViews];
```
Use delegate method for reciving sticker messages from sticker view controller

```objc
- (void)stickerController:(STKStickerController *)stickerController didSelectStickerWithMessage:(NSString *)message {
    
    //Send sticker message
    
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
