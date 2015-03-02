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
    NSLog(@"%s", __FUNCTION__);
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [[AmazonS3Loader sharedManager] downloadPhoto:_imageName progressBlock:^(int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.navigationItem.title = [NSString stringWithFormat:@"%lld", totalBytesSent * 100 / totalBytesExpectedToSend ];
        });
        
        
    } block:^(UIImage *image) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageView = [[UIImageView alloc] initWithImage:image];
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
