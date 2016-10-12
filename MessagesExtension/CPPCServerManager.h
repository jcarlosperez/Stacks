//
//  CPPCServerManager.h
//  PicChoose
//
//  Created by Ben Rosen on 10/9/16.
//  Copyright © 2016 CP Digital Darkroom. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RXPromise;

@interface CPPCServerManager : NSObject

+ (instancetype)sharedInstance;

- (void)uploadRawImage:(UIImage *)image promise:(RXPromise *)promise;

@end
