//
//  QMAudioIncomingCell.h
//  Pods
//
//  Created by Vitaliy Gurkovsky on 2/13/17.
//
//

#import "QMMediaIncomingCell.h"
#import "QMProgressView.h"

@interface QMAudioIncomingCell : QMMediaIncomingCell

@property (weak, nonatomic) IBOutlet QMProgressView *progressView;

@end
