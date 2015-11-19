//
//  QMHeaderCollectionReusableView.m
//  Pods
//
//  Created by Vitaliy Gorbachov on 11/16/15.
//
//

#import "QMHeaderCollectionReusableView.h"

@implementation QMHeaderCollectionReusableView

+ (UINib *)nib {
    return [UINib nibWithNibName:NSStringFromClass([self class]) bundle:[NSBundle bundleForClass:[self class]]];
}

+ (NSString *)cellReuseIdentifier {
    return NSStringFromClass([self class]);
}

@end
