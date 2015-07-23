//
//  STKStickerHeaderDelegateManager.h
//  StickerPipe
//
//  Created by Vadim Degterev on 21.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface STKStickerHeaderDelegateManager : NSObject <UICollectionViewDataSource, UICollectionViewDelegate>

@property (copy, nonatomic) void(^didSelectRow)(NSIndexPath *indexPath);
@property (strong, nonatomic) UIImage *placeholderImage;
@property (strong, nonatomic) UIColor *placeholderHeadercolor;


- (void)setStickerPacks:(NSArray *)stickerPacks;

@end
