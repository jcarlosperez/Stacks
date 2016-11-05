//
//  CPPCStackManager.h
//  PicChoose
//
//  Created by Ben Rosen on 11/3/16.
//  Copyright © 2016 CP Digital Darkroom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CPPCStackManager : NSObject

+ (instancetype)sharedInstance;

- (void)addImage:(UIImage *)image;

@end
