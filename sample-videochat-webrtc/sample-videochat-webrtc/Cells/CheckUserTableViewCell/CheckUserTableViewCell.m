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

@end

@implementation CheckUserTableViewCell

- (void)setCheckmark:(BOOL)isCheck {
    self.checkmakrView.checked = isCheck;
}


@end
