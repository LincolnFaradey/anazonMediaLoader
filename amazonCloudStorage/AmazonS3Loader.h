//
//  AmazonDownloader.h
//  AmazonCloudStorage
//
//  Created by Andrei Nechaev on 2/28/15.
//  Copyright (c) 2015 Andrei Nechaev. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AmazonS3Loader : NSObject

+ (id)sharedManager;

- (void)uploadPhoto:(UIImage *)image withUploadProgress: (void(^)(int64_t totalBytesSent, int64_t totalBytesExpectedToSend))tracker;


@end
