## MD5Digest

This is an extremely simple `NSString` category that creates an MD5 digest from a given `NSString`. The logic to do this came straight from [these](http://stackoverflow.com/questions/652300/using-md5-hash-on-a-string-in-cocoa) [StackOverflow](http://stackoverflow.com/questions/2018550/how-do-i-create-an-md5-hash-of-a-string-in-cocoa) [questions](http://stackoverflow.com/questions/1524604/md5-algorithm-in-objective-c) so you can easily implement it on your own if you would like.

## Usage

It's quite simple:

```
NSString *digest = [someString MD5Digest];
```

## Installation

Using CocoaPods:

```
pod 'MD5Digest'
```

Otherwise just include `NSString+MD5.{h,m}` in your project.


### Testing

I wrote a quick Ruby script to test that the digest produced by this class extension matched that produced by Ruby's built in methods (not that they couldn't mess up, it's just much less likely). Run it with `ruby test.rb`. If you change the name in the project to something else, in order to test it you'll have to change it in the Ruby script as well.

