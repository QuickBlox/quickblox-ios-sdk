//
//  SearchBarView.m
//  sample-chat
//
//  Created by Injoit on 03.08.2021.
//  Copyright © 2021 QuickBlox Team. All rights reserved.
//

#import "SearchBarView.h"
#import "UIView+Chat.h"

const CGFloat searchBarHeight = 44.0f;

@interface SearchBarView () <UISearchBarDelegate>
//MARK: - Properties
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UIButton *cancelSearchButton;
@property (nonatomic, strong) NSString *searchText;
@end

@implementation SearchBarView
//MARK: - Life Cycle
- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self != nil) {
        [self setupViews];
    }
    return self;
}

//MARK - Setup
- (void)setupViews {
    self.cancelSearchButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.cancelSearchButton setImage:[UIImage imageNamed:@"ic_cancel"] forState:UIControlStateNormal];
    self.cancelSearchButton.tintColor = [UIColor colorWithRed:0.43f green:0.48f blue:0.57f alpha:1.0f];
    self.cancelSearchButton.enabled = YES;
    [self.cancelSearchButton addTarget:self action:@selector(cancelSearchButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.cancelSearchButton];
    self.cancelSearchButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.cancelSearchButton.topAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.topAnchor].active = YES;
    [self.cancelSearchButton.rightAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.rightAnchor].active = YES;
    [self.cancelSearchButton.widthAnchor constraintEqualToConstant:56.0f].active = YES;
    [self.cancelSearchButton.heightAnchor constraintEqualToConstant:searchBarHeight].active = YES;
    self.cancelSearchButton.hidden = YES;
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
    self.searchBar.barTintColor = UIColor.whiteColor;
    self.searchBar.translucent = YES;
    self.searchBar.placeholder = @"Search";
    self.searchBar.delegate = self;
    self.searchBar.showsCancelButton = NO;
    [self addSubview:self.searchBar];
    self.searchBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.searchBar.topAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.topAnchor].active = YES;
    [self.searchBar.rightAnchor constraintEqualToAnchor:self.cancelSearchButton.leftAnchor constant: -2.0f].active = YES;
    [self.searchBar.leftAnchor constraintEqualToAnchor:self.leftAnchor].active = YES;
    [self.searchBar.heightAnchor constraintEqualToConstant:searchBarHeight].active = YES;
    
    UIImageView *iconSearch = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search"]];
    iconSearch.frame = CGRectMake(0.0f, 0.0f, 28.0f, 28.0f);
    iconSearch.contentMode = UIViewContentModeCenter;
    [self.searchBar setRoundBorderEdgeColorView:0.0f borderWidth:1.0f color:nil borderColor:UIColor.whiteColor];
    UITextField *searchTextField = [self.searchBar valueForKey:@"searchField"];
    if (searchTextField) {
        UILabel *systemPlaceholderLabel = [searchTextField valueForKey:@"placeholderLabel"];
        if (systemPlaceholderLabel) {
            
            // Create custom placeholder label
            UILabel *placeholderLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            placeholderLabel.backgroundColor = UIColor.whiteColor;
            placeholderLabel.text = @"Search";
            placeholderLabel.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightRegular];
            placeholderLabel.textColor = [UIColor colorWithRed:0.43f green:0.48f blue:0.57f alpha:1.0f];
            
            [systemPlaceholderLabel addSubview:placeholderLabel];
            placeholderLabel.translatesAutoresizingMaskIntoConstraints = NO;
            [placeholderLabel.leftAnchor constraintEqualToAnchor:systemPlaceholderLabel.leftAnchor].active = YES;
            [placeholderLabel.topAnchor constraintEqualToAnchor:systemPlaceholderLabel.topAnchor].active = YES;
            [placeholderLabel.rightAnchor constraintEqualToAnchor:systemPlaceholderLabel.rightAnchor].active = YES;
            [placeholderLabel.bottomAnchor constraintEqualToAnchor:systemPlaceholderLabel.bottomAnchor].active = YES;
        }
        searchTextField.leftView = iconSearch;
        searchTextField.backgroundColor = UIColor.whiteColor;
        searchTextField.clearButtonMode = UITextFieldViewModeNever;
    }
}

- (void)cancelSearchButtonTapped:(id)sender {
    self.cancelSearchButton.hidden = YES;
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
    
    if ([self.delegate respondsToSelector:@selector(searchBarView:didCancelSearchButtonTapped:)]) {
        [self.delegate searchBarView:self didCancelSearchButtonTapped:sender];
    }
}

#pragma mark UISearchBarDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.cancelSearchButton.hidden = NO;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.searchText = searchText;
    
    if ([self.delegate respondsToSelector:@selector(searchBarView:didChangeSearchText:)]) {
        [self.delegate searchBarView:self didChangeSearchText:searchText];
    }
}

@end
