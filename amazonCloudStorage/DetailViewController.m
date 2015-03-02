//
//  DetailViewController.m
//  amazonCloudStorage
//
//  Created by Andrei Nechaev on 3/1/15.
//  Copyright (c) 2015 Andrei Nechaev. All rights reserved.
//

#import "DetailViewController.h"
#import "AmazonS3Loader.h"

@interface DetailViewController ()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.imageView.layer.affineTransform = CGAffineTransformMakeRotation(M_PI / 2);
    [self downloadPhoto];
}


- (void)downloadPhoto
{
    [[AmazonS3Loader sharedManager] downloadPhoto:_imageName progressBlock:^(int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.navigationItem.title = [NSString stringWithFormat:@"%lld", totalBytesSent * 100 / totalBytesExpectedToSend ];
        });
        
        
    } block:^(UIImage *image) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageView = [[UIImageView alloc] init];
            self.imageView.image = image;
            self.imageView.layer.affineTransform = CGAffineTransformMakeRotation(M_PI / 2);
            self.imageView.frame = self.view.bounds;
            self.imageView.contentMode = UIViewContentModeScaleAspectFit;
            
            [self.view addSubview:self.imageView];
        });
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
