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
        
        // create instance of aws object to later upload pictures
        AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionUSEast1 identityPoolId:@"***REMOVED***" unauthRoleArn:@"***REMOVED***" authRoleArn:nil  identityProviderManager:nil];
        
        AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:credentialsProvider];
        
        [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
        
        // create folders so we can temporarily store them before upload
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

- (void)uploadRawImage:(UIImage *)image promise:(RXPromise *)promise {
    NSString *uniqueString = [[NSProcessInfo processInfo] globallyUniqueString];
    NSString *fileName = [uniqueString stringByAppendingString:@".jpg"];
    NSString *filePath = [[NSTemporaryDirectory() stringByAppendingPathComponent:@"upload"] stringByAppendingPathComponent:fileName];

    CGFloat height = image.size.height / (image.size.width/500);
    UIImage *scaledImaged = [image scaledImageToSize:CGSizeMake(500, height)];
    NSData *imageData = UIImageJPEGRepresentation(scaledImaged, 0.4);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error = nil;
        [imageData writeToFile:filePath options:NSDataWritingAtomic error:&error];
        if (!error) {
            // enough prep... actually upload the image now
            AWSS3TransferManagerUploadRequest *uploadRequest = [[AWSS3TransferManagerUploadRequest alloc] init];
            uploadRequest.body = [NSURL fileURLWithPath:filePath];
            uploadRequest.key = fileName;
            uploadRequest.bucket = @"picchoosebackend";
            [[[AWSS3TransferManager defaultS3TransferManager] upload:uploadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id _Nullable(AWSTask * _Nonnull task) {
                if (task.error) {
                    [promise rejectWithReason:task.error];
                    return nil;
                }
                [promise fulfillWithValue:uniqueString];
                return nil;
            }];
        }
    });
}

@end
