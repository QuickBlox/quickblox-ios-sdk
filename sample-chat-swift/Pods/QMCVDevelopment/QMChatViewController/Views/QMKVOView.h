//
//  QMKVOView.h
//  
//
//  Created by Vitaliy Gurkovsky on 10/12/16.
//
//

#import <UIKit/UIKit.h>

@interface QMKVOView : UIView

@property (nonatomic, copy, nullable) void (^superFrameDidChangeBlock)(CGRect superViewFrame);

@end
       
