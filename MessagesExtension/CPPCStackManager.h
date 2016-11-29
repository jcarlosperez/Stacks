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

@property (nonatomic, strong) NSMutableArray *imageKeys;
@property (nonatomic, strong) NSMutableDictionary *imageRatings;

+ (instancetype)sharedInstance;

- (void)addImage:(UIImage *)image;

- (NSArray *)images;

- (UIImage *)previewImage;

- (UIImage *)responseImage;

- (void)removeAllImages;

@end
