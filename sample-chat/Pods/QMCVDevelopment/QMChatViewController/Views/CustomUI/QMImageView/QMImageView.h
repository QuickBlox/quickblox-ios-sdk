//
//  QMImageView.h
//  Q-municate
//
//  Created by Andrey Ivanov on 27.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDWebImageManager.h"
IB_DESIGNABLE
@protocol QMImageViewDelegate ;

typedef NS_ENUM(NSUInteger, QMImageViewType) {
    QMImageViewTypeNone,
    QMImageViewTypeCircle,
    QMImageViewTypeSquare
};

@interface QMImageView : UIImageView
/**
 Default QMUserImageViewType QMUserImageViewTypeNone
 */
@property (nonatomic) IBInspectable CGFloat borderWidth;
@property (assign, nonatomic) QMImageViewType imageViewType;
@property (strong, nonatomic, readonly) NSURL *url;

@property (weak, nonatomic) id <QMImageViewDelegate> delegate;

- (void)setImage:(UIImage *)image withKey:(NSString *)key;

- (void)applyImage:(UIImage *)image;

- (void)setImageWithURL:(NSURL *)url
            placeholder:(UIImage *)placehoder
                options:(SDWebImageOptions)options
               progress:(SDWebImageDownloaderProgressBlock)progress
         completedBlock:(SDWebImageCompletionBlock)completedBlock;
@end

@protocol QMImageViewDelegate <NSObject>

- (void)imageViewDidTap:(QMImageView *)imageView;

@end
