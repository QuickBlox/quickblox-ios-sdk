//
//  DialogTableViewCell.m
//  sample-multiconference-videochat
//
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import "DialogTableViewCell.h"

@interface DialogTableViewCell () {
    
    NSString *_title;
}

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation DialogTableViewCell

// MARK: - Overrides

- (void)setTitle:(NSString *)title {
    
    if (![_title isEqualToString:title]) {
        
        _title = [title copy];
        self.titleLabel.text = _title;
    }
}

// MARK: - Actions

- (IBAction)didTapListenerButton {
    [_delegate dialogCellDidListenerButton:self];
}

- (IBAction)didTapAudioButton {
    [_delegate dialogCellDidAudioButton:self];
}

- (IBAction)didTapVideoButton {
    [_delegate dialogCellDidVideoButton:self];
}

@end
