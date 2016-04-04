//
//  STKStickersShopViewController.h
//  StickerPipe
//
//  Created by Olya Lutsyk on 1/28/16.
//  Copyright © 2016 908 Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STKStickersShopViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIWebView *stickersShopWebView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activity;

@property (nonatomic, strong) NSString *packName;
@end
