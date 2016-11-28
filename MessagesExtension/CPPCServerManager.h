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

- (void)downloadImagesWithImageKeys:(NSArray<NSString *>*)imageKeys promise:(RXPromise *)promise;

- (void)uploadRawImages:(NSArray<UIImage *>*)images promise:(RXPromise *)promise;

@end
