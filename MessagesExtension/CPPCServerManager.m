//
//  CPPCServerManager.m
//  PicChoose
//
//  Created by Ben Rosen on 10/9/16.
//  Copyright © 2016 CP Digital Darkroom. All rights reserved.
//

#import "CPPCServerManager.h"
#import "UIImage+Optimizations.h"
#import "RXPromise.h"
#import "CPPCUtilities.h"

@implementation CPPCServerManager

#pragma mark - Shared Instance

+ (instancetype)sharedInstance {
    static CPPCServerManager *staticInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        staticInstance = [[self alloc] init];
    });
    return staticInstance;
}

#pragma mark - Initialization

- (instancetype)init {
    if (self = [super init]) {
        
        AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionUSEast1 identityPoolId:@"***REMOVED***" unauthRoleArn:@"***REMOVED***" authRoleArn:nil  identityProviderManager:nil];
        
        AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:credentialsProvider];
        
        [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
        
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"upload"] withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"Error creating upload folder: %@", error);
        }
        
        [[NSFileManager defaultManager] createDirectoryAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"download"] withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"Error creating download folder: %@", error);
        }
    }
    return self;
}

#pragma mark - Class Methods

- (void)downloadImagesWithImageKeys:(NSArray<NSString *>*)imageKeys promise:(RXPromise *)promise  {
    NSMutableArray *imageFileURLs = [NSMutableArray array];
    for (NSString *imageKey in imageKeys) {
        NSString *fullImageName = [imageKey stringByAppendingString:@".jpg"];
        NSString *localFileString = [CPPCUtilities localFileURLFromImageName:fullImageName];
        
        AWSS3TransferManagerDownloadRequest *downloadRequest = [[AWSS3TransferManagerDownloadRequest alloc] init];
        downloadRequest.bucket = @"picchoosebackend";
        downloadRequest.key = fullImageName;
        downloadRequest.downloadingFileURL = [NSURL fileURLWithPath:localFileString];
        
        AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
        
        [[transferManager download:downloadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id _Nullable(AWSTask * _Nonnull task) {
            if (task.result) {
                [imageFileURLs addObject:localFileString];
            } else if (task.error) {
                [promise rejectWithReason:task.error];
                return nil;
            }
            return nil;
        }];
    }
    [promise fulfillWithValue:imageFileURLs];
}

- (void)downloadImageWithKey:(NSString *)imageKey withSuccessBlock:(void (^)(AWSTask *))successBlock failureBlock:(void (^)(NSError *))failureBlock {
    
    NSString *fileKey = [NSString stringWithFormat:@"%@.jpg", imageKey];
    
    NSString *downloadingFilePath = [[NSTemporaryDirectory() stringByAppendingPathComponent:@"download"] stringByAppendingPathComponent:fileKey];
    NSURL *downloadingFileURL = [NSURL fileURLWithPath:downloadingFilePath];
    
    AWSS3TransferManagerDownloadRequest *downloadRequest = [AWSS3TransferManagerDownloadRequest new];
    downloadRequest.bucket = @"picchoosebackend";
    downloadRequest.key = fileKey;
    downloadRequest.downloadingFileURL = downloadingFileURL;
    
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    
    [[transferManager download:downloadRequest] continueWithBlock:^id(AWSTask *task) {
        
        if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]
            && task.error.code == AWSS3TransferManagerErrorPaused) {
            NSLog(@"Download paused.");
        } else if (task.error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                failureBlock(task.error);
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                successBlock(task);
            });
        }
        
        return nil;
    }];
}

- (void)uploadRawImages:(NSArray<UIImage *>*)images promise:(RXPromise *)promise {
    NSMutableArray *imageURLs = [NSMutableArray array];
    for (UIImage *image in images) {
        NSString *imageName = [[NSProcessInfo processInfo] globallyUniqueString];
        NSString *imagePath = [NSString stringWithFormat:@"%@/%@.jpg", self.class.temporaryUploadFilePath, imageName];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *imageData = UIImageJPEGRepresentation(image, 0.2);
            
            NSError *error = nil;
            [imageData writeToFile:imagePath options:NSDataWritingAtomic error:&error];
            if (error) {
                [promise rejectWithReason:error];
                return;
            }
            AWSS3TransferManagerUploadRequest *uploadRequest = [[AWSS3TransferManagerUploadRequest alloc] init];
            uploadRequest.body = [NSURL fileURLWithPath:imagePath];
            uploadRequest.key = imageName;
            uploadRequest.bucket = @"picchoosebackend";
            [[[AWSS3TransferManager defaultS3TransferManager] upload:uploadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id _Nullable(AWSTask * _Nonnull task) {
                if (task.result) {
                    [imageURLs addObject:imageName];
                } else {
                    [promise rejectWithReason:task.error
                     ];
                }
                return nil;
            }];
        });
    }
    [promise fulfillWithValue:imageURLs];

}

+ (NSString *)temporaryDownloadFilePath {
    return [NSTemporaryDirectory() stringByAppendingPathComponent:@"download"];
}

+ (NSString *)temporaryUploadFilePath {
    return [NSTemporaryDirectory() stringByAppendingPathComponent:@"upload"];
}

@end
