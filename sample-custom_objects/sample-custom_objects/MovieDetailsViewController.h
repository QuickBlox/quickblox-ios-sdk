//
//  MovieDetailsViewController.h
//  sample-custom_objects
//
//  Created by Igor Khomenko on 6/10/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Quickblox/Quickblox.h>

@interface MovieDetailsViewController : UIViewController

@property (nonatomic) QBCOCustomObject *movie;

@end
