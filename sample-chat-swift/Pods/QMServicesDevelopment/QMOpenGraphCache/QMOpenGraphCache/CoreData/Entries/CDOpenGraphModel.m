#import "CDOpenGraphModel.h"

@interface CDOpenGraphModel ()

// Private interface goes here.

@end

@implementation CDOpenGraphModel

- (QMOpenGraphItem *)toQMOpenGraphItem {
    
    QMOpenGraphItem *og = [[QMOpenGraphItem alloc] init];
    
    og.ID = self.id;
    og.baseUrl = self.url;
    og.siteTitle = self.title;
    og.faviconUrl = self.faviconURL;
    og.siteDescription = self.siteDescription;
    og.imageURL = self.imageURL;
    og.imageWidth = self.widthValue;
    og.imageHeight = self.heightValue;
    
    return og;
}

- (void)updateWithQMOpenGraphItem:(QMOpenGraphItem *)og {
    
    self.id = og.ID;
    self.url = og.baseUrl;
    self.title = og.siteTitle;
    self.faviconURL = og.faviconUrl;
    self.siteDescription = og.siteDescription;
    self.imageURL = og.imageURL;
    self.heightValue = og.imageHeight;
    self.widthValue = og.imageWidth;
}

@end
