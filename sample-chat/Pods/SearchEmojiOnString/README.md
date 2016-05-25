# SearchEmojiOnString-iOS

[![Version](https://img.shields.io/cocoapods/v/SearchEmojiOnString.svg?style=flat-square)](http://cocoapods.org/pods/SearchEmojiOnString)
[![License](https://img.shields.io/cocoapods/l/SearchEmojiOnString.svg?style=flat-square)](http://cocoapods.org/pods/SearchEmojiOnString)
[![Platform](https://img.shields.io/cocoapods/p/SearchEmojiOnString.svg?style=flat-square)](http://cocoapods.org/pods/SearchEmojiOnString)
[![CocoaPods](https://img.shields.io/cocoapods/metrics/doc-percent/SearchEmojiOnString.svg?style=flat-square)](http://cocoapods.org/pods/SearchEmojiOnString)
[![Build Status](https://img.shields.io/travis/GabrielMassana/SearchEmojiOnString-iOS/master.svg?style=flat-square)](https://travis-ci.org/GabrielMassana/SearchEmojiOnString-iOS)

##   What is it?

Category to search emojis on an NSString. 

The category allows to check if has emojis, the number of emojis and the range of the emojis.

## Installation

#### Podfile

```ruby
platform :ios, '8.0'
pod 'SearchEmojiOnString', '~> 1.0'
```

Then, run the following command:

```bash
$ pod install
```

#### Old school

Drag into your project the folder `/SearchEmojiOnString-iOS`. That's all.

## Example

#### ContainsEmoji

YES if the String contains emojis, NO otherwise.

```objc
#import "NSString+EMOEmoji.h"

...

    NSString *emojis = @"🤐🤑🤒🤓🤔🤕🤖🤗🤘🦀🦁🦂🦃🦄🧀☂️✝️✡️☯️";
    BOOL containsEmoji = [emojis emo_containsEmoji];
    NSLog(@"%@", @(containsEmoji));

    // Output: ["true"]
```

#### EmojiCount

Calculate number of emojis on the string.

```objc
#import "NSString+EMOEmoji.h"

...

    NSString *emojis = @"🤐🤑🤒🤓🤔";
    NSInteger emojiCount = [emojis emo_emojiCount];
    NSLog(@"%@", @(emojiCount));

    // Output: ["5"]
```

#### EmojiRanges

Calculate the NSRange for every emoji on the string.

```objc
#import "NSString+EMOEmoji.h"

...

    NSString *emojis = @"🤐emoji🤑test🤒";
    NSArray *emojiRanges = [emojis emo_emojiRanges];
    NSLog(@"%@", emojiRanges);
    
    // Output: ["(
    //    	 "NSRange: {0, 2}",
    //    	 "NSRange: {7, 2}",
    //    	 "NSRange: {13, 2}"
    //		 )"]
```

#### IsPureEmojiString 
Thanks to [Jichao Wu](https://github.com/wujichao)

Calculate if the string consists entirely of emojis.

```objc
#import "NSString+EMOEmoji.h"

...
    NSString *emojisText = @"🤐emoji🤑test🤒";
    BOOL emojiText_isPureEmojiString = [emojisText emo_isPureEmojiString];
    NSLog(@"%@", @(emojiText_isPureEmojiString));
    
    // Output: ["false"]
        
    NSString *emojis = @"🤐🤑🤒";
    BOOL emoji_isPureEmojiString = [emojis emo_isPureEmojiString];
    NSLog(@"%@", @(emoji_isPureEmojiString));

    // Output: ["true"]
 ```
 
## License

SearchEmojiOnString-iOS is released under the MIT license. Please see the file called LICENSE.

## Versions

```bash
$ git tag -a 1.0.0 -m 'Version 1.0.0'

$ git push --tags
```

## Author

Gabriel Massana

##Found an issue?

Please open a [new Issue here](https://github.com/GabrielMassana/SearchEmojiOnString-iOS/issues/new) if you run into a problem specific to SearchEmojiOnString-iOS, have a feature request, or want to share a comment.

