//
//  ContentViewController.m
//  sample-content
//
//  Created by Igor Khomenko on 6/9/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import "ContentViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface ContentViewController ()

@property (nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Load the image
    //
    NSString *privateUrl = [self.file privateUrl];
    if(privateUrl){
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:privateUrl]
                     placeholderImage:nil];
    }else{
        NSLog(@"Private URL is NULL");
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
