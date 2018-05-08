//
//  QMAudioOutgoingCell.h
//  Pods
//
//  Created by Vitaliy Gurkovsky on 2/13/17.
//
//

#import "QMMediaOutgoingCell.h"
#import "QMProgressView.h"

@interface QMAudioOutgoingCell : QMMediaOutgoingCell

@property (weak, nonatomic) IBOutlet QMProgressView *progressView;

@end
