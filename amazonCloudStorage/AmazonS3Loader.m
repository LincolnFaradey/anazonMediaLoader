//
//  amazonDownloader.m
//  amazonCloudStorage
//
//  Created by Andrei Nechaev on 2/28/15.
//  Copyright (c) 2015 Andrei Nechaev. All rights reserved.
//

#import <AWSiOSSDKv2/S3.h>
#import "Constants.h"
#import "AmazonS3Loader.h"

@interface AmazonS3Loader () {
    NSMutableArray *keys;
}

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
    
    AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];

    uploadRequest.bucket = BUCKET;
    uploadRequest.contentLength = length;
    uploadRequest.body = [self fileURLWith:data];
    uploadRequest.key = [self fileKey];
    uploadRequest.contentType = @"image/png";
    
    uploadRequest.uploadProgress = ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        tracker(totalBytesSent, totalBytesExpectedToSend);
    };
    
    
    [[[AWSS3TransferManager defaultS3TransferManager] upload:uploadRequest] continueWithBlock:^id(BFTask *task) {
        
        if (task.error) {
            NSLog(@"Err - %@", task.error);

        }else if(task.isCancelled) {
            NSLog(@"Task is cancelled");
        }
        
        return nil;
    }];
}

- (void)downloadPhoto:(NSString *)imageName progressBlock:(void(^)(int64_t totalBytesSent, int64_t totalBytesExpectedToSend))progress block:(void(^)(UIImage *image))completition
{
    AWSS3TransferManagerDownloadRequest *request = [AWSS3TransferManagerDownloadRequest new];
    request.bucket = BUCKET;
    request.key = imageName;
    request.downloadProgress =  ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        progress(totalBytesSent, totalBytesExpectedToSend);
    };
    NSString* path = [NSTemporaryDirectory() stringByAppendingPathComponent:imageName];
    NSURL *url = [NSURL URLWithString:path];
    
    __block UIImage *image = [UIImage imageWithContentsOfFile:path];
    if (image) {
        completition(image);
        return;
    }
    
    request.downloadingFileURL = url;
    [[[AWSS3TransferManager defaultS3TransferManager] download:request] continueWithSuccessBlock:^id(BFTask *task) {
        if (!task.error) {
            image =  [UIImage imageWithContentsOfFile:path];
            completition(image);
        }
        
        return nil;
    }];
}

- (void)downloadList:(void(^)(NSArray *))completition
{
    AWSS3ListObjectsRequest *listObjects = [AWSS3ListObjectsRequest new];
    listObjects.delimiter = @"/";
    listObjects.bucket = BUCKET;
    keys = [NSMutableArray array];
    AWSS3 *s3 = [[AWSS3 alloc] initWithConfiguration:serviceConfiguration];
    [[s3 listObjects:listObjects] continueWithSuccessBlock:^id(BFTask *task) {
        AWSS3ListObjectsOutput *output = [AWSS3ListObjectsOutput new];
        output = task.result;
        
        for (AWSS3Object *s3object in output.contents) {
            [keys addObject:s3object.key];
        }
        completition(keys);
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
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM-dd-yyyy-hh:mm:ssa"];
    NSString *dateString = [dateFormat stringFromDate:today];
    NSLog(@"time %@", dateString);
    return [NSString stringWithFormat:@"%@.png", dateString];
}

@end
