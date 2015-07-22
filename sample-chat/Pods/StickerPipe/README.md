## About

**StickerPipe** is a stickers SDK for iOS

![ios](ios.gif)

## Installation

Get the API key on the [StickerPipe](http://stickerpipe.com/)

CocoaPods:
```ruby
pod "StickerPipe", "~> 0.1.6"
```
## Usage

Add API key in your AppDelegate.m 

```objc
[STKStickersManager initWitApiKey:@"API_KEY"];
```

Use category for UIImageView for display sticker

```objc
    if ([STKStickersManager isStickerMessage:message]) {
        [self.stickerImageView stk_setStickerWithMessage:message completion:nil];
        
    }
```

Add STKStickerPanel like inputView for your UITextView/UITextField

```objc
@property (strong, nonatomic) STKStickerPanel *stickerPanel;


self.inputTextView.inputView = self.stickerPanel;
[self.inputTextView reloadInputViews];
```
Use delegate method for reciving sticker messages from sticker panel

```objc
- (void)stickerPanel:(STKStickerPanel *)stickerPanel didSelectStickerWithMessage:(NSString *)stickerMessage {
    
    //Send sticker message
    
}
```
## Сustomizations

**You can change default placeholders color:**

Displayed stickers placeholder color

```objc
[STKStickersManager setColorForDisplayedStickerPlaceholder:[UIColor greenColor]];
```

Placeholder in stickers panel

```objc
[STKStickersManager setColorForPanelPlaceholder:[UIColor redColor]];
```

Placeholder in stickers panel header

```objc
[STKStickersManager setColorForPanelHeaderPlaceholderColor:[UIColor blueColor]];
```

## Credits

908 Inc.

## Contact

mail@908.vc

## License

StickerPipe is available under the Apache 2 license. See the [LICENSE](LICENSE) file for more information.
