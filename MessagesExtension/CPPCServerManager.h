//
//  CPPCServerManager.h
//  PicChoose
//
//  Created by Ben Rosen on 10/9/16.
//  Copyright © 2016 CP Digital Darkroom. All rights reserved.
//

#import <AWSCore/AWSCore.h>
#import <AWSCognito/AWSCognito.h>
#import <AWSS3/AWSS3.h>
#import <UIKit/UIKit.h>

@class RXPromise;

@interface CPPCServerManager : NSObject

+ (instancetype)sharedInstance;

- (void)downloadImageWithKey:(NSString *)imageKey withSuccessBlock:(void (^)(AWSTask *responseTask))successBlock failureBlock:(void (^)(NSError *error))failureBlock;

- (void)uploadRawImage:(UIImage *)image promise:(RXPromise *)promise;

@end
