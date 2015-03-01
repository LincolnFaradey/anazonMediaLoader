//
//  amazonDownloader.m
//  amazonCloudStorage
//
//  Created by Andrei Nechaev on 2/28/15.
//  Copyright (c) 2015 Andrei Nechaev. All rights reserved.
//

#import <AWSiOSSDKv2/AWSCore.h>
#import <AWSiOSSDKv2/S3.h>
#import "Constants.h"
#import "AmazonS3Loader.h"

@interface AmazonS3Loader ()

@property (nonatomic, strong) AWSCognitoCredentialsProvider *credentialsProvider;
@property (nonatomic, strong) AWSServiceConfiguration *serviceConfiguration;

@end
@implementation AmazonS3Loader
@synthesize credentialsProvider;
@synthesize serviceConfiguration;

+ (id)sharedManager
{
    static AmazonS3Loader *sharedAmazonDownloader = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedAmazonDownloader = [[self alloc] init];
    });
    
    return sharedAmazonDownloader;
}

- (id)init
{
    self = [super init];
    if (self) {

        credentialsProvider = [AWSCognitoCredentialsProvider credentialsWithRegionType:AWSRegionUSEast1 identityPoolId:POOL_ID];

        serviceConfiguration = [AWSServiceConfiguration configurationWithRegion:AWSRegionUSWest2 credentialsProvider:credentialsProvider];
        [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = serviceConfiguration;
    }
    
    return self;
}

- (void)uploadPhoto:(UIImage *)image withUploadProgress: (void(^)(int64_t totalBytesSent, int64_t totalBytesExpectedToSend))tracker
{
    NSData *data = UIImagePNGRepresentation(image);
    NSNumber *length = [NSNumber numberWithUnsignedLongLong:[data length]];
    
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];

    uploadRequest.bucket = BUCKET;
    uploadRequest.contentLength = length;
    uploadRequest.body = [self fileURLWith:data];
    uploadRequest.key = [self fileKey];
    uploadRequest.contentType = @"image/png";
    
    uploadRequest.uploadProgress = ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        tracker(totalBytesSent, totalBytesExpectedToSend);
    };
    
    
    [[transferManager upload:uploadRequest] continueWithBlock:^id(BFTask *task) {
        
        if (task.error) {
            NSLog(@"Err - %@", task.error);

        }else if(task.isCancelled) {
            NSLog(@"Task is cancelled");
        }
        
        return nil;
    }];
}

- (NSURL *)fileURLWith:(NSData *)data
{
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:[self fileKey]];
    [data writeToFile:path atomically:YES];
    
    return [NSURL URLWithString:path];
}

- (NSString *)fileKey
{
    return [NSString stringWithFormat:@"%f.png",[NSDate timeIntervalSinceReferenceDate]];
}

@end
