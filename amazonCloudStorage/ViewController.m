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

@property (weak, nonatomic) IBOutlet UILabel *percetageLabel;
@property (weak, nonatomic) IBOutlet UIButton *snapButton;

@property (nonatomic, strong) UIPopoverController *popController;
@property (nonatomic, strong) UIImagePickerController *imagePickerController;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _imagePickerController = [[UIImagePickerController alloc] init];
    _imagePickerController.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.percetageLabel.alpha = 0.0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)showImagePicker:(UIButton *)sender {
    [self sourceType];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.popController = [[UIPopoverController alloc] initWithContentViewController:_imagePickerController];
        [self.popController presentPopoverFromRect:CGRectMake(0, 0, 300, 300) inView:self.snapButton permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
    }else {
        [self presentViewController:self.imagePickerController animated:YES completion:nil];
    }
}


#pragma mark - UIImagePickerControllerDelegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    AmazonS3Loader *am = [AmazonS3Loader sharedManager];
    [am uploadPhoto:image withUploadProgress:^(int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        dispatch_async(dispatch_get_main_queue(), ^{
            int percents = (int)(totalBytesSent * 100 / totalBytesExpectedToSend);
            _percetageLabel.textColor = [self colorfulPercents:percents];
            _percetageLabel.alpha = percents / 100.;
            _percetageLabel.text = [NSString stringWithFormat:@"%d", percents];
        });
    }];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self.popController dismissPopoverAnimated:YES];
    }else {
        [self.imagePickerController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self.popController dismissPopoverAnimated:YES];
    }else {
        [self.imagePickerController dismissViewControllerAnimated:YES completion:nil];
    }
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

- (IBAction)unwindToSegue:(UIStoryboardSegue *)sender
{
    NSLog(@"%s", __FUNCTION__);
}

- (UIColor *)colorfulPercents:(int)p
{
    if (p < 34) {
        return [UIColor redColor];
    }else if (p < 67) {
        return [UIColor blueColor];
    }else{
        return [UIColor greenColor];
    }
}
- (IBAction)showList:(UIButton *)sender {
    UIStoryboard *iPadSB = [UIStoryboard storyboardWithName:@"Universal" bundle:nil];
    UINavigationController *navController = [iPadSB instantiateViewControllerWithIdentifier:@"navigationController"];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UIPopoverController *popoverVC = [[UIPopoverController alloc] initWithContentViewController:navController];
        [popoverVC presentPopoverFromRect:sender.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }else{
        [self presentViewController:navController animated:YES completion:nil];
    }
    
}

@end
