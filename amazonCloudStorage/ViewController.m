//
//  ViewController.m
//  amazonCloudStorage
//
//  Created by Andrei Nechaev on 2/28/15.
//  Copyright (c) 2015 Andrei Nechaev. All rights reserved.
//

#import "ViewController.h"
#import "AmazonS3Loader.h"
#import "TableViewController.h"

@interface ViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    
}

@property (nonatomic) UIImagePickerController *imagePickerController;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _imagePickerController = [[UIImagePickerController alloc] init];
    _imagePickerController.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)showImagePicker:(UIButton *)sender {
    [self sourceType];
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}


#pragma mark - UIImagePickerControllerDelegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    AmazonS3Loader *am = [AmazonS3Loader sharedManager];
    [am uploadPhoto:image withUploadProgress:^(int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        NSLog(@"byte %lld", totalBytesSent * 100 / totalBytesExpectedToSend);
    }];
    
    [self dismissViewControllerAnimated:_imagePickerController completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:_imagePickerController completion:nil];
}


#pragma mark - Helper methods
- (void)sourceType
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    }else {
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
}

- (IBAction)photosButtonPressed:(UIButton *)sender {
    TableViewController *tvc = [[TableViewController alloc] init];
    [self presentViewController:tvc animated:YES completion:nil];
}

@end
