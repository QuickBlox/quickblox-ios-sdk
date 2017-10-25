//
//  QMMediaViewDelegate.h
//  QMPLayer
//
//  Created by Vitaliy Gurkovsky on 1/30/17.
//  Copyright © 2017 quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 The current state of the media view.
 */
typedef NS_ENUM(NSInteger, QMMediaViewState) {
    /** Default view state.*/
    QMMediaViewStateNotReady,
    /** The view is ready to play.*/
    QMMediaViewStateReady,
    /** The view's model is loading.*/
    QMMediaViewStateLoading,
    /** The view is playing.*/
    QMMediaViewStateActive,
    /** The error has been occured.*/
    QMMediaViewStateError
};

@protocol QMMediaHandler;

@protocol QMMediaViewDelegate <NSObject>

@required

/**
 The QMMediaHandler's delegate.
 */
@property (nonatomic, weak) id <QMMediaHandler> mediaHandler;

/**
 The message ID.
 */
@property (nonatomic, strong) NSString *messageID;

@optional

/**
 Determines whether the view should have cancel button.
 */
@property (nonatomic, assign) BOOL cancellable;

/**
 Determines whether the view should have play button.
 */
@property (nonatomic, assign) BOOL playable;

/**
 The state of the view.
 @see 'QMMediaViewState'.
 */
@property (nonatomic, assign) QMMediaViewState viewState;

/**
 Represents the current time.
 */
@property (nonatomic, assign) NSTimeInterval currentTime;
/**
 Represents the current duration.
 */
@property (nonatomic, assign) NSTimeInterval duration;

/**
 Represents the current progress.
 */
@property (nonatomic, assign) CGFloat progress;

/**
 Sets the thumbnail image.
 */
@property (nonatomic, strong) UIImage *thumbnailImage;

/**
 Sets the image.
 */
@property (nonatomic, strong) UIImage *image;

/**
 Tells the delegate that the error has been occured.
 
 @param error The instance of NSError.
 */
- (void)showLoadingError:(NSError *)error;

/**
 Tells the delegate that the error has been occured.
 
 @param error The instance of NSError.
 */
- (void)showUploadingError:(NSError *)error;

@end

@protocol QMMediaHandler

/**
 Tells the delegate that the media button has been tapped.
 
 @param view Instance that adopts id<QMMediaViewDelegate>.
 */
- (void)didTapMediaButton:(id<QMMediaViewDelegate>)view;

@end
