//
//  SearchBarView.h
//  sample-chat
//
//  Created by Injoit on 03.08.2021.
//  Copyright © 2021 QuickBlox Team. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class SearchBarView;

@protocol SearchBarViewDelegate <NSObject>

- (void)searchBarView:(SearchBarView *)searchBarView
  didChangeSearchText:(NSString *)searchText;

- (void)searchBarView:(SearchBarView *)searchBarView
didCancelSearchButtonTapped:(UIButton *)sender;

@end

@interface SearchBarView : UIView

@property (nonatomic, weak) id<SearchBarViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
