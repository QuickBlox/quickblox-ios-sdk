#import "_CDOpenGraphModel.h"
#import "QMOpenGraphItem.h"

@interface CDOpenGraphModel : _CDOpenGraphModel

- (QMOpenGraphItem *)toQMOpenGraphItem;
- (void)updateWithQMOpenGraphItem:(QMOpenGraphItem *)og;

@end
