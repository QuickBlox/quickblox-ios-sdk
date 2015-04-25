//
//  CheckUserTableViewCell.m
//  QBRTCChatSemple
//
//  Created by Andrey Ivanov on 11.12.14.
//  Copyright (c) 2014 QuickBlox Team. All rights reserved.
//

#import "CheckUserTableViewCell.h"
#import "CheckMarkView.h"
#import "CornerView.h"

@interface CheckUserTableViewCell()

@property (weak, nonatomic) IBOutlet CheckMarkView *checkmakrView;
@property (assign, nonatomic) BOOL checkmark;

@end

@implementation CheckUserTableViewCell

- (void)setCheckmark:(BOOL)isCheck {
    
    if (_checkmark != isCheck) {
        
        _checkmark = isCheck;
        self.checkmakrView.check = isCheck;
    }
}

@end
