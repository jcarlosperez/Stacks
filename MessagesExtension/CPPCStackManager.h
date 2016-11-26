//
//  CPPCStackManager.h
//  PicChoose
//
//  Created by Ben Rosen on 11/3/16.
//  Copyright © 2016 CP Digital Darkroom. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSNotificationName const CPPCImageChangeNotificationName = @"CPPCImageChangeNotificationName";

@interface CPPCStackManager : NSObject

+ (instancetype)sharedInstance;

- (void)addImage:(UIImage *)image;

- (NSArray *)images;

- (UIImage *)previewImage;

- (void)removeAllImages;

@end
