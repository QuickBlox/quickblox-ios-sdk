//
//  MainViewController.h
//  SimpleSample-Content
//
//  Created by kirill on 7/17/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//
//
// This class shows how to work with QuickBlox Content module.
// It shows how to organize user's gallery.
// It allows upload/download images to/from gallery.
//

#import <UIKit/UIKit.h>

#define IMAGE_WIDTH 100
#define IMAGE_HEIGHT 100
#define START_POSITION_X 22
#define START_POSITION_Y 10
#define MARGING 5
#define IMAGES_IN_ROW 3

@interface MainViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate, QBActionStatusDelegate,UIGestureRecognizerDelegate>{
    
    int currentImageX;
    int currentImageY;
    int picturesInRowCounter;
    
    NSMutableArray* imageViews;
}
@property (retain, nonatomic) IBOutlet UIScrollView *scroll;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic,retain) UIImagePickerController* imagePicker;

@end
